import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/providers/main/main_tab_provider.dart';
import 'package:todaybread/providers/user/user_profile_provider.dart';
import 'package:todaybread/providers/boss/boss_sales_provider.dart';
import 'package:todaybread/screens/boss/boss_bread_management_screen.dart';
import 'package:todaybread/screens/boss/boss_order_history_screen.dart';
import 'package:todaybread/screens/boss/boss_sales_screen.dart';
import 'package:todaybread/providers/wishlist/wishlist_provider.dart';
import 'package:todaybread/screens/bread/bread_detail_screen.dart';
import 'package:todaybread/screens/store/store_detail_screen.dart';
import 'package:todaybread/screens/wish/wish_screen.dart';
import 'package:todaybread/services/fcm/fcm_service.dart';
import 'package:todaybread/utils/app_navigator.dart';

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
  late final MainTabProvider _mainTabProvider;
  int _lastHandledTabRequestId = 0;
  int _homeRefreshSignal = 0;
  int _myPageRefreshSignal = 0;

  static const int _homeTabIndex = 0;
  static const int _wishTabIndex = 2;
  static const int _bossSalesTabIndex = 2;
  static const int _myPageTabIndex = 3;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _mainTabProvider = context.read<MainTabProvider>();
    _mainTabProvider.addListener(_handleTabRequest);

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProfileProvider>().hydrateFromLocal(notify: true);
      context.read<AuthProvider>().refreshRoleFromStoredToken();

      // FCM 알림 탭 핸들러 등록
      FcmService.instance.onMessageTap = _handleNotificationTap;

      // 앱 종료 상태에서 알림 탭으로 열린 경우 처리
      FcmService.instance.checkInitialMessage();
    });
  }

  @override
  void dispose() {
    FcmService.instance.onMessageTap = null;
    _mainTabProvider.removeListener(_handleTabRequest);
    _transitionController.dispose();
    super.dispose();
  }

  /// FCM 알림 클릭 시 호출 — data의 type에 따라 화면 이동
  ///
  /// 백엔드 payload 타입:
  ///   ORDER_CREATED        — 사장님: 주문 내역 화면
  ///   KEYWORD_STOCK        — 유저: 빵 상세 우선, 없으면 가게 상세
  ///   FAVORITE_STORE_STOCK — 유저: 빵 상세 우선, 없으면 가게 상세
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    switch (type) {
      case 'ORDER_CREATED':
        // 사장님 주문 알림 → 주문 내역 화면
        nav.push(
          MaterialPageRoute(builder: (_) => const BossOrderHistoryScreen()),
        );

      case 'KEYWORD_STOCK':
      case 'FAVORITE_STORE_STOCK':
        // 유저 재고 알림 — breadId가 있으면 빵 상세 우선, 없으면 가게 상세
        final storeId = int.tryParse(data['storeId'] ?? '');
        final breadId = int.tryParse(data['breadId'] ?? '');
        if (storeId == null) {
          debugPrint('알림 payload에 storeId 없음: $data');
          return;
        }
        if (breadId != null) {
          nav.push(
            MaterialPageRoute(
              builder: (_) => BreadDetailScreen(
                breadId: breadId,
                storeId: storeId,
                fallbackToStoreOnLoadFailure: true,
              ),
            ),
          );
        } else {
          nav.push(
            MaterialPageRoute(
              builder: (_) => StoreDetailScreen(storeId: storeId),
            ),
          );
        }

      default:
        debugPrint('알 수 없는 알림 타입: $type / data: $data');
    }
  }

  void _handleTabRequest() {
    final requestId = _mainTabProvider.requestId;
    if (_lastHandledTabRequestId == requestId) return;
    _lastHandledTabRequestId = requestId;

    final requestedIndex = _mainTabProvider.requestedIndex;
    if (requestedIndex == null || !mounted) return;
    _selectTab(requestedIndex, forceRefresh: true);
  }

  void _onTap(int index) {
    _selectTab(index, forceRefresh: index == _myPageTabIndex);
  }

  void _selectTab(int index, {bool forceRefresh = false}) {
    final role = context.read<AuthProvider>().role;
    final pages = _pagesForRole(role);
    if (index < 0 || index >= pages.length) return;

    final isSameTab = _selectedIndex == index;
    final shouldRefreshMyPage =
        role == UserRole.user &&
        index == _myPageTabIndex &&
        (forceRefresh || !isSameTab);

    if (isSameTab && !shouldRefreshMyPage) return;

    setState(() {
      _selectedIndex = index;
      if (!isSameTab && role == UserRole.user && index == _homeTabIndex) {
        _homeRefreshSignal++;
      }
      if (shouldRefreshMyPage) {
        _myPageRefreshSignal++;
      }
    });
    if (!isSameTab && role == UserRole.user && index == _wishTabIndex) {
      context.read<WishlistProvider>().load();
    }
    if (!isSameTab && role == UserRole.boss && index == _bossSalesTabIndex) {
      final now = DateTime.now();
      context.read<BossSalesProvider>().fetchMonthlySales(
        DateTime(now.year, now.month),
        forceRefresh: true,
      );
    }
    // IndexedStack은 유지해서 각 탭의 상태를 보존하고,
    // 보이는 화면만 짧게 fade + slide 시켜 가볍게 전환감을 줍니다.
    if (!isSameTab) {
      _transitionController
        ..reset()
        ..forward();
    }
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
        BossOrderHistoryScreen(showAppBar: false),
        BossBreadManagementScreen(showAppBar: false),
        BossSalesScreen(showAppBar: false),
        MyPageHomeScreen(),
      ];
    }

    if (role == UserRole.unknown) {
      return [
        HomeScreen(refreshSignal: _homeRefreshSignal),
        const MapScreen(),
        const SizedBox.shrink(),
        const MyPageHomeScreen(),
      ];
    }

    return [
      HomeScreen(refreshSignal: _homeRefreshSignal),
      const MapScreen(),
      const WishScreen(),
      MyPageHomeScreen(orderRefreshSignal: _myPageRefreshSignal),
    ];
  }
}
