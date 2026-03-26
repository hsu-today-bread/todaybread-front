import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/store/store_provider.dart';
import 'package:todaybread/screens/boss/boss_store_create_screen.dart';
import 'package:todaybread/utils/app_colors.dart';

class BossScreen2 extends StatefulWidget {
  const BossScreen2({super.key});

  @override
  State<BossScreen2> createState() => _BossScreen2State();
}

class _BossScreen2State extends State<BossScreen2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StoreProvider>();
      // 매장 관리 진입 시 서버 기준으로 현재 사장님이 이미 매장을 등록했는지 조회한다.
      if (!provider.hasFetchedStatus) {
        provider.fetchStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (storeProvider.isLoading &&
                        !storeProvider.hasFetchedStatus) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (storeProvider.hasStore && storeProvider.store != null) {
                      // 등록된 매장이 있으면 empty 상태 대신 관리 탭 화면을 보여준다.
                      final store = storeProvider.store!;
                      return _StoreManagementView(store: store);
                    }

                    // 아직 등록된 매장이 없으면 로띠 + 등록 버튼 empty state를 보여준다.
                    return Column(
                      children: [
                        const Spacer(),
                        SizedBox(
                          width: 210,
                          height: 210,
                          child: Lottie.asset('assets/lottie/emptyStore.json'),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '등록된 매장이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BossStoreCreateScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBackground,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '매장 등록하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF4A3A3A),
                size: 26,
              ),
            ),
          ),
          const Center(
            child: Text(
              '매장 관리',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreManagementView extends StatelessWidget {
  final dynamic store;

  const _StoreManagementView({required this.store});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // 매장 관리 화면은 기본 정보 / 운영 정보 두 탭으로 나눠서 보여준다.
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4E4E4)),
            ),
            child: const TabBar(
              indicatorColor: AppColors.primaryBackground,
              labelColor: Colors.black,
              unselectedLabelColor: Color(0xFF8A8A8A),
              labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: '기본 정보'),
                Tab(text: '운영 정보'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _StoreBasicInfoTab(store: store),
                _StoreOperationInfoTab(store: store),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreBasicInfoTab extends StatelessWidget {
  final dynamic store;

  const _StoreBasicInfoTab({required this.store});

  @override
  Widget build(BuildContext context) {
    final isOpen = _isStoreOpen(store.endTime as String);

    return ListView(
      children: [
        _InfoSection(
          title: '로고',
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              size: 42,
              color: Color(0xFF7D7D7D),
            ),
          ),
        ),
        _InfoSection(
          title: '매장 위치',
          value: '${store.addressLine1}\n${store.addressLine2}',
        ),
        _InfoSection(title: '매장 이름', value: store.name as String),
        _InfoSection(title: '매장 전화번호', value: store.phone as String),
        _InfoSection(title: '영업 상태', value: isOpen ? '영업중' : '영업 종료'),
        _InfoSection(title: '매장 소개', value: store.description as String),
      ],
    );
  }

  bool _isStoreOpen(String endTime) {
    final now = TimeOfDay.now();
    final parts = endTime.split(':');
    if (parts.length < 2) {
      return false;
    }
    final end = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    if (now.hour < end.hour) {
      return true;
    }
    if (now.hour == end.hour && now.minute <= end.minute) {
      return true;
    }
    return false;
  }
}

class _StoreOperationInfoTab extends StatelessWidget {
  final dynamic store;

  const _StoreOperationInfoTab({required this.store});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoSection(title: '영업 시간', value: store.orderTime as String),
        _InfoSection(
          title: '운영 정보',
          value: '종료 ${store.endTime} / 라스트 오더 ${store.lastOrderTime}',
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String? value;
  final Widget? child;

  const _InfoSection({required this.title, this.value, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: 실제 수정 화면이 준비되면 각 항목별 상세 수정 화면으로 연결
                  // TODO: 각 항목별 수정 화면 연결
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF6F6F6F),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (child != null)
            child!
          else
            Text(
              value ?? '',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF5E5E5E),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class BossSubScreen extends StatelessWidget {
  final String title;

  const BossSubScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F7F7),
        foregroundColor: Colors.black,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Text(
          '$title 화면 준비 중입니다.',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6F6F6F),
          ),
        ),
      ),
    );
  }
}
