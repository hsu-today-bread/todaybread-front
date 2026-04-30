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
    final items = isBoss
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: '주문내역',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: '메뉴관리',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: '매출관리',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'MY',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: '지도로 보기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: '빵',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'MY',
            ),
          ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBackground,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: items,
    );
  }
}
