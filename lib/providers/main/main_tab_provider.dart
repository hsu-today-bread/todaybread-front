import 'package:flutter/foundation.dart';

/// MainShell 밖의 화면에서 메인 탭 전환을 요청하기 위한 provider입니다.
class MainTabProvider extends ChangeNotifier {
  int? _requestedIndex;
  int _requestId = 0;

  int? get requestedIndex => _requestedIndex;
  int get requestId => _requestId;

  void requestTab(int index) {
    _requestedIndex = index;
    _requestId++;
    notifyListeners();
  }
}
