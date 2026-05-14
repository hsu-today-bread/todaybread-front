import 'package:flutter/material.dart';
import 'package:todaybread/models/store/business_hours_response.dart';

const String defaultBusinessStartTime = '09:00:00';
const String defaultBusinessEndTime = '22:00:00';
const String defaultBusinessLastOrderTime = '21:30:00';

String weekdayLabel(int dayOfWeek) {
  const labels = ['월', '화', '수', '목', '금', '토', '일'];
  if (dayOfWeek < 1 || dayOfWeek > 7) {
    return '요일';
  }
  return labels[dayOfWeek - 1];
}

String formatBusinessTime(String? value, {String emptyText = '미설정'}) {
  if (value == null || value.isEmpty) {
    return emptyText;
  }
  final parts = value.split(':');
  if (parts.length < 2) {
    return value;
  }
  return '${parts[0]}:${parts[1]}';
}

TimeOfDay? parseBusinessTime(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final parts = value.split(':');
  if (parts.length < 2) {
    return null;
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }
  return TimeOfDay(hour: hour, minute: minute);
}

String timeOfDayToBusinessString(TimeOfDay value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute:00';
}

String buildBusinessHoursSummary({
  required bool isClosed,
  required String? startTime,
  required String? endTime,
  required String? lastOrderTime,
}) {
  if (isClosed) {
    return '휴무';
  }
  return '${formatBusinessTime(startTime)} - ${formatBusinessTime(endTime)} / 라스트오더 ${formatBusinessTime(lastOrderTime)}';
}

String? validateBusinessHoursValues({
  required bool isClosed,
  required String? startTime,
  required String? endTime,
  required String? lastOrderTime,
  String? label,
}) {
  if (isClosed) {
    return null;
  }

  final prefix = label == null ? '' : '$label ';
  if ((startTime ?? '').isEmpty ||
      (endTime ?? '').isEmpty ||
      (lastOrderTime ?? '').isEmpty) {
    return '$prefix영업시간을 모두 입력해주세요.';
  }

  final startMinutes = _timeToMinutes(startTime);
  final endMinutes = _timeToMinutes(endTime);
  final lastOrderMinutes = _timeToMinutes(lastOrderTime);
  if (startMinutes == null || endMinutes == null || lastOrderMinutes == null) {
    return '$prefix시간 형식이 올바르지 않습니다.';
  }

  if (startMinutes >= endMinutes) {
    return '$prefix시작 시간은 종료 시간보다 빨라야 합니다.';
  }

  if (lastOrderMinutes < startMinutes || lastOrderMinutes > endMinutes) {
    return '$prefix라스트오더는 시작 시간과 종료 시간 사이여야 합니다.';
  }

  return null;
}

bool isStoreOpenNow(
  List<BusinessHoursResponse> businessHours, {
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  BusinessHoursResponse? todayHours;
  for (final value in businessHours) {
    if (value.dayOfWeek == current.weekday) {
      todayHours = value;
      break;
    }
  }

  if (todayHours == null || todayHours.isClosed) {
    return false;
  }

  final startMinutes = _timeToMinutes(todayHours.startTime);
  final endMinutes = _timeToMinutes(todayHours.endTime);
  if (startMinutes == null || endMinutes == null) {
    return false;
  }

  final currentMinutes = current.hour * 60 + current.minute;
  return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
}

String buildTodayBusinessHoursText(
  List<BusinessHoursResponse> businessHours, {
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  for (final value in businessHours) {
    if (value.dayOfWeek == current.weekday) {
      return buildBusinessHoursSummary(
        isClosed: value.isClosed,
        startTime: value.startTime,
        endTime: value.endTime,
        lastOrderTime: value.lastOrderTime,
      );
    }
  }
  return '등록된 영업시간이 없습니다.';
}

int? _timeToMinutes(String? value) {
  final time = parseBusinessTime(value);
  if (time == null) {
    return null;
  }
  return time.hour * 60 + time.minute;
}
