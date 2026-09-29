import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

/// الجلسة على الجهاز: توكن الخادم، وآخر نسخة من المستخدم، ومعرّف الجهاز.
/// القراءة متزامنة لأن [ApiClient] يقرأ التوكن مع كل طلب.
abstract class AuthLocalDataSource {
  String? get token;
  UserModel? get cachedUser;

  /// معرّف ثابت لهذا التثبيت، يطلبه الخادم في `auth/active`.
  String get deviceId;

  Future<void> saveToken(String token);
  Future<void> saveUser(UserModel user);

  /// يمسح التوكن والمستخدم، ويُبقي معرّف الجهاز.
  Future<void> clear();
}

class SharedPrefsAuthLocalDataSource implements AuthLocalDataSource {
  SharedPrefsAuthLocalDataSource(this._prefs);

  static const _tokenKey = 'auth.token';
  static const _userKey = 'auth.user';
  static const _deviceIdKey = 'auth.device_id';

  final SharedPreferences _prefs;

  @override
  String? get token => _prefs.getString(_tokenKey);

  @override
  UserModel? get cachedUser {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // نسخة تالفة أو بصيغة قديمة: نعامل الجلسة كأنها غير موجودة.
      return null;
    }
  }

  @override
  String get deviceId {
    final saved = _prefs.getString(_deviceIdKey);
    if (saved != null) return saved;
    final random = Random.secure();
    final id = [
      for (var i = 0; i < 16; i++) random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
    // SharedPreferences يحدّث نسخته في الذاكرة فوراً، فلا حاجة لانتظار الكتابة.
    unawaited(_prefs.setString(_deviceIdKey, id));
    return id;
  }

  @override
  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token);

  @override
  Future<void> saveUser(UserModel user) => _prefs.setString(_userKey, jsonEncode(user.toJson()));

  @override
  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}