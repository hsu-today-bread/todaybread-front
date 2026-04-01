import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/bread/bread_provider.dart';
import 'package:todaybread/providers/boss/boss_provider.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/providers/store/store_provider.dart';
import 'package:todaybread/providers/user/user_profile_provider.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:todaybread/screens/splash_screen.dart';
import 'package:todaybread/services/local/user_local_store.dart';
import 'package:todaybread/services/local/keyword_local_store.dart';
import 'package:todaybread/providers/keyword/keyword_provider.dart'; // 추가

void main() async {
  // async 추가 + 아래 두 줄 추가
  WidgetsFlutterBinding.ensureInitialized();
  await UserLocalStore.init();
  await KeywordLocalStore.init();
  await FlutterNaverMap().init(
    clientId: const String.fromEnvironment('NAVER_MAP_CLIENT_ID'),
    onAuthFailed: (e) => debugPrint('네이버 지도 인증 실패: $e'),
  );

  debugPrint(
    'Client ID 확인: ${const String.fromEnvironment('NAVER_MAP_CLIENT_ID')}',
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
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..refreshRoleFromStoredToken(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProfileProvider()..hydrateFromLocal(),
        ),
        ChangeNotifierProvider(create: (_) => BreadProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => BossProvider()),
        ChangeNotifierProvider(create: (_) => KeywordProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '오늘의 빵',
        theme: ThemeData(fontFamily: 'NoonnuBasicGothic'),
        home: const SplashScreen(),
        //home: const SplashScreen(),
      ),
    );
  }
}
