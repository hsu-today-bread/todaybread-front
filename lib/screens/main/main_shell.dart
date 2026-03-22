import 'package:flutter/material.dart';
import 'package:todaybread/screens/wish/wish_screen.dart';

import '../../widgets/main_bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../map/map_screen.dart';
import '../myPage/my_page_screen1.dart';

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

  late final List<Widget> _pages = [
    const HomeScreen(),
    const MapScreen(),
    const WishScreen(),
    const MyPageScreen1(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
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
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _BreadPlaceholderScreen extends StatelessWidget {
  const _BreadPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            '탭 화면 준비 중입니다.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6F6F6F),
            ),
          ),
        ),
      ),
    );
  }
}
