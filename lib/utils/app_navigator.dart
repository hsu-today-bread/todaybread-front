import 'package:flutter/material.dart';

/// 앱 전역에서 Navigator를 참조할 수 있는 GlobalKey입니다.
/// FCM 알림 클릭처럼 위젯 컨텍스트 밖에서 화면 이동이 필요할 때 사용합니다.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
