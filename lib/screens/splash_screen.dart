import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/providers/user/user_profile_provider.dart';

import '../services/auth/auth_service.dart';
import '../utils/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/loading_lottie.dart';
import 'main/main_shell.dart';
import 'onboarding_screen.dart';
import '../services/fcm/fcm_service.dart';

///앱 실행 시 가장 먼저 보여지는 스플래시 뷰
///
/// 로고와 앱 이름을 2초 간 보여 준 후
/// 저장된 JWT 유무/만료 여부에 따라 홈 또는 온보딩으로 이동
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

  /// 2초 후 저장된 세션을 복구할 수 있는지 확인해서 진입 화면을 결정합니다.
  void _moveToNextScreen() {
    _navigationTimer = Timer(const Duration(seconds: 2), () async {
      debugPrint('[SplashScreen] checking stored session');
      final authProvider = context.read<AuthProvider>();
      final userProfileProvider = context.read<UserProfileProvider>();
      final hasValidSession = await AuthService.instance
          .restoreSessionIfPossible();
      if (hasValidSession) {
        await authProvider.refreshRoleFromStoredToken(notify: false);
        userProfileProvider.hydrateFromLocal();
        try {
          await FcmService.instance.registerTokenAfterLogin();
        } catch (e) {
          debugPrint('[SplashScreen] FCM token restore failed: $e');
        }
      } else {
        userProfileProvider.clearProfile();
      }
      debugPrint('[SplashScreen] hasValidSession=$hasValidSession');
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              hasValidSession ? const MainShell() : const OnboardingScreen(),
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
      backgroundColor: AppColors.white,
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
              const Text('오늘의 빵', style: AppTextStyles.splashTitle),
              const SizedBox(height: 8),

              //NOTE: 슬로건 변경할 예정
              const Text('오늘 하루 마무리를 빵으로', style: AppTextStyles.splashSubtitle),
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
