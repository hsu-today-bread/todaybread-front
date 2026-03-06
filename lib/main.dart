import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:flutter/services.dart';

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
      home: const SplashScreen(),
    );
  }

}