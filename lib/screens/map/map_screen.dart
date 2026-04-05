import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../utils/app_colors.dart';
import '../../services/location/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  NCameraPosition? _initialPosition;

  @override
  void initState() {
    super.initState();
    _loadInitialPosition();
  }

  Future<void> _loadInitialPosition() async {
    final position = await determinePosition();
    setState(() {
      _initialPosition = NCameraPosition(
        target: NLatLng(position.latitude, position.longitude),
        zoom: 14,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        title: const Text(
          '내 주변 빵집',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _initialPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                NaverMap(
                  options: NaverMapViewOptions(
                    activeLayerGroups: [NLayerGroup.building],
                    initialCameraPosition: _initialPosition!,
                    mapType: NMapType.basic,
                    locationButtonEnable: true,
                  ),
                ),
                const _BottomSheet(),
              ],
            ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.08, // 핸들만 살짝 보이는 기본 상태
      minChildSize: 0.08,
      maxChildSize: 0.55, // 절반 조금 넘게 올라옴
      snap: true,
      snapSizes: const [0.08, 0.55],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // 드래그 핸들
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              // 가게 목록
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index.isOdd) return const Divider(height: 1);
                      return const _StoreCard();
                    },
                    childCount: 9, // TODO: 실제 데이터 연동 시 (items * 2 - 1)로 교체
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          // 가게 이미지
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Color(0xFFBBBBBB),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          // 가게 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      '가게 이름', // TODO: 실제 데이터 연동 시 교체
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                    SizedBox(width: 2),
                    Text(
                      '4.9',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '서울시 성북구 성북동', // TODO: 실제 데이터 연동 시 교체
                  style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 2),
                const Text(
                  '0.7km', // TODO: 실제 데이터 연동 시 교체
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFCCCCCC),
          ),
        ],
      ),
    );
  }
}
