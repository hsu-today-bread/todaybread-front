import 'package:geolocator/geolocator.dart';

/// 기기의 현재 위치를 가져온다.
///
/// 위치 서비스가 꺼져 있거나 권한이 없으면 Future.error를 반환한다.
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('위치 서비스가 비활성화되어 있습니다.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('위치 권한이 거부되었습니다.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('위치 권한이 영구적으로 거부되었습니다. 설정에서 직접 허용해주세요.');
  }

  return await Geolocator.getCurrentPosition();
}
