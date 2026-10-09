import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/profile_image.dart';
import '../../domain/entities/profile_update.dart';
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
    final error = Validators.phone(phone);
    if (error != null) return Left(ValidationFailure(error));
    return guard(() => _remote.login(Validators.normalizedPhone(phone)));
  }

  @override
  Future<Either<Failure, User?>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final error = Validators.phone(phone) ?? Validators.otp(otp);
    if (error != null) return Left(ValidationFailure(error));

    return guard<User?>(() async {
      final session = await _remote.activate(
        phone: Validators.normalizedPhone(phone),
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
    final error = Validators.notEmpty(details.firstName) ??
        Validators.notEmpty(details.lastName) ??
        Validators.email(details.email);
    if (error != null) return Left(ValidationFailure(error));

    return guard<User>(() async {
      // الطلب يُرسل بالتوكن المحفوظ في verifyOtp؛ بعد نجاحه تُفتح الجلسة.
      final user = await _remote.completeProfile(details);
      await _local.saveUser(user);
      return user;
    });
  }

  @override
  Future<Either<Failure, User?>> currentUser() async => Right(_local.cachedUser);

  @override
  Future<Either<Failure, User>> refreshProfile() {
    return guard<User>(() async {
      final token = _local.token;
      final user = await _remote.getProfile();
      // خرج المستخدم أو انتهت جلسته قبل وصول الرد: لا يُعاد حفظ مستخدم جلسة أُغلقت.
      if (_local.token == token) await _local.saveUser(user);
      return user;
    });
  }

  @override
  Future<Either<Failure, User>> updateProfile(ProfileUpdate update) async {
    final error = Validators.notEmpty(update.firstName) ?? Validators.notEmpty(update.lastName);
    if (error != null) return Left(ValidationFailure(error));

    return guard<User>(() async {
      final user = await _remote.updateProfile(update);
      await _local.saveUser(user);
      return user;
    });
  }

  @override
  Future<Either<Failure, User>> updateProfileImage(ProfileImage image) async {
    final contentType = image.contentType;
    if (contentType == null) return const Left(ValidationFailure(AppStrings.errorImageType));

    return guard<User>(() async {
      final user = await _remote.updateProfileImage(image, contentType);
      await _local.saveUser(user);
      return user;
    });
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // فشل إبلاغ الخادم (انقطاع أو توكن منتهٍ) لا يمنع الخروج من الجهاز.
    await guard(_remote.logout);
    return guard(_local.clear);
  }
}