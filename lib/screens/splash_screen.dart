import 'dart:async';
import 'package:flutter/material.dart';

import '../utils/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/loading_lottie.dart';
import 'onboarding_screen.dart';

///앱 실행 시 가장 먼저 보여지는 스플래시 뷰
///
/// 로고와 앱 이름을 2초 간 보여 준 후 온보딩 화면으로 이동
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _moveToNextScreen();
  }

  /// 2초 후 온보디이 화면으로 이동하는 함수
  void _moveToNextScreen() {
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.splashLogo,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                '오늘의 빵',
                style: AppTextStyles.splashTitle,
              ),
              const SizedBox(height: 8),

              //NOTE: 슬로건 변경할 예정
              const Text(
                '오늘 하루 마무리를 빵으로',
                style: AppTextStyles.splashSubtitle,
              ),
              const SizedBox(height: 32),
              const LoadingLottie(
                assetPath: AppAssets.loadingLottie,
                width: 48,
                height: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
