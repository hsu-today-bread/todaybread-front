import 'boss_parsing.dart';

class BossMonthlySalesResponse {
  const BossMonthlySalesResponse({
    required this.year,
    required this.month,
    required this.menuSummaries,
    required this.dailyTotals,
    required this.salesByDate,
    required this.declaredTotalQuantity,
    required this.declaredTotalAmount,
  });

  final int year;
  final int month;
  final List<BossSalesMenuSummary> menuSummaries;
  final List<BossSalesDailyTotal> dailyTotals;
  final Map<String, int> salesByDate;
  final int? declaredTotalQuantity;
  final int? declaredTotalAmount;

  int get totalQuantity =>
      declaredTotalQuantity ??
      menuSummaries.fold<int>(0, (sum, item) => sum + item.quantity);

  int get totalAmount =>
      declaredTotalAmount ??
      menuSummaries.fold<int>(0, (sum, item) => sum + item.amount);

  int amountFor(DateTime date) {
    return salesByDate[bossDateKey(date)] ?? 0;
  }

  bool hasSalesOn(DateTime date) => amountFor(date) > 0;

  factory BossMonthlySalesResponse.fromDynamic(
    dynamic data,
    DateTime requestedMonth,
  ) {
    final rawJson = bossAsMap(data);
    final body = rawJson == null
        ? null
        : bossAsMap(bossFirstValue(rawJson, ['data', 'result'])) ?? rawJson;
    final rawMenuSummaries = data is List
        ? data
        : bossFirstList(body ?? const <String, dynamic>{}, [
            'items',
            'menuSummaries',
            'menuSales',
            'sales',
            'rows',
            'summary',
            'content',
            'data',
          ]);
    final dailyTotals = _parseDailyTotals(body?['dailySales']);

    return BossMonthlySalesResponse(
      year: bossReadInt(body?['year'], fallback: requestedMonth.year),
      month: bossReadInt(body?['month'], fallback: requestedMonth.month),
      menuSummaries: aggregateBossSalesSummaries(
        _parseMenuSummaries(rawMenuSummaries),
      ),
      dailyTotals: dailyTotals,
      salesByDate: _buildSalesByDate(dailyTotals),
      declaredTotalQuantity: _readNullableInt(
        body == null
            ? null
            : bossFirstValue(body, [
                'totalQuantity',
                'sumQuantity',
                'quantity',
              ]),
      ),
      declaredTotalAmount: _readNullableInt(
        body == null
            ? null
            : bossFirstValue(body, [
                'totalSales',
                'totalAmount',
                'sumAmount',
                'amount',
                'salesAmount',
              ]),
      ),
    );
  }
}

class BossDailySalesResponse {
  const BossDailySalesResponse({
    required this.date,
    required this.menuSummaries,
    required this.declaredTotalQuantity,
    required this.declaredTotalAmount,
  });

  final DateTime date;
  final List<BossSalesMenuSummary> menuSummaries;
  final int? declaredTotalQuantity;
  final int? declaredTotalAmount;

  int get totalQuantity =>
      declaredTotalQuantity ??
      menuSummaries.fold<int>(0, (sum, item) => sum + item.quantity);

  int get totalAmount =>
      declaredTotalAmount ??
      menuSummaries.fold<int>(0, (sum, item) => sum + item.amount);

  factory BossDailySalesResponse.fromDynamic(dynamic data, DateTime request) {
    final rawJson = bossAsMap(data);
    final body = rawJson == null
        ? null
        : bossAsMap(bossFirstValue(rawJson, ['data', 'result'])) ?? rawJson;
    final rawMenuSummaries = data is List
        ? data
        : bossFirstList(body ?? const <String, dynamic>{}, [
            'menuSummaries',
            'menuSales',
            'sales',
            'rows',
            'summary',
            'items',
            'content',
            'data',
          ]);

    return BossDailySalesResponse(
      date:
          bossReadDate(
            body == null
                ? null
                : bossFirstValue(body, [
                    'date',
                    'dateString',
                    'salesDate',
                    'day',
                    'targetDate',
                  ]),
          ) ??
          bossNormalizeDate(request),
      menuSummaries: aggregateBossSalesSummaries(
        _parseMenuSummaries(rawMenuSummaries),
      ),
      declaredTotalQuantity: _readNullableInt(
        body == null
            ? null
            : bossFirstValue(body, [
                'totalQuantity',
                'sumQuantity',
                'quantity',
              ]),
      ),
      declaredTotalAmount: _readNullableInt(
        body == null
            ? null
            : bossFirstValue(body, [
                'totalSales',
                'totalAmount',
                'sumAmount',
                'amount',
                'salesAmount',
              ]),
      ),
    );
  }
}

