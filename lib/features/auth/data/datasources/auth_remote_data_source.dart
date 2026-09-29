import '../../../../core/network/api_client.dart';
import '../../domain/entities/registration_details.dart';
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

  /// يُكمل بيانات حساب جديد (`users/edit`) بتوكنه، ويعيد المستخدم مكتملاً.
  Future<UserModel> completeProfile(RegistrationDetails details);

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

  /// قيم `gender` في الخادم.
  static const _genders = {Gender.female: 0, Gender.male: 1};

  /// قيم `know_about_app` في الخادم. لا يوجد «يوتيوب» هناك، فيُرسل كـ «غير ذلك».
  static const _sources = {
    AppSource.facebook: 1,
    AppSource.instagram: 2,
    AppSource.friend: 3,
    AppSource.school: 4,
    AppSource.youtube: 5,
    AppSource.other: 5,
  };

  @override
  Future<UserModel> completeProfile(RegistrationDetails details) async {
    final data = await _client.post(
      '/users/edit',
      fields: {
        'f_name': details.firstName,
        'l_name': details.lastName,
        'email': details.email,
        'school_id': details.schoolId,
        'branch_id': details.branchId,
        'gender': _genders[details.gender],
        'age': details.age,
        'know_about_app': _sources[details.source],
      },
    );
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _client.get('/auth/logout');
  }
}