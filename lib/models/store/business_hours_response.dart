import 'package:todaybread/models/store/business_hours_request.dart';

class BusinessHoursResponse {
  final int dayOfWeek;
  final bool isClosed;
  final String? startTime;
  final String? endTime;
  final String? lastOrderTime;

  const BusinessHoursResponse({
    required this.dayOfWeek,
    required this.isClosed,
    required this.startTime,
    required this.endTime,
    required this.lastOrderTime,
  });

  factory BusinessHoursResponse.fromJson(Map<String, dynamic> json) {
    return BusinessHoursResponse(
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

  BusinessHoursRequest toRequest() {
    return BusinessHoursRequest(
      dayOfWeek: dayOfWeek,
      isClosed: isClosed,
      startTime: startTime,
      endTime: endTime,
      lastOrderTime: lastOrderTime,
    );
  }
}
