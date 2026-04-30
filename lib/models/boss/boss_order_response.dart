import 'boss_parsing.dart';

class BossOrderPageResponse {
  const BossOrderPageResponse({
    required this.orders,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  final List<BossOrderResponse> orders;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;

  factory BossOrderPageResponse.fromDynamic(dynamic data) {
    if (data is List) {
      final orders = data
          .map((value) => bossAsMap(value))
          .whereType<Map<String, dynamic>>()
          .map(BossOrderResponse.fromJson)
          .toList();
      return BossOrderPageResponse(
        orders: orders,
        page: 0,
        size: orders.length,
        totalPages: 1,
        totalElements: orders.length,
      );
    }

    final json = bossAsMap(data) ?? const <String, dynamic>{};
    final body = bossAsMap(bossFirstValue(json, ['data', 'result'])) ?? json;
    final rawOrders = bossFirstList(body, [
      'content',
      'orders',
      'items',
      'results',
      'data',
    ]);
    final orders = rawOrders
        .map((value) => bossAsMap(value))
        .whereType<Map<String, dynamic>>()
        .map(BossOrderResponse.fromJson)
        .toList();

    return BossOrderPageResponse(
      orders: orders,
      page: bossReadInt(bossFirstValue(body, ['number', 'page']), fallback: 0),
      size: bossReadInt(
        bossFirstValue(body, ['size', 'pageSize']),
        fallback: orders.length,
      ),
      totalPages: bossReadInt(
        bossFirstValue(body, ['totalPages']),
        fallback: orders.isEmpty ? 0 : 1,
      ),
      totalElements: bossReadInt(
        bossFirstValue(body, ['totalElements', 'totalCount', 'count']),
        fallback: orders.length,
      ),
    );
  }
}

class BossOrderResponse {
  const BossOrderResponse({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentAmount,
    required this.items,
  });

  final int id;
  final String orderNumber;
  final String status;
  final int paymentAmount;
  final List<BossOrderLineItemResponse> items;

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  factory BossOrderResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = bossFirstList(json, [
      'items',
      'orderItems',
      'menus',
      'menuItems',
      'details',
      'orderDetails',
    ]);
    final items = rawItems
        .map((value) => bossAsMap(value))
        .whereType<Map<String, dynamic>>()
        .map(BossOrderLineItemResponse.fromJson)
        .toList();

    final orderId = bossReadInt(bossFirstValue(json, ['orderId', 'id']));
    final paymentAmount = bossReadInt(
      bossFirstValue(json, [
        'paymentAmount',
        'totalAmount',
        'amount',
        'paidAmount',
        'finalAmount',
      ]),
      fallback: items.fold<int>(0, (sum, item) => sum + item.amount),
    );

    return BossOrderResponse(
      id: orderId,
      orderNumber: bossReadString(
        bossFirstValue(json, ['orderNumber', 'orderNo', 'merchantUid']),
        fallback: orderId > 0 ? '$orderId' : '주문번호 없음',
      ),
      status: bossReadString(
        bossFirstValue(json, ['status']),
        fallback: 'CONFIRMED',
      ),
      paymentAmount: paymentAmount,
      items: items,
    );
  }
}

class BossOrderLineItemResponse {
  const BossOrderLineItemResponse({
    required this.name,
    required this.quantity,
    required this.amount,
  });

  final String name;
  final int quantity;
  final int amount;

  factory BossOrderLineItemResponse.fromJson(Map<String, dynamic> json) {
    final bread = bossAsMap(bossFirstValue(json, ['bread', 'menu', 'item']));
    return BossOrderLineItemResponse(
      name: bossReadString(
        bossFirstValue(json, ['name', 'menuName', 'breadName', 'itemName']) ??
            bread?['name'],
        fallback: '메뉴명 없음',
      ),
      quantity: bossReadInt(
        bossFirstValue(json, ['quantity', 'count', 'qty', 'totalQuantity']),
        fallback: 0,
      ),
      amount: bossReadInt(
        bossFirstValue(json, [
              'amount',
              'lineAmount',
              'totalAmount',
              'salesAmount',
            ]) ??
            bread?['salePrice'],
        fallback: 0,
      ),
    );
  }
}
