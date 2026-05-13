import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todaybread/models/notification/app_notification.dart';

class NotificationLocalStore {
  static const String boxName = 'notification_box';
  static const int _maxItems = 100;

  static Future<void> init() async {
    await Hive.openBox(boxName);
  }

  static Box get _box => Hive.box(boxName);

  static List<AppNotification> getNotifications() {
    return _box.values
        .whereType<Map>()
        .map(AppNotification.fromJson)
        .where((notification) => notification.id.isNotEmpty)
        .toList()
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
  }

  static int unreadCount() {
    return getNotifications()
        .where((notification) => !notification.isRead)
        .length;
  }

  static Future<void> saveRemoteMessage(RemoteMessage message) async {
    final id = _messageId(message);
    final notification = AppNotification(
      id: id,
      title: message.notification?.title ?? _fallbackTitle(message.data),
      body: message.notification?.body ?? '',
      data: message.data.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      receivedAt: DateTime.now(),
      isRead: false,
    );

    await _box.put(id, notification.toJson());
    await _trim();
  }

  static Future<void> markRead(String id) async {
    final value = _box.get(id);
    if (value is! Map) {
      return;
    }
    final notification = AppNotification.fromJson(value).copyWith(isRead: true);
    await _box.put(id, notification.toJson());
  }

  static Future<void> delete(String id) async {
    await _box.delete(id);
  }

  static Future<void> clear() async {
    await _box.clear();
  }

  static Future<void> _trim() async {
    final notifications = getNotifications();
    if (notifications.length <= _maxItems) {
      return;
    }
    for (final notification in notifications.skip(_maxItems)) {
      await _box.delete(notification.id);
    }
  }

  static String _messageId(RemoteMessage message) {
    final messageId = message.messageId;
    if (messageId != null && messageId.isNotEmpty) {
      return messageId;
    }
    final data = message.data;
    return [
      data['type'],
      data['storeId'],
      data['breadId'],
      data['orderId'],
      message.sentTime?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    ].where((value) => value != null && value.toString().isNotEmpty).join('_');
  }

  static String _fallbackTitle(Map<String, dynamic> data) {
    return switch (data['type']?.toString()) {
      'KEYWORD_STOCK' => '찾던 빵이 등록됐어요',
      'FAVORITE_STORE_STOCK' => '단골 매장에 새 빵이 등록됐어요',
      'ORDER_CREATED' => '새 주문이 들어왔어요',
      _ => '오늘의 빵 알림',
    };
  }
}
