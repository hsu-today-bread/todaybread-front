import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:todaybread/screens/order/payment_result_screen.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/payment/payment_service.dart';
import 'package:todaybread/utils/app_colors.dart';

/// Toss orderId 형식 (`order_123`) 에서 내부 orderId (`123`) 추출
int _parseOrderId(String tossOrderId) {
  return int.parse(tossOrderId.replaceFirst('order_', ''));
}

/// 멱등성 키 생성
String _generateIdempotencyKey() {
  final rand = Random.secure();
  final values = List<int>.generate(8, (_) => rand.nextInt(256));
  final hex = values.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
  return 'pay_${DateTime.now().millisecondsSinceEpoch}_$hex';
}

/// Toss 결제 위젯 WebView 화면
///
/// [orderId]    : 백엔드 내부 주문 ID
/// [amount]     : 결제 금액
/// [storeName]  : 가게 이름 (주문명에 사용)
/// [clientKey]  : 토스 페이먼츠 Client Key
class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.storeName,
    required this.clientKey,
  });

  final int orderId;
  final int amount;
  final String storeName;
  final String clientKey;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isPageLoading = true;
  bool _isConfirming = false;
  bool _hasNavigated = false;

  static const _successScheme = 'todaybread://payment/success';
  static const _failScheme = 'todaybread://payment/fail';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isPageLoading = true),
          onPageFinished: (_) => setState(() => _isPageLoading = false),
          onWebResourceError: (_) => setState(() => _isPageLoading = false),
          onNavigationRequest: _handleNavigation,
        ),
      )
      ..loadHtmlString(_buildTossHtml(), baseUrl: 'https://localhost');
  }

  // ── Toss 결제 위젯 HTML 생성 ──────────────────────────────────────────────

  String _buildTossHtml() {
    final tossOrderId = 'order_${widget.orderId}';
    final orderName = '${widget.storeName} 결제';

    return '''
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>결제</title>
  <script src="https://js.tosspayments.com/v2/standard"></script>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Pretendard', sans-serif;
      background: #ffffff;
    }
    .wrap { padding: 16px; }
    #payment-widget { margin-bottom: 8px; }
    #agreement { margin-bottom: 20px; }
    #pay-btn {
      width: 100%; padding: 16px 0;
      background: #3182F6; color: #fff;
      font-size: 16px; font-weight: 700;
      border: none; border-radius: 14px; cursor: pointer;
      -webkit-tap-highlight-color: transparent;
      transition: opacity 0.15s;
    }
    #pay-btn:disabled { background: #c8c8c8; cursor: default; }
    #pay-btn:active:not(:disabled) { opacity: 0.8; }
    .loading-box {
      display: flex; align-items: center; justify-content: center;
      min-height: 180px;
      color: #999; font-size: 14px;
    }
    #err-msg {
      color: #e53935; font-size: 13px;
      margin-top: 12px; text-align: center;
      min-height: 18px;
    }
  </style>
</head>
<body>
  <div class="wrap">
    <div id="payment-widget"><div class="loading-box">결제 수단 불러오는 중…</div></div>
    <div id="agreement"></div>
    <button id="pay-btn" disabled>결제하기</button>
    <p id="err-msg"></p>
  </div>
  <script>
    var clientKey = ${_jsStr(widget.clientKey)};
    var tossOrderId = ${_jsStr(tossOrderId)};
    var amount = ${widget.amount};
    var orderName = ${_jsStr(orderName)};

    var tossPayments = TossPayments(clientKey);
    var widgets = tossPayments.widgets({ customerKey: TossPayments.ANONYMOUS });

    (async function init() {
      await widgets.setAmount({ currency: 'KRW', value: amount });
      await Promise.all([
        widgets.renderPaymentMethods({ selector: '#payment-widget', variantKey: 'DEFAULT' }),
        widgets.renderAgreement({ selector: '#agreement', variantKey: 'AGREEMENT' }),
      ]);
      document.getElementById('pay-btn').disabled = false;
    })().catch(function(e) {
      document.getElementById('err-msg').textContent = '결제 위젯 로드에 실패했습니다.';
    });

    document.getElementById('pay-btn').addEventListener('click', async function() {
      var btn = document.getElementById('pay-btn');
      btn.disabled = true;
      document.getElementById('err-msg').textContent = '';
      try {
        await widgets.requestPayment({
          orderId: tossOrderId,
          orderName: orderName,
          successUrl: '$_successScheme',
          failUrl: '$_failScheme',
        });
      } catch(e) {
        btn.disabled = false;
        if (e.code !== 'USER_CANCEL') {
          document.getElementById('err-msg').textContent = e.message || '결제 중 오류가 발생했습니다.';
        }
      }
    });
  </script>
</body>
</html>
''';
  }

  /// Dart 문자열을 JS 문자열 리터럴로 안전하게 변환
  String _jsStr(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r');
    return "'$escaped'";
  }

  // ── 네비게이션 가로채기 ───────────────────────────────────────────────────

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;

    if (url.startsWith('todaybread://payment/success')) {
      if (_hasNavigated) return NavigationDecision.prevent;
      _hasNavigated = true;

      final uri = Uri.parse(url);
      final paymentKey = uri.queryParameters['paymentKey'] ?? '';
      final tossOrderId = uri.queryParameters['orderId'] ?? '';
      final amountStr = uri.queryParameters['amount'];
      final amount = amountStr != null ? int.tryParse(amountStr) : null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _confirmPayment(paymentKey, tossOrderId, amount);
      });
      return NavigationDecision.prevent;
    }

    if (url.startsWith('todaybread://payment/fail')) {
      if (_hasNavigated) return NavigationDecision.prevent;
      _hasNavigated = true;

      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      final message = uri.queryParameters['message'];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentResultScreen.fail(
              errorCode: code,
              errorMessage: message,
            ),
          ),
        );
      });
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  // ── 결제 승인 확정 ────────────────────────────────────────────────────────

  Future<void> _confirmPayment(
      String paymentKey, String tossOrderId, int? redirectAmount) async {
    if (!mounted) return;
    setState(() => _isConfirming = true);

    try {
      final internalOrderId = _parseOrderId(tossOrderId);
      final confirmAmount = redirectAmount ?? widget.amount;
      final idempotencyKey = _generateIdempotencyKey();

      final result = await PaymentService.instance.confirmPayment(
        paymentKey: paymentKey,
        orderId: internalOrderId,
        amount: confirmAmount,
        idempotencyKey: idempotencyKey,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentResultScreen.success(
            orderId: result.orderId.toString(),
            paymentKey: paymentKey,
            amount: result.amount,
            storeName: widget.storeName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConfirming = false;
        _hasNavigated = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentResultScreen.fail(
            errorMessage: ApiException.messageFrom(e),
          ),
        ),
      );
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: _isConfirming ? null : _onClose,
          icon: Icon(
            Icons.close,
            color: _isConfirming ? Colors.grey : Colors.black,
            size: 24,
          ),
        ),
        title: const Text(
          '결제',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isPageLoading && !_isConfirming)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryBackground,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '결제 페이지 불러오는 중…',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          if (_isConfirming)
            Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primaryBackground,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '결제 확인 중…',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onClose() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '결제를 취소하시겠어요?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '현재 진행 중인 결제가 취소됩니다.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              '계속하기',
              style: TextStyle(color: AppColors.primaryBackground),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
