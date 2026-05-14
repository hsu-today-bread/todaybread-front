import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/firebase_options.dart';
import 'package:todaybread/services/fcm/fcm_service.dart';
import 'package:todaybread/providers/bread/bread_provider.dart';
import 'package:todaybread/providers/boss/boss_order_provider.dart';
import 'package:todaybread/providers/boss/boss_provider.dart';
import 'package:todaybread/providers/boss/boss_review_provider.dart';
import 'package:todaybread/providers/boss/boss_sales_provider.dart';
import 'package:todaybread/providers/interest_area/interest_area_provider.dart';
import 'package:todaybread/providers/keyword/keyword_provider.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/providers/main/main_tab_provider.dart';
import 'package:todaybread/providers/store/favourite_store_provider.dart';
import 'package:todaybread/providers/store/store_provider.dart';
import 'package:todaybread/providers/wishlist/wishlist_provider.dart';
import 'package:todaybread/providers/user/user_profile_provider.dart';
import 'package:todaybread/screens/splash_screen.dart';
import 'package:todaybread/services/local/notification_local_store.dart';
import 'package:todaybread/services/local/user_local_store.dart';
import 'package:todaybread/utils/app_navigator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('백그라운드 메시지 수신: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await UserLocalStore.init();
  await NotificationLocalStore.init();
  await FcmService.instance.init(); // onMessageTap은 MainShell에서 세팅
  final naverMapClientId = const String.fromEnvironment('NAVER_MAP_CLIENT_ID');
  await FlutterNaverMap().init(
    clientId: naverMapClientId,
    onAuthFailed: (e) => debugPrint('네이버 지도 인증 실패: $e'),
  );

  debugPrint(
    'Naver Map Client ID configured: ${naverMapClientId.trim().isNotEmpty}',
  );

  runApp(const TodayBreadApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}

class TodayBreadApp extends StatelessWidget {
  const TodayBreadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => BreadProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => BossProvider()),
        ChangeNotifierProvider(create: (_) => BossOrderProvider()),
        ChangeNotifierProvider(create: (_) => BossReviewProvider()),
        ChangeNotifierProvider(create: (_) => BossSalesProvider()),
        ChangeNotifierProvider(create: (_) => KeywordProvider()),
        ChangeNotifierProvider(create: (_) => FavouriteStoreProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => InterestAreaProvider()),
        ChangeNotifierProvider(create: (_) => MainTabProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '오늘의 빵',
        navigatorKey: navigatorKey,
        theme: ThemeData(fontFamily: 'PretendardVariable'),
        home: const SplashScreen(),
      ),
    );
  }
}
