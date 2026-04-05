import 'package:todaybread/services/network/dio_client.dart';

class DisplayHelper {
  DisplayHelper._();

  static String? resolveImageUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '${DioClient.baseUrl}$value';
  }

  static String formatDistanceKm(double? distanceKm) {
    if (distanceKm == null) {
      return '미확인';
    }
    return '${distanceKm.toStringAsFixed(1)}km';
  }

  static String buildLastOrderRemainingTimeText({
    required bool isSelling,
    required String? lastOrderTime,
  }) {
    if (!isSelling) {
      return '영업 종료';
    }

    if (lastOrderTime == null || lastOrderTime.isEmpty) {
      return '오늘 마감';
    }

    final parts = lastOrderTime.split(':');
    if (parts.length < 2) {
      return lastOrderTime;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return lastOrderTime;
    }

    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, hour, minute);
    final difference = target.difference(now);
    if (difference.isNegative || difference.inMinutes <= 0) {
      return '곧 마감';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return '$hours시간 $minutes분';
    }
    if (hours > 0) {
      return '$hours시간';
    }
    return '$minutes분';
  }
}
