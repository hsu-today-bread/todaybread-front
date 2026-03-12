import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:flutter/services.dart';
import 'screens/home/home_screen.dart';

void main() {
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
      // 로그인이 먼저 보이게 하고 싶은면 home: const SplashScreen(),이거 주석 해제하고
      // home: const HomeScreen(), 이거 주석처리하기.
      //home: const SplashScreen(),
      home: const SplashScreen(),
    );
  }

}