import 'package:flutter/material.dart';

/// 토스처럼 부드러운 화면 전환 빌더입니다.
///
/// 들어오는 화면은 오른쪽에서 살짝 밀려오며 서서히 나타나고(fade + slide),
/// 빠져나가는 화면은 살짝 왼쪽으로 밀리며 옅어집니다.
/// [ThemeData.pageTransitionsTheme]에 등록하면 앱의 모든 [MaterialPageRoute]에
/// 일괄 적용됩니다.
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 들어오는 화면: 오른쪽에서 6% 밀려오며 fade-in
    final Animation<Offset> slideIn =
        Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );

    final Animation<double> fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    // 빠져나가는(뒤로 밀리는) 화면: 왼쪽으로 4% 밀리며 살짝 어두워짐
    final Animation<Offset> slideOut =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.04, 0),
        ).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic),
        );

    final Animation<double> fadeOut = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut));

    return SlideTransition(
      position: slideOut,
      child: FadeTransition(
        opacity: fadeOut,
        child: SlideTransition(
          position: slideIn,
          child: FadeTransition(opacity: fadeIn, child: child),
        ),
      ),
    );
  }
}

/// 모든 플랫폼에 [SmoothPageTransitionsBuilder]를 적용한 테마 설정입니다.
const PageTransitionsTheme kSmoothPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: SmoothPageTransitionsBuilder(),
    TargetPlatform.iOS: SmoothPageTransitionsBuilder(),
  },
);
