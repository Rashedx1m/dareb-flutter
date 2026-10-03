import '../../../../core/network/api_client.dart';
import '../../domain/entities/profile_image.dart';
import '../../domain/entities/profile_update.dart';
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

  /// يعدّل الاسم والمدرسة لحساب مكتمل (`users/update`).
  Future<UserModel> updateProfile(ProfileUpdate update);

  /// يرفع صورة الملف الشخصي (`users/update-image`) بنوعها [contentType].
  Future<UserModel> updateProfileImage(ProfileImage image, String contentType);

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
  }) {
    return _client.post(
      '/auth/active',
      fields: {'phone': phone, 'verification_code': code, 'device_id': deviceId},
      parse: (data) => AuthSessionModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<UserModel> getProfile() => _client.get('/profile/get', parse: _user);

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
  Future<UserModel> completeProfile(RegistrationDetails details) {
    return _client.post(
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
      parse: _user,
    );
  }

  @override
  Future<UserModel> updateProfile(ProfileUpdate update) {
    return _client.post(
      '/users/update',
      fields: {
        'f_name': update.firstName,
        'l_name': update.lastName,
        'school_id': update.schoolId,
      },
      parse: _user,
    );
  }

  @override
  Future<UserModel> updateProfileImage(ProfileImage image, String contentType) {
    return _client.upload(
      '/users/update-image',
      field: 'image',
      bytes: image.bytes,
      fileName: image.fileName,
      contentType: contentType,
      parse: _user,
    );
  }

  @override
  Future<void> logout() async {
    await _client.get('/auth/logout');
  }

  static UserModel _user(dynamic data) => UserModel.fromJson(data as Map<String, dynamic>);
}