class BossSalesMenuSummary {
  const BossSalesMenuSummary({
    required this.menuName,
    required this.quantity,
    required this.amount,
  });

  final String menuName;
  final int quantity;
  final int amount;

  factory BossSalesMenuSummary.fromJson(Map<String, dynamic> json) {
    final bread = bossAsMap(bossFirstValue(json, ['bread', 'menu', 'item']));
    final quantity = bossReadInt(
      bossFirstValue(json, [
        'totalQuantity',
        'quantity',
        'count',
        'salesCount',
        'qty',
      ]),
      fallback: 0,
    );
    final unitPrice = bossReadInt(
      bossFirstValue(json, ['unitPrice', 'salePrice', 'price', 'amount']) ??
          bread?['salePrice'],
      fallback: 0,
    );
    final totalSales = bossReadInt(
      bossFirstValue(json, [
        'totalSales',
        'totalAmount',
        'totalPrice',
        'salesAmount',
        'revenue',
        'amount',
      ]),
      fallback: unitPrice > 0 && quantity > 0 ? unitPrice * quantity : 0,
    );

    return BossSalesMenuSummary(
      menuName: bossReadString(
        bossFirstValue(json, [
              'menuName',
              'name',
              'breadName',
              'itemName',
              'bread_title',
            ]) ??
            bread?['name'],
      ),
      quantity: quantity,
      amount: totalSales,
    );
  }
}

class BossSalesDailyTotal {
  const BossSalesDailyTotal({
    required this.date,
    required this.dateKey,
    required this.totalAmount,
  });

  final DateTime date;
  final String dateKey;
  final int totalAmount;

  static BossSalesDailyTotal? fromMonthlyJson(Map<String, dynamic> json) {
    final rawDate = bossReadString(json['date']).trim();
    final parsedDate = bossReadDate(rawDate);
    if (rawDate.isEmpty || parsedDate == null) {
      return null;
    }

    return BossSalesDailyTotal(
      date: parsedDate,
      dateKey: rawDate,
      totalAmount: bossReadInt(json['totalSales']),
    );
  }
}

List<BossSalesMenuSummary> aggregateBossSalesSummaries(
  List<BossSalesMenuSummary> rows,
) {
  final summaryByMenu = <String, BossSalesMenuSummary>{};

  for (final item in rows) {
    final name = item.menuName.trim();
    if (name.isEmpty) {
      continue;
    }
    final existing = summaryByMenu[name];
    if (existing == null) {
      summaryByMenu[name] = item;
      continue;
    }
    summaryByMenu[name] = BossSalesMenuSummary(
      menuName: name,
      quantity: existing.quantity + item.quantity,
      amount: existing.amount + item.amount,
    );
  }

  final items = summaryByMenu.values.toList();
  items.sort((a, b) => b.amount.compareTo(a.amount));
  return items;
}

List<BossSalesMenuSummary> _parseMenuSummaries(dynamic value) {
  final list = value is List
      ? value
      : value == null
      ? const []
      : bossAsMap(value)?.values.toList() ?? const [];

  return list
      .map((item) => bossAsMap(item))
      .whereType<Map<String, dynamic>>()
      .map(BossSalesMenuSummary.fromJson)
      .where((item) => item.menuName.trim().isNotEmpty)
      .toList();
}

List<BossSalesDailyTotal> _parseDailyTotals(dynamic value) {
  if (value is! List) {
    return const [];
  }

  final rows = value
      .map((item) => bossAsMap(item))
      .whereType<Map<String, dynamic>>()
      .map(BossSalesDailyTotal.fromMonthlyJson)
      .whereType<BossSalesDailyTotal>()
      .toList();
  rows.sort((a, b) => a.date.compareTo(b.date));
  return rows;
}

Map<String, int> _buildSalesByDate(List<BossSalesDailyTotal> rows) {
  final result = <String, int>{};

  for (final row in rows) {
    result[row.dateKey] = row.totalAmount;
  }

  return result;
}

int? _readNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  return bossReadInt(value);
}
