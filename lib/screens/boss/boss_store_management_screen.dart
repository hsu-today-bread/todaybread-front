import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_info_response.dart';
import 'package:todaybread/providers/store/store_provider.dart';
import 'package:todaybread/screens/boss/boss_store_edit_screen.dart';
import 'package:todaybread/screens/boss/boss_store_create_screen.dart';
import 'package:todaybread/services/network/dio_client.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/utils/business_hours_helper.dart';

/// 사장님 매장관리 메인 화면입니다.
///
/// 매장 존재 여부를 확인한 뒤 빈 상태, 등록 화면, 수정 진입 화면 중
/// 현재 상태에 맞는 화면을 보여줍니다.
class BossStoreManagementScreen extends StatefulWidget {
  const BossStoreManagementScreen({super.key});

  @override
  State<BossStoreManagementScreen> createState() =>
      _BossStoreManagementScreenState();
}

class _BossStoreManagementScreenState extends State<BossStoreManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StoreProvider>();
      // 매장 수정/이미지 교체 후에도 최신 상태를 보장하려고
      // 진입할 때마다 서버 기준으로 다시 조회한다.
      provider.fetchStatus();
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

                    if (storeProvider.storeInfo != null) {
                      return _StoreManagementView(
                        storeInfo: storeProvider.storeInfo!,
                      );
                    }

                    if (storeProvider.hasStore) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '매장 정보를 불러오지 못했습니다',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              storeProvider.errorMessage ?? '잠시 후 다시 시도해주세요.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6F6F6F),
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: storeProvider.fetchStatus,
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      );
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
  final StoreInfoResponse storeInfo;

  const _StoreManagementView({required this.storeInfo});

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
                _StoreBasicInfoTab(storeInfo: storeInfo),
                _StoreOperationInfoTab(store: storeInfo.store),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreBasicInfoTab extends StatelessWidget {
  final StoreInfoResponse storeInfo;

  const _StoreBasicInfoTab({required this.storeInfo});

  @override
  Widget build(BuildContext context) {
    final StoreCommonResponse store = storeInfo.store;
    final isOpen = isStoreOpenNow(store.businessHours);
    final primaryImageUrl = storeInfo.images.isEmpty
        ? null
        : _resolveImageUrl(storeInfo.images.first.imageUrl);

    return ListView(
      children: [
        _InfoSection(
          title: '매장 이미지',
          onEdit: () => _openEdit(context, StoreEditMode.image),
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(18),
              image: primaryImageUrl == null
                  ? null
                  : DecorationImage(
                      image: NetworkImage(primaryImageUrl),
                      fit: BoxFit.cover,
                    ),
            ),
            child: primaryImageUrl == null
                ? const Icon(
                    Icons.storefront_rounded,
                    size: 42,
                    color: Color(0xFF7D7D7D),
                  )
                : null,
          ),
        ),
        _InfoSection(
          title: '매장 위치',
          value: '${store.addressLine1}\n${store.addressLine2}',
          onEdit: () => _openEdit(context, StoreEditMode.location),
        ),
        _InfoSection(
          title: '매장 이름',
          value: store.name,
          onEdit: () => _openEdit(context, StoreEditMode.name),
        ),
        _InfoSection(
          title: '매장 전화번호',
          value: store.phone,
          onEdit: () => _openEdit(context, StoreEditMode.phone),
        ),
        _InfoSection(title: '영업 상태', value: isOpen ? '영업중' : '영업 종료'),
        _InfoSection(
          title: '매장 소개',
          value: store.description,
          onEdit: () => _openEdit(context, StoreEditMode.description),
        ),
      ],
    );
  }

  Future<void> _openEdit(BuildContext context, StoreEditMode mode) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BossStoreEditScreen(storeInfo: storeInfo, mode: mode),
      ),
    );
  }

  String _resolveImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return '${DioClient.baseUrl}$imageUrl';
  }
}

class _StoreOperationInfoTab extends StatelessWidget {
  final StoreCommonResponse store;

  const _StoreOperationInfoTab({required this.store});

  @override
  Widget build(BuildContext context) {
    final weeklySummary = store.businessHours
        .map(
          (value) =>
              '${weekdayLabel(value.dayOfWeek)}요일  ${buildBusinessHoursSummary(isClosed: value.isClosed, startTime: value.startTime, endTime: value.endTime, lastOrderTime: value.lastOrderTime)}',
        )
        .join('\n');

    return ListView(
      children: [
        _InfoSection(
          title: '오늘 영업시간',
          value: buildTodayBusinessHoursText(store.businessHours),
          onEdit: () => _openEdit(context),
        ),
        _InfoSection(
          title: '주간 영업시간',
          value: weeklySummary,
          onEdit: () => _openEdit(context),
        ),
      ],
    );
  }

  Future<void> _openEdit(BuildContext context) async {
    final storeInfo = context.read<StoreProvider>().storeInfo;
    if (storeInfo == null) {
      return;
    }
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BossStoreEditScreen(
          storeInfo: storeInfo,
          mode: StoreEditMode.operation,
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String? value;
  final Widget? child;
  final VoidCallback? onEdit;

  const _InfoSection({
    required this.title,
    this.value,
    this.child,
    this.onEdit,
  });

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
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
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
