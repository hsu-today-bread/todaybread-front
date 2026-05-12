import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:todaybread/config/app_config.dart';
import 'package:todaybread/screens/order/payment_result_screen.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/order/order_service.dart';
import 'package:todaybread/services/payment/payment_service.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/utils/idempotency_key.dart';

/// 토스페이먼츠 결제창 화면 (WebView + JS SDK, API 개별 연동 키 호환)
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
  bool _isConfirming = false;
  bool _isCancelling = false;
  bool _hasHandledTerminalRoute = false;

  String get _successUrl => AppConfig.paymentSuccessUrl;
  String get _failUrl => AppConfig.paymentFailUrl;
  bool get _isBusy => _isConfirming || _isCancelling;

  @override
  void initState() {
    super.initState();

    final tossOrderId = 'order_${widget.orderId}';
    final orderName = '${widget.storeName} 결제';
    final clientKey = jsonEncode(widget.clientKey);
    final encodedTossOrderId = jsonEncode(tossOrderId);
    final encodedOrderName = jsonEncode(orderName);
    final encodedSuccessUrl = jsonEncode(_successUrl);
    final encodedFailUrl = jsonEncode(_failUrl);

    final html =
        '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
</head>
<body>
<script>
  var s = document.createElement('script');
  s.src = 'https://js.tosspayments.com/v2/standard';
  s.onload = function() {
    var tossPayments = TossPayments($clientKey);
    var payment = tossPayments.payment({customerKey: TossPayments.ANONYMOUS});
    payment.requestPayment({
      method: 'CARD',
      amount: { currency: 'KRW', value: ${widget.amount} },
      orderId: $encodedTossOrderId,
      orderName: $encodedOrderName,
      successUrl: $encodedSuccessUrl,
      failUrl: $encodedFailUrl,
    });
  };
  document.head.appendChild(s);
</script>
</body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.startsWith(_successUrl)) {
              _handleSuccess(Uri.parse(url));
              return NavigationDecision.prevent;
            }
            if (url.startsWith(_failUrl)) {
              _handleFail(Uri.parse(url));
              return NavigationDecision.prevent;
            }

            // 외부 앱 스킴 처리 (intent://, supertoss://, kakaotalk:// 등)
            final uri = Uri.tryParse(url);
            if (uri != null &&
                !uri.scheme.startsWith('http') &&
                uri.scheme != 'about' &&
                uri.scheme != 'data') {
              _launchExternalApp(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(html, baseUrl: AppConfig.paymentCallbackBaseUrl);
  }

  Future<void> _launchExternalApp(String url) async {
    String target = url;
    if (url.startsWith('intent://')) {
      final schemeMatch = RegExp(r'scheme=([^;]+)').firstMatch(url);
      if (schemeMatch != null) {
        final scheme = schemeMatch.group(1)!;
        final hostAndPath = url.replaceFirst('intent://', '').split('#').first;
        target = '$scheme://$hostAndPath';
      }
    }

    final uri = Uri.tryParse(target);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleSuccess(Uri uri) {
    if (_hasHandledTerminalRoute) {
      return;
    }
    _hasHandledTerminalRoute = true;

    final paymentKey = uri.queryParameters['paymentKey'] ?? '';
    final orderId = uri.queryParameters['orderId'] ?? '';
    final amount = int.tryParse(uri.queryParameters['amount'] ?? '') ?? 0;

    _confirmPayment(
      paymentKey: paymentKey,
      tossOrderId: orderId,
      amount: amount,
    );
  }

  Future<void> _handleFail(Uri uri) async {
    if (_hasHandledTerminalRoute) {
      return;
    }
    _hasHandledTerminalRoute = true;

    final errorCode = uri.queryParameters['code'] ?? '';
    final errorMessage = uri.queryParameters['message'] ?? '';

    if (errorCode == 'PAY_PROCESS_CANCELED' ||
        errorCode == 'USER_CANCEL' ||
        errorCode == 'PAY_PROCESS_ABORTED') {
      await _cancelPendingOrderAndPop();
      return;
    }

    final cancelErrorMessage = await _cancelPendingOrder();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentResultScreen.fail(
          errorCode: errorCode,
          errorMessage: _buildFailMessage(
            errorMessage: errorMessage,
            cancelErrorMessage: cancelErrorMessage,
          ),
        ),
      ),
    );
  }

  Future<String?> _cancelPendingOrder() async {
    if (_isCancelling) {
      return null;
    }

    if (mounted) {
      setState(() => _isCancelling = true);
    }

    try {
      await OrderService.instance.cancelOrder(widget.orderId);
      return null;
    } catch (e) {
      return ApiException.messageFrom(e);
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  Future<void> _cancelPendingOrderAndPop() async {
    final cancelErrorMessage = await _cancelPendingOrder();
    if (!mounted) {
      return;
    }

    if (cancelErrorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '결제는 취소됐지만 주문 취소 처리에 실패했습니다. 주문내역에서 확인해주세요. ($cancelErrorMessage)',
            ),
          ),
        );
    }

    Navigator.of(context).pop();
  }

  String _buildFailMessage({
    required String errorMessage,
    required String? cancelErrorMessage,
  }) {
    final baseMessage = errorMessage.isNotEmpty
        ? errorMessage
        : '결제를 처리하는 중 문제가 발생했습니다.';

    if (cancelErrorMessage != null) {
      return '$baseMessage\n생성된 주문 취소에 실패했습니다. 주문내역에서 확인해주세요.';
    }

    return '$baseMessage\n생성된 주문은 취소되었습니다.';
  }

  Future<void> _onUserRequestedCancel() async {
    _hasHandledTerminalRoute = true;
    await _cancelPendingOrderAndPop();
  }

  Future<void> _confirmPayment({
    required String paymentKey,
    required String tossOrderId,
    required int amount,
  }) async {
    if (!mounted) return;
    setState(() => _isConfirming = true);

    try {
      final internalOrderId = int.parse(tossOrderId.replaceFirst('order_', ''));
      final idempotencyKey = IdempotencyKey.uuidV4();

      final result = await PaymentService.instance.confirmPayment(
        paymentKey: paymentKey,
        orderId: internalOrderId,
        amount: amount,
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
      setState(() => _isConfirming = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentResultScreen.fail(
            errorMessage: ApiException.messageFrom(e),
          ),
        ),
      );
    }
  }

  void _onClose() {
    if (_isBusy) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '결제를 취소하시겠어요?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '현재 진행 중인 결제와 생성된 결제 대기 주문이 함께 취소됩니다.',
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
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _onUserRequestedCancel();
            },
            child: const Text('취소', style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onClose();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            onPressed: _isBusy ? null : _onClose,
            icon: Icon(
              Icons.close,
              color: _isBusy ? Colors.grey : Colors.black,
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
            if (_isBusy)
              Container(
                color: Colors.black26,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.primaryBackground,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isCancelling ? '주문 취소 중…' : '결제 확인 중…',
                          style: const TextStyle(
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
      ),
    );
  }
}
