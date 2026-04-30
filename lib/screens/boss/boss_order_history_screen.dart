import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/boss/boss_order_response.dart';
import 'package:todaybread/providers/boss/boss_order_provider.dart';
import 'package:todaybread/utils/app_colors.dart';

class BossOrderHistoryScreen extends StatefulWidget {
  const BossOrderHistoryScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<BossOrderHistoryScreen> createState() => _BossOrderHistoryScreenState();
}

class _BossOrderHistoryScreenState extends State<BossOrderHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BossOrderProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BossOrderResponse> _filteredOrders(List<BossOrderResponse> source) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return source;
    }
    return source
        .where((order) => order.orderNumber.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<BossOrderProvider>();
    final orders = _filteredOrders(orderProvider.orders);
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: widget.showAppBar
          ? AppBar(
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
            )
          : null,
      body: SafeArea(
        top: !widget.showAppBar,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, widget.showAppBar ? 12 : 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.showAppBar) ...[
                const Text(
                  '주문내역',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
              ],
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
              if (orderProvider.isLoading && !orderProvider.hasFetched)
                const Padding(
                  padding: EdgeInsets.only(top: 64),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (orderProvider.errorMessage != null &&
                  orderProvider.orders.isEmpty)
                _OrderMessageState(
                  message: orderProvider.errorMessage!,
                  actionLabel: '다시 불러오기',
                  onAction: () =>
                      context.read<BossOrderProvider>().fetchOrders(),
                )
              else if (orders.isEmpty)
                _OrderMessageState(
                  message: isSearching ? '검색된 주문이 없습니다.' : '현재 픽업 대기 주문이 없습니다.',
                )
              else ...[
                for (final order in orders) ...[
                  _OrderCard(
                    order: order,
                    isProcessing: orderProvider.processingOrderId == order.id,
                    onPickupConfirm: () => _handlePickupConfirm(order),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePickupConfirm(BossOrderResponse order) async {
    if (order.id <= 0) {
      _showSnackBar('주문 ID를 확인할 수 없어 픽업 확인을 진행할 수 없습니다.');
      return;
    }

    final success = await context.read<BossOrderProvider>().confirmPickup(
      order.id,
    );
    if (!mounted) {
      return;
    }

    final message = success
        ? '픽업 완료 처리되었습니다.'
        : context.read<BossOrderProvider>().errorMessage ?? '처리에 실패했습니다.';
    _showSnackBar(message);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isProcessing,
    required this.onPickupConfirm,
  });

  final BossOrderResponse order;
  final bool isProcessing;
  final VoidCallback onPickupConfirm;

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
              onPressed: isProcessing ? null : onPickupConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBackground,
                disabledBackgroundColor: const Color(0xFFD8D8D8),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isProcessing ? '처리 중...' : '픽업 확인',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMessageState extends StatelessWidget {
  const _OrderMessageState({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF757575),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBackground,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatPrice(int price) {
  return price.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
}
