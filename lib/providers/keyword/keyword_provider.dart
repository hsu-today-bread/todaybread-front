import 'package:flutter/material.dart';
import 'package:todaybread/services/local/keyword_local_store.dart';

/// 키워드 관리 상태를 관리하는 Provider
class KeywordProvider extends ChangeNotifier {

  /// 등록된 키워드 리스트(wish_screen.dart에서 만드는게 아니라 여기서 생성)
  List<String> _keywords = [];

  List<String> get keywords => _keywords;

  /// 저장된 키워드를 로컬 DB에서 불러올 때 사용
  void loadKeywords() {
    _keywords = KeywordLocalStore.getKeywords();
    debugPrint('저장된 키워드: $_keywords'); // 앱 시작할 때 불러와서 확인 가능
    notifyListeners();
  }

  /// 키워드를 추가하고 로컬 DB에 저장
  Future<void> addKeyword(String keyword) async {
    if (_keywords.length >= 5) return;
    _keywords.add(keyword);
    await KeywordLocalStore.saveKeywords(_keywords);
    notifyListeners();
  }

  /// 키워드를 삭제하고 로컬 DB에 저장
  Future<void> removeKeyword(String keyword) async {
    _keywords.remove(keyword);
    await KeywordLocalStore.saveKeywords(_keywords);
    notifyListeners();
  }
}