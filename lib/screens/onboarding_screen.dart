import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'login/login_screen1.dart';

///온보딩 화면
///
/// 오늘의 빵 시작하기 버튼을 눌러 로그인 화면으로 이동
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    ///상태바 스타일 설정
    ///
    /// - statusBarColor : 상태바 배경 색상
    /// - statusBarIconBrightness : 상태바 아이콘 색상
    /// - statusBarBrightness : iOS 상태바 밝기

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryBackground,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,

        /// 상단 AppBar
        ///
        /// - elevation : 그림자 제거
        /// - scrolledUnderElevation : 스크롤 시 그림자 제거
        /// - automaticallyImplyLeading : 뒤로가기 버튼 제거
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: ClipPath(
                    /// 커스텀 곡선 모양을 만들기 위한 클리퍼
                    clipper: TopCurveClipper(),
                    child: Container(
                      color: AppColors.primaryBackground,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),
                      const Text(
                        '오늘의 빵과 함께\n남김없는 한 끼를 시작해요',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 84),
                      Center(
                        child: Image.asset(
                          AppAssets.breadImage,
                          width: 330,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 72),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          /// 버튼 클릭 시 LoginScreen1 이동
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen1(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBackground,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '오늘의 빵 시작하기',
                            style: AppTextStyles.startButton,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 상단 곡선 배경을 만들기 위한 CustomClipper
///
/// ClipPath와 함께 사용되어 컨테이너를
/// 곡선 형태로 잘라내는 역할을 한다.
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    path.lineTo(0, size.height * 0.82);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.82,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
