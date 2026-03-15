import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:flutter/services.dart';
import 'screens/home/home_screen.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async {
  // async 추가 + 아래 두 줄 추가
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
    clientId: 'jrxo5fi6nv',
    onAuthFailed: (e) => debugPrint('네이버 지도 인증 실패: $e'),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '오늘의 빵',
      theme: ThemeData(
        fontFamily: 'NoonnuBasicGothic',
      ),
      home: const HomeScreen(),
      //home: const SplashScreen(),
    );
  }

}