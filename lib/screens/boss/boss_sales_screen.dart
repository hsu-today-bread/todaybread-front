import 'package:flutter/material.dart';
import 'package:todaybread/utils/app_colors.dart';

class BossSalesScreen extends StatelessWidget {
  const BossSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final sales = _dummySales;
    final totalAmount = sales.fold<int>(0, (sum, item) => sum + item.price);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF7F7F7),
        surfaceTintColor: const Color(0xFFF7F7F7),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
        ),
        centerTitle: true,
        title: const Text(
          '매출관리',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                  ),
                  child: Text(
                    '📅 오늘 ${today.month}월 ${today.day}일 (${_weekdayLabel(today.weekday)})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 34, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int index = 0; index < sales.length; index++) ...[
                        _SalesRow(order: index + 1, item: sales[index]),
                        if (index != sales.length - 1)
                          const Divider(
                            height: 28,
                            thickness: 1,
                            color: Color(0xFFE6E6E6),
                          ),
                      ],
                      const Divider(
                        height: 36,
                        thickness: 1,
                        color: Color(0xFFD8D8D8),
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '오늘의 판매금액',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            '${_formatPrice(totalAmount)}원',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return '월';
      case DateTime.tuesday:
        return '화';
      case DateTime.wednesday:
        return '수';
      case DateTime.thursday:
        return '목';
      case DateTime.friday:
        return '금';
      case DateTime.saturday:
        return '토';
      case DateTime.sunday:
        return '일';
      default:
        return '';
    }
  }

  static String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

class _SalesRow extends StatelessWidget {
  const _SalesRow({required this.order, required this.item});

  final int order;
  final _SalesItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$order.',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.name,
            style: const TextStyle(
              fontSize: 15,
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
                color: Color(0xFF4D4D4D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${BossSalesScreen._formatPrice(item.price)}원',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3B3B3B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SalesItem {
  const _SalesItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final int quantity;
  final int price;
}

// TODO: Replace dummy sales data with real sales/order API response.
const List<_SalesItem> _dummySales = [
  _SalesItem(name: '소금빵', quantity: 2, price: 6200),
  _SalesItem(name: '단팥빵', quantity: 1, price: 2400),
  _SalesItem(name: '크루아상', quantity: 3, price: 8100),
  _SalesItem(name: '소보루빵', quantity: 2, price: 3900),
  _SalesItem(name: '꽈배기', quantity: 4, price: 6400),
];
