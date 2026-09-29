import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/auth_validators.dart';
import '../../domain/entities/registration_details.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

/// المصادقة عبر الخادم. الجلسة تُعدّ مفتوحة لحساب مكتمل فقط؛ الحساب الجديد
/// يُحفظ توكنه ويبقى في تدفق الدخول إلى أن يُكمل بياناته.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this._remote, required this._local});

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  User? get cachedUser => _local.cachedUser;

  @override
  Future<Either<Failure, void>> requestOtp({required String phone}) async {
    final error = AuthValidators.phone(phone);
    if (error != null) return Left(ValidationFailure(error));
    return guard(() => _remote.login(AuthValidators.normalizedPhone(phone)));
  }

  @override
  Future<Either<Failure, User?>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final error = AuthValidators.phone(phone) ?? AuthValidators.otp(otp);
    if (error != null) return Left(ValidationFailure(error));

    return guard<User?>(() async {
      final session = await _remote.activate(
        phone: AuthValidators.normalizedPhone(phone),
        code: otp.trim(),
        deviceId: _local.deviceId,
      );
      // التوكن يُحفظ دائماً لأن إكمال الحساب (users/edit) يحتاجه.
      await _local.saveToken(session.token);
      if (!session.user.isProfileComplete) return null;
      await _local.saveUser(session.user);
      return session.user;
    });
  }

  @override
  Future<Either<Failure, User>> register(RegistrationDetails details) async {
    // مؤقت: يُربط بـ users/edit في الجزء التالي مع قوائم المدارس والفروع.
    return const Left(ServerFailure('إكمال الحساب لم يُربط بالخادم بعد'));
  }

  @override
  Future<Either<Failure, User?>> currentUser() async => Right(_local.cachedUser);

  @override
  Future<Either<Failure, void>> logout() async {
    // فشل إبلاغ الخادم (انقطاع أو توكن منتهٍ) لا يمنع الخروج من الجهاز.
    await guard(_remote.logout);
    return guard(_local.clear);
  }
}