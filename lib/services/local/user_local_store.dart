import 'package:hive_flutter/hive_flutter.dart';

class UserLocalStore {
  static const String boxName = 'user_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Box get _box => Hive.box(boxName);

  static Future<void> saveUser({
    required String nickname,
    required String name,
    required String phone,
  }) async {
    await _box.put('nickname', nickname);
    await _box.put('name', name);
    await _box.put('phone', phone);
  }

  static String getNickname() => _box.get('nickname', defaultValue: '');
  static String getName() => _box.get('name', defaultValue: '');
  static String getPhone() => _box.get('phone', defaultValue: '');

  static Future<void> clearUser() async {
    await _box.delete('nickname');
    await _box.delete('name');
    await _box.delete('phone');
  }

}