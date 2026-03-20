import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../utils/app_colors.dart';
import 'package:geolocator/geolocator.dart';

// 지도 화면
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}
/// 기기의 현재 위치를 가져오는 코드
///
/// 위치 권환을 허용하지 않으면 Future가 오류를 반환함
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // 위치 권환이 허용되지 않으면 더 진행되지 않음
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // 위치 권환을 허용하지 않았을 때, 나중에 한번 더 물어봄
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // 권환을 영원히 허용하지 않음을 선택시, 그에 맞게 처리
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // 위치 권환 허용 시, 현재 위치 반환
  return await Geolocator.getCurrentPosition();
}

class _MapScreenState extends State<MapScreen> {
  NaverMapController? _mapController;
  NCameraPosition? _initialPosition;

  @override
  void initState() {
    super.initState();
    _loadInitialPosition(); // ← 별도 함수 호출
  }

  Future<void> _loadInitialPosition() async {
    final position = await _determinePosition(); // 결과 기다렸다가 받기
    setState(() {
      _initialPosition = NCameraPosition( // _initialPosition에 저장!
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
          ? const Center(child: CircularProgressIndicator()) // 위치 가져오는 중
          : NaverMap(
              options: NaverMapViewOptions(
                // 보여줄 요소들( ex) building은 건물 )
                activeLayerGroups: [
                  NLayerGroup.building,
                ],
                // 초기 위치 잡는 코드, 한성대학교로 해놨음
                initialCameraPosition: _initialPosition!,
                // 지도 타입 설정(basic은 기본이고, 다른 모드도 가능)
                mapType: NMapType.basic,
                locationButtonEnable: true,
              ),
      ),
    );
  }
}
