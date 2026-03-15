import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import '../../utils/app_colors.dart';
import '../home/home_screen.dart';

/// 지도로 보기 화면
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 현재 선택된 하단 네비게이션 인덱스 (지도 탭 = 1)
  int _selectedNavIndex = 1;

  NaverMapController? _mapController;

  // 더미 빵집 데이터 (나중에 서버 API로 교체 예정)
  final List<Map<String, dynamic>> _bakeries = [
    {'id': '1', 'name': '성심당', 'lat': 37.5665, 'lng': 126.9780},
    {'id': '2', 'name': '뚜레쥬르', 'lat': 37.5670, 'lng': 126.9790},
  ];

  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;
    setState(() => _selectedNavIndex = index);

    // 탭에 따라 화면 이동
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
    // 다른 탭은 해당 화면 완성 후 추가
  }

  // 지도 준비 완료 후 마커 추가
  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    _addBakeryMarkers();
  }

  // 빵집 위치에 마커 추가
  void _addBakeryMarkers() {
    for (final bakery in _bakeries) {
      final marker = NMarker(
        id: bakery['id'],
        position: NLatLng(bakery['lat'], bakery['lng']),
      );
      marker.setOnTapListener((overlay) {
        _showBakeryBottomSheet(bakery['name']);
      });
      _mapController?.addOverlay(marker);
    }
  }

  // 마커 탭 시 하단 시트 표시
  void _showBakeryBottomSheet(String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('마감 임박 상품이 있어요!',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
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
      body: NaverMap(
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(37.5665, 126.9780), // 서울 기본값, 추후 내 위치로 변경
            zoom: 14,
          ),
          locationButtonEnable: true, // 내 위치 버튼
        ),
        onMapReady: _onMapReady,
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _selectedNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}