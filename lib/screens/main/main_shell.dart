import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/providers/user/user_profile_provider.dart';
import 'package:todaybread/screens/boss/boss_dashboard_screen.dart';
import 'package:todaybread/screens/wish/wish_screen.dart';

import '../../widgets/main_bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../map/map_screen.dart';
import '../myPage/my_page_home_screen.dart';

/// 앱의 메인 탭 구조를 관리하는 셸 화면입니다.
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late final AnimationController _transitionController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<UserProfileProvider>().hydrateFromLocal(notify: true);
      context.read<AuthProvider>().refreshRoleFromStoredToken();
    });
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.03, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _transitionController,
            curve: Curves.easeOutCubic,
          ),
        );
    _transitionController.value = 1;
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    // IndexedStack은 유지해서 각 탭의 상태를 보존하고,
    // 보이는 화면만 짧게 fade + slide 시켜 가볍게 전환감을 줍니다.
    _transitionController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final pages = _pagesForRole(role);

    if (_selectedIndex >= pages.length) {
      _selectedIndex = pages.length - 1;
    }

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: IndexedStack(index: _selectedIndex, children: pages),
        ),
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        role: role,
      ),
    );
  }

  List<Widget> _pagesForRole(UserRole role) {
    if (role == UserRole.boss) {
      return const [
        HomeScreen(),
        MapScreen(),
        WishScreen(),
        BossDashboardScreen(),
        MyPageHomeScreen(),
      ];
    }

    return const [HomeScreen(), MapScreen(), WishScreen(), MyPageHomeScreen()];
  }
}
