import 'boss_parsing.dart';

class BossMonthlySalesResponse {
  const BossMonthlySalesResponse({
    required this.year,
    required this.month,
    required this.menuSummaries,
    required this.dailyTotals,
    required this.declaredTotalQuantity,
    required this.declaredTotalAmount,
    required this.hasDailyBreakdown,
  });

  final int year;
  final int month;
  final List<BossSalesMenuSummary> menuSummaries;
  final List<BossSalesDailyTotal> dailyTotals;
  final int? declaredTotalQuantity;
  final int? declaredTotalAmount;
  final bool hasDailyBreakdown;

  int get totalQuantity =>
      declaredTotalQuantity ??
      menuSummaries.fold<int>(0, (sum, item) => sum + item.quantity);

  int get totalAmount =>
      declaredTotalAmount ??
      menuSummaries.fold<int>(0, (sum, item) => sum + item.amount);

  int amountFor(DateTime date) {
    final key = bossDateKey(date);
    for (final item in dailyTotals) {
      if (bossDateKey(item.date) == key) {
        return item.totalAmount;
      }
    }
    return 0;
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
            'menuSummaries',
            'menuSales',
            'sales',
            'rows',
            'summary',
            'items',
            'content',
            'data',
          ]);

    final rawDailySection = body == null
        ? null
        : bossFirstValue(body, [
            'dailyTotals',
            'dailySales',
            'dateSummaries',
            'days',
            'calendar',
            'salesByDate',
            'dailyAmounts',
          ]);

    return BossMonthlySalesResponse(
      year: bossReadInt(body?['year'], fallback: requestedMonth.year),
      month: bossReadInt(body?['month'], fallback: requestedMonth.month),
      menuSummaries: aggregateBossSalesSummaries(
        _parseMenuSummaries(rawMenuSummaries),
      ),
      dailyTotals: _parseDailyTotals(rawDailySection),
      declaredTotalQuantity: _readNullableInt(
        rawJson == null
            ? null
            : bossFirstValue(body!, [
                'totalQuantity',
                'sumQuantity',
                'quantity',
              ]),
      ),
      declaredTotalAmount: _readNullableInt(
        body == null
            ? null
            : bossFirstValue(body, [
                'totalAmount',
                'sumAmount',
                'amount',
                'salesAmount',
              ]),
      ),
      hasDailyBreakdown: rawDailySection != null,
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
    return BossSalesMenuSummary(
      menuName: bossReadString(
        bossFirstValue(json, ['menuName', 'name', 'breadName', 'itemName']) ??
            bread?['name'],
      ),
      quantity: bossReadInt(
        bossFirstValue(json, [
          'quantity',
          'count',
          'salesCount',
          'totalQuantity',
        ]),
        fallback: 0,
      ),
      amount: bossReadInt(
        bossFirstValue(json, [
          'amount',
          'salesAmount',
          'revenue',
          'totalAmount',
        ]),
        fallback: 0,
      ),
    );
  }
}

class BossSalesDailyTotal {
  const BossSalesDailyTotal({required this.date, required this.totalAmount});

  final DateTime date;
  final int totalAmount;

  factory BossSalesDailyTotal.fromJson(Map<String, dynamic> json) {
    final nestedSummaries = _parseMenuSummaries(
      bossFirstValue(json, [
        'menuSummaries',
        'menuSales',
        'sales',
        'rows',
        'summary',
        'items',
      ]),
    );

    return BossSalesDailyTotal(
      date:
          bossReadDate(
            bossFirstValue(json, ['date', 'salesDate', 'day', 'targetDate']),
          ) ??
          DateTime.now(),
      totalAmount: bossReadInt(
        bossFirstValue(json, [
          'totalAmount',
          'amount',
          'salesAmount',
          'revenue',
        ]),
        fallback: nestedSummaries.fold<int>(
          0,
          (sum, item) => sum + item.amount,
        ),
      ),
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
  if (value == null) {
    return const [];
  }

  if (value is List) {
    final rows = value
        .map((item) => bossAsMap(item))
        .whereType<Map<String, dynamic>>()
        .map(BossSalesDailyTotal.fromJson)
        .toList();
    rows.sort((a, b) => a.date.compareTo(b.date));
    return rows;
  }

  final map = bossAsMap(value);
  if (map == null) {
    return const [];
  }

  final rows = <BossSalesDailyTotal>[];
  for (final entry in map.entries) {
    final parsedDate = bossReadDate(entry.key);
    if (parsedDate != null) {
      final nestedMap = bossAsMap(entry.value);
      if (nestedMap != null) {
        rows.add(
          BossSalesDailyTotal.fromJson({
            'date': parsedDate.toIso8601String(),
            ...nestedMap,
          }),
        );
        continue;
      }
      rows.add(
        BossSalesDailyTotal(
          date: parsedDate,
          totalAmount: bossReadInt(entry.value, fallback: 0),
        ),
      );
      continue;
    }

    final nestedMap = bossAsMap(entry.value);
    if (nestedMap != null) {
      final row = BossSalesDailyTotal.fromJson(nestedMap);
      rows.add(row);
    }
  }

  rows.sort((a, b) => a.date.compareTo(b.date));
  return rows;
}

int? _readNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  return bossReadInt(value);
}
