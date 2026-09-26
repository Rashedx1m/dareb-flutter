import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/auth_validators.dart';
import '../../features/auth/domain/entities/user.dart';

/// تخزين محلي لجلسة المستخدم والحسابات المكتملة، حتى لا تُعاد عملية
/// التسجيل عند إعادة فتح التطبيق.
abstract class SessionStorage {
  /// الجلسة الحالية إن وُجدت، بلا انتظار.
  User? get cachedSession;

  Future<User?> readSession();

  Future<void> writeSession(User user);

  Future<void> clearSession();

  Future<User?> findUserByPhone(String phone);

  Future<void> saveUser(User user);
}

/// تنفيذ في الذاكرة للاختبارات أو التشغيل دون تفضيلات محفوظة.
class MemorySessionStorage implements SessionStorage {
  User? _session;
  final Map<String, User> _users = {};

  @override
  User? get cachedSession => _session;

  @override
  Future<User?> readSession() async => _session;

  @override
  Future<void> writeSession(User user) async => _session = user;

  @override
  Future<void> clearSession() async => _session = null;

  @override
  Future<User?> findUserByPhone(String phone) async =>
      _users[AuthValidators.normalizedPhone(phone)];

  @override
  Future<void> saveUser(User user) async =>
      _users[AuthValidators.normalizedPhone(user.phone)] = user;
}

class SharedPreferencesSessionStorage implements SessionStorage {
  SharedPreferencesSessionStorage(this._prefs)
      : _session = _decodeUser(_prefs.getString(_sessionKey));

  static const _sessionKey = 'auth.session';
  static const _usersKey = 'auth.registered_users';

  final SharedPreferences _prefs;
  User? _session;

  @override
  User? get cachedSession => _session;

  @override
  Future<User?> readSession() async => _session;

  @override
  Future<void> writeSession(User user) async {
    _session = user;
    await _prefs.setString(_sessionKey, jsonEncode(_userToJson(user)));
  }

  @override
  Future<void> clearSession() async {
    _session = null;
    await _prefs.remove(_sessionKey);
  }

  @override
  Future<User?> findUserByPhone(String phone) async {
    final target = AuthValidators.normalizedPhone(phone);
    for (final user in _readUsers()) {
      if (AuthValidators.normalizedPhone(user.phone) == target) return user;
    }
    return null;
  }

  @override
  Future<void> saveUser(User user) async {
    final users = _readUsers();
    final phone = AuthValidators.normalizedPhone(user.phone);
    users.removeWhere((item) => AuthValidators.normalizedPhone(item.phone) == phone);
    users.add(user);
    await _prefs.setString(
      _usersKey,
      jsonEncode([for (final item in users) _userToJson(item)]),
    );
  }

  List<User> _readUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    final users = <User>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final user = _userFromJson(item.cast<String, dynamic>());
      if (user != null) users.add(user);
    }
    return users;
  }

  static User? _decodeUser(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return _userFromJson(decoded.cast<String, dynamic>());
  }
}

Map<String, Object?> _userToJson(User user) => {
      'id': user.id,
      'name': user.name,
      'phone': user.phone,
      'email': user.email,
      'avatarUrl': user.avatarUrl,
      'progress': user.progress,
      'points': user.points,
      'enrolledCoursesCount': user.enrolledCoursesCount,
    };

User? _userFromJson(Map<String, dynamic> json) {
  final id = json['id'];
  final name = json['name'];
  final phone = json['phone'];
  if (id is! String || name is! String || phone is! String) return null;
  return User(
    id: id,
    name: name,
    phone: phone,
    email: json['email'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    progress: (json['progress'] as num?)?.toDouble() ?? 0,
    points: (json['points'] as num?)?.toInt() ?? 0,
    enrolledCoursesCount: (json['enrolledCoursesCount'] as num?)?.toInt() ?? 0,
  );
}
