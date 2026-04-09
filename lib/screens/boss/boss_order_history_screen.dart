import 'package:flutter/material.dart';
import 'package:todaybread/utils/app_colors.dart';

class BossOrderHistoryScreen extends StatefulWidget {
  const BossOrderHistoryScreen({super.key});

  @override
  State<BossOrderHistoryScreen> createState() => _BossOrderHistoryScreenState();
}

class _BossOrderHistoryScreenState extends State<BossOrderHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_BossOrderHistoryItem> get _filteredOrders {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _dummyOrders;
    }
    return _dummyOrders
        .where((order) => order.orderNumber.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

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
          '주문 내역',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE4E4E4)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: '주문번호 입력',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF8C8C8C),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text(
                      '검색된 주문이 없습니다.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),
                ),
              for (final order in orders) ...[
                _OrderCard(order: order),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final _BossOrderHistoryItem order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주문번호 : ${order.orderNumber}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFE4E4E4)),
          Column(
            children: [
              for (int index = 0; index < order.items.length; index++) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.items[index].name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                    Text(
                      '${order.items[index].quantity}개',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                if (index != order.items.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  '총 개수',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ),
              Text(
                '${order.totalQuantity}개',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  '결제 내역',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ),
              Text(
                '${_formatPrice(order.paymentAmount)}원',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _showPickupTodo(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBackground,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '픽업 확인',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showPickupTodo(BuildContext context) {
    // TODO: Connect pickup confirmation flow to real order status API.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('픽업 확인 기능은 추후 연결 예정입니다.')));
  }
}

class _BossOrderHistoryItem {
  const _BossOrderHistoryItem({
    required this.orderNumber,
    required this.items,
    required this.paymentAmount,
  });

  final String orderNumber;
  final List<_BossOrderMenuItem> items;
  final int paymentAmount;

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);
}

class _BossOrderMenuItem {
  const _BossOrderMenuItem({required this.name, required this.quantity});

  final String name;
  final int quantity;
}

String _formatPrice(int price) {
  return price.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
}

// TODO: Replace dummy orders with real order-history DTO/API response.
const List<_BossOrderHistoryItem> _dummyOrders = [
  _BossOrderHistoryItem(
    orderNumber: 'A127',
    items: [_BossOrderMenuItem(name: '소금빵', quantity: 2)],
    paymentAmount: 6200,
  ),
  _BossOrderHistoryItem(
    orderNumber: 'A126',
    items: [
      _BossOrderMenuItem(name: '단팥빵', quantity: 1),
      _BossOrderMenuItem(name: '우유식빵', quantity: 1),
    ],
    paymentAmount: 9100,
  ),
  _BossOrderHistoryItem(
    orderNumber: 'A125',
    items: [_BossOrderMenuItem(name: '크루아상', quantity: 3)],
    paymentAmount: 8100,
  ),
  _BossOrderHistoryItem(
    orderNumber: 'A124',
    items: [
      _BossOrderMenuItem(name: '소보루빵', quantity: 2),
      _BossOrderMenuItem(name: '꽈배기', quantity: 2),
    ],
    paymentAmount: 10300,
  ),
  _BossOrderHistoryItem(
    orderNumber: 'A123',
    items: [_BossOrderMenuItem(name: '치아바타', quantity: 1)],
    paymentAmount: 3400,
  ),
  _BossOrderHistoryItem(
    orderNumber: 'A122',
    items: [
      _BossOrderMenuItem(name: '앙버터', quantity: 2),
      _BossOrderMenuItem(name: '버터프레첼', quantity: 1),
    ],
    paymentAmount: 9800,
  ),
];
