Map<String, dynamic>? bossAsMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

dynamic bossFirstValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key) && json[key] != null) {
      return json[key];
    }
  }
  return null;
}

List<dynamic> bossFirstList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value;
    }
  }
  return const [];
}

int bossReadInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    final normalized = value.replaceAll(',', '').trim();
    return int.tryParse(normalized) ??
        double.tryParse(normalized)?.toInt() ??
        fallback;
  }
  return fallback;
}

String bossReadString(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

DateTime? bossReadDate(dynamic value) {
  if (value is DateTime) {
    return DateTime(value.year, value.month, value.day);
  }
  if (value is String) {
    final parsed = DateTime.tryParse(value.trim());
    if (parsed != null) {
      return DateTime(parsed.year, parsed.month, parsed.day);
    }
  }
  if (value is int) {
    final milliseconds = value > 9999999999 ? value : value * 1000;
    final parsed = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
  if (value is num) {
    return bossReadDate(value.toInt());
  }
  final map = bossAsMap(value);
  if (map != null) {
    return bossReadDate(
      bossFirstValue(map, ['date', 'salesDate', 'day', 'targetDate']),
    );
  }
  return null;
}

DateTime bossNormalizeDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String bossMonthKey(DateTime value) {
  final normalized = DateTime(value.year, value.month);
  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}';
}

String bossDateKey(DateTime value) {
  final normalized = bossNormalizeDate(value);
  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}
