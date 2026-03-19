import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/screens/main/main_shell.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:todaybread/services/local/user_local_store.dart';


void main() async {
  // async 추가 + 아래 두 줄 추가
  WidgetsFlutterBinding.ensureInitialized();
  await UserLocalStore.init();
  await NaverMapSdk.instance.initialize(
    clientId: const String.fromEnvironment('NAVER_MAP_CLIENT_ID'),
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
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '오늘의 빵',
        theme: ThemeData(fontFamily: 'NoonnuBasicGothic'),
        //home: const MainShell(),
        home: const SplashScreen(),
      ),
    );
  }
}
