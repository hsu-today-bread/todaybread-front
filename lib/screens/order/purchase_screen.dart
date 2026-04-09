import 'package:flutter/material.dart';
import 'package:todaybread/utils/app_colors.dart';

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

Future<void> showPurchaseNoticeAndOpenScreen(
  BuildContext context, {
  required List<PurchaseItem> items,
}) async {
  if (items.isEmpty) {
    return;
  }

  final shouldProceed = await showDialog<bool>(
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
                    foregroundColor: Colors.white,
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

  if (shouldProceed != true || !context.mounted) {
    return;
  }

  await Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => PurchaseScreen(items: items)));
}

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key, required this.items});

  final List<PurchaseItem> items;

  int get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

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
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
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
                        for (int index = 0; index < items.length; index++) ...[
                          _PurchaseItemRow(item: items[index]),
                          if (index != items.length - 1)
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
                              '${_formatPrice(totalPrice)}원',
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
                      onPressed: () =>
                          _showPaymentSnackBar(context, '토스페이 결제는 연결 예정입니다.'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3182F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '토스페이로 결제하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () =>
                          _showPaymentSnackBar(context, '일반 결제는 연결 예정입니다.'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF232323),
                        side: const BorderSide(
                          color: AppColors.primaryBackground,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '그냥 결제하기',
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

  static void _showPaymentSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

class _PurchaseItemRow extends StatelessWidget {
  const _PurchaseItemRow({required this.item});

  final PurchaseItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                  '${PurchaseScreen._formatPrice(item.totalPrice)}원',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
