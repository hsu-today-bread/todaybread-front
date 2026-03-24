import 'package:flutter/material.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import '../../utils/app_colors.dart';

/// 앱 전역 하단 네비게이션바 위젯

class MainBottomNavBar extends StatelessWidget {
  /// 현재 선택된 탭 인덱스
  final int currentIndex;

  /// 탭 선택 콜백
  final ValueChanged<int> onTap;

  /// 현재 사용자 권한입니다.
  final UserRole role;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isBoss = role == UserRole.boss;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBackground,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.map_outlined),
          activeIcon: const Icon(Icons.map),
          label: '지도로 보기',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_border),
          activeIcon: const Icon(Icons.favorite),
          label: '빵',
        ),
        if (isBoss)
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: '사장님',
          ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'MY',
        ),
      ],
    );
  }
}
