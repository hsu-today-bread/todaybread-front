import 'package:flutter/material.dart';
import 'package:todaybread/screens/order/payment_webview_screen.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/order/order_service.dart';
import 'package:todaybread/services/payment/payment_service.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/utils/idempotency_key.dart';

// ── 공통 유틸 ────────────────────────────────────────────────────────────────

String _formatPrice(int price) {
  return price.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

// ── PurchaseItem 모델 ─────────────────────────────────────────────────────────

class PurchaseItem {
  const PurchaseItem({
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String name;
  final int unitPrice;
  final int quantity;

  int get totalPrice => unitPrice * quantity;
}

// ── 주의사항 다이얼로그 + PurchaseScreen 진입 ─────────────────────────────────

/// 장바구니 주문용
Future<void> showPurchaseNoticeAndOpenScreen(
  BuildContext context, {
  required List<PurchaseItem> items,
  String? storeName,
}) async {
  if (items.isEmpty) return;

  final shouldProceed = await _showNoticeDialog(context);
  if (shouldProceed != true || !context.mounted) return;

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PurchaseScreen(items: items, storeName: storeName),
    ),
  );
}

/// 바로 구매용
Future<void> showDirectPurchaseNoticeAndOpenScreen(
  BuildContext context, {
  required List<PurchaseItem> items,
  required int breadId,
  required int quantity,
  String? storeName,
}) async {
  if (items.isEmpty) return;

  final shouldProceed = await _showNoticeDialog(context);
  if (shouldProceed != true || !context.mounted) return;

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PurchaseScreen(
        items: items,
        storeName: storeName,
        breadId: breadId,
        directQuantity: quantity,
      ),
    ),
  );
}

Future<bool?> _showNoticeDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                icon: const Icon(
                  Icons.close,
                  color: AppColors.primaryBackground,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 12),
              const Text(
                '구매 전 주의사항',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '저희 오늘의 빵은 고객님의 노쇼 방지를 위해 선 결제 후 픽업으로 진행됩니다.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                  color: Color(0xFF5E5E5E),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBackground,
                    foregroundColor: AppColors.onPrimaryBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ── PurchaseScreen ────────────────────────────────────────────────────────────

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({
    super.key,
    required this.items,
    this.storeName,
    this.breadId,
    this.directQuantity,
  });

  final List<PurchaseItem> items;
  final String? storeName;

  /// 바로 구매 시 필요한 필드 (null이면 장바구니 주문)
  final int? breadId;
  final int? directQuantity;

  bool get isDirectOrder => breadId != null;

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool _isLoading = false;

  int get _totalPrice =>
      widget.items.fold(0, (sum, item) => sum + item.totalPrice);

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
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _isLoading ? Colors.grey : Colors.black,
            size: 20,
          ),
        ),
        title: const Text(
          '구매하기',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '주문내역',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEAEAEA)),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < widget.items.length; i++) ...[
                          _PurchaseItemRow(item: widget.items[i]),
                          if (i != widget.items.length - 1)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(
                                height: 1,
                                color: Color(0xFFE4E4E4),
                              ),
                            ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Divider(height: 1, color: Color(0xFFD9D9D9)),
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '총 주문 금액',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                              '${_formatPrice(_totalPrice)}원',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '결제 수단 선택',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _startTossPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBackground,
                        disabledBackgroundColor: AppColors.primaryBackground
                            .withValues(alpha: 0.6),
                        foregroundColor: AppColors.onPrimaryBackground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.onPrimaryBackground,
                              ),
                            )
                          : const Text(
                              '토스페이로 결제하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 주문 생성 + Client Key 조회 후 결제 WebView로 이동합니다.
  Future<void> _startTossPayment() async {
    setState(() => _isLoading = true);

    try {
      final idempotencyKey = IdempotencyKey.uuidV4();

      // 주문 생성 (장바구니 or 바로구매) + Client Key 동시 조회
      final orderFuture = widget.isDirectOrder
          ? OrderService.instance.createDirectOrder(
              breadId: widget.breadId!,
              quantity: widget.directQuantity!,
              idempotencyKey: idempotencyKey,
            )
          : OrderService.instance.createOrderFromCart(idempotencyKey);

      final results = await Future.wait([
        orderFuture,
        PaymentService.instance.getClientKey(),
      ]);

      final order = results[0] as dynamic;
      final clientKey = results[1] as String;

      if (!mounted) return;
      setState(() => _isLoading = false);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            orderId: order.orderId as int,
            orderIdempotencyKey: idempotencyKey,
            amount: order.totalAmount as int,
            storeName: order.storeName as String,
            clientKey: clientKey,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(ApiException.messageFrom(e))));
    }
  }
}

// ── 주문 항목 행 ──────────────────────────────────────────────────────────────

class _PurchaseItemRow extends StatelessWidget {
  const _PurchaseItemRow({required this.item});

  final PurchaseItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.quantity}개',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5B5B5B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatPrice(item.totalPrice)}원',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F2F2F),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
