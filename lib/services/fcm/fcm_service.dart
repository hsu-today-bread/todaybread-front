import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todaybread/services/network/dio_client.dart';

/// FCM Token 발급, 서버 전송, 알림 수신 처리를 담당하는 서비스입니다.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// 알림 클릭 시 화면 이동을 위한 콜백 — MainShell에서 세팅합니다.
  void Function(RemoteMessage)? onMessageTap;

  /// 포그라운드 알림 탭을 위해 수신된 메시지를 임시 저장합니다 (알림 ID → 메시지).
  final Map<int, RemoteMessage> _pendingMessages = {};

  /// 앱 시작 시 한 번 호출합니다. onTap은 MainShell 마운트 후 별도로 세팅합니다.
  Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    _listenForegroundMessages();
    _listenNotificationTap();
  }

  /// 알림 권한 요청
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('알림 권한: ${settings.authorizationStatus}');
  }

  /// Foreground 알림 표시를 위한 local notification 초기화
  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // 포그라운드 알림 배너를 탭했을 때 — payload에 저장해둔 알림 ID로 메시지 복원
        final idStr = details.payload;
        if (idStr == null) return;
        final id = int.tryParse(idStr);
        if (id == null) return;
        final message = _pendingMessages.remove(id);
        if (message == null) return;
        debugPrint('포그라운드 알림 탭: ${message.data}');
        onMessageTap?.call(message);
      },
    );

    // Android 알림 채널 생성
    const channel = AndroidNotificationChannel(
      'todaybread_channel',
      '오늘의 빵 알림',
      description: '키워드, 단골 매장, 주문 관련 알림',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Foreground 상태에서 메시지 수신 시 local notification으로 표시
  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground 메시지 수신: ${message.messageId}');
      _showLocalNotification(message);
    });
  }

  /// Background 상태에서 알림 클릭 감지
  void _listenNotificationTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('알림 클릭 (background): ${message.data}');
      onMessageTap?.call(message);
    });
  }

  /// 앱 종료 상태에서 알림 클릭으로 앱이 열린 경우 처리
  Future<void> checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      debugPrint('알림 클릭 (terminated): ${message.data}');
      onMessageTap?.call(message);
    }
  }

  /// Foreground 알림을 local notification으로 표시하고 메시지를 임시 저장
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final id = notification.hashCode;
    _pendingMessages[id] = message;

    const androidDetails = AndroidNotificationDetails(
      'todaybread_channel',
      '오늘의 빵 알림',
      channelDescription: '키워드, 단골 매장, 주문 관련 알림',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      notification.title,
      notification.body,
      details,
      payload: id.toString(), // 탭 시 메시지 복원에 사용
    );
  }

  /// 알림 끄기 — 서버에서 현재 유저의 FCM token 비활성화
  Future<void> disableToken() async {
    try {
      await DioClient.instance.delete('/api/fcm-tokens');
      debugPrint('FCM Token 비활성화 성공');
    } catch (e) {
      debugPrint('FCM Token 비활성화 실패: $e');
      rethrow;
    }
  }

  /// 로그인 완료 후 호출 — Token 발급 및 서버 등록, 갱신 감지 시작
  Future<void> registerTokenAfterLogin() async {
    final token = await _messaging.getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
      await _sendTokenToServer(token);
    }
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token 갱신: $newToken');
      _sendTokenToServer(newToken);
    });
  }

  /// FCM Token을 서버 POST /api/fcm-tokens 로 전송
  Future<void> _sendTokenToServer(String token) async {
    try {
      final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
      await DioClient.instance.post(
        '/api/fcm-tokens',
        data: {'token': token, 'platform': platform},
      );
      debugPrint('FCM Token 서버 등록 성공');
    } catch (e) {
      debugPrint('FCM Token 서버 등록 실패: $e');
    }
  }
}
