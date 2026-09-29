import '../../../../core/network/api_client.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';

/// واجهات المصادقة على الخادم. ترمي استثناءات [ApiClient] عند الفشل.
abstract class AuthRemoteDataSource {
  /// يطلب إرسال رمز التحقق إلى الرقم (عبر واتساب).
  Future<void> login(String phone);

  /// يتحقق من الرمز ويعيد التوكن مع المستخدم، مكتملاً كان حسابه أم جديداً.
  Future<AuthSessionModel> activate({
    required String phone,
    required String code,
    required String deviceId,
  });

  Future<UserModel> getProfile();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  // المسارات تبدأ بـ "/" لأن Dio يلصقها بـ baseUrl كما هي دون أن يضيف فاصلاً.

  @override
  Future<void> login(String phone) async {
    await _client.post('/auth/login', fields: {'phone': phone});
  }

  @override
  Future<AuthSessionModel> activate({
    required String phone,
    required String code,
    required String deviceId,
  }) async {
    final data = await _client.post(
      '/auth/active',
      fields: {'phone': phone, 'verification_code': code, 'device_id': deviceId},
    );
    return AuthSessionModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getProfile() async {
    final data = await _client.get('/profile/get');
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _client.get('/auth/logout');
  }
}