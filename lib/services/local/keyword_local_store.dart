import 'package:hive_flutter/hive_flutter.dart';

class KeywordLocalStore {
  static const String boxName = 'keyword_box';

  // keyword_box를 열기 (main.dart의 UserLocalStore.init() 이후에 호출)
  static Future<void> init() async {
    await Hive.openBox(boxName);
  }

  static Box get _box => Hive.box(boxName);

  // 키워드 리스트 저장
  static Future<void> saveKeywords(List<String> keywords) async {
    await _box.put('keywords', keywords);
  }

  // 키워드 리스트 불러오기
  static List<String> getKeywords() {
    final data = _box.get('keywords', defaultValue: <String>[]);
    return List<String>.from(data);
  }

  // 키워드 전체 삭제
  static Future<void> clearKeywords() async {
    await _box.delete('keywords');
  }
}