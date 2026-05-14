class BusinessHoursRequest {
  static const Object _unset = Object();

  final int dayOfWeek;
  final bool isClosed;
  final String? startTime;
  final String? endTime;
  final String? lastOrderTime;

  const BusinessHoursRequest({
    required this.dayOfWeek,
    required this.isClosed,
    required this.startTime,
    required this.endTime,
    required this.lastOrderTime,
  });

  factory BusinessHoursRequest.fromJson(Map<String, dynamic> json) {
    return BusinessHoursRequest(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      isClosed: json['isClosed'] as bool? ?? false,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      lastOrderTime: json['lastOrderTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'isClosed': isClosed,
      'startTime': startTime,
      'endTime': endTime,
      'lastOrderTime': lastOrderTime,
    };
  }

  BusinessHoursRequest copyWith({
    int? dayOfWeek,
    bool? isClosed,
    Object? startTime = _unset,
    Object? endTime = _unset,
    Object? lastOrderTime = _unset,
  }) {
    return BusinessHoursRequest(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isClosed: isClosed ?? this.isClosed,
      startTime: identical(startTime, _unset)
          ? this.startTime
          : startTime as String?,
      endTime: identical(endTime, _unset) ? this.endTime : endTime as String?,
      lastOrderTime: identical(lastOrderTime, _unset)
          ? this.lastOrderTime
          : lastOrderTime as String?,
    );
  }
}
