import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/auth_validators.dart';
import '../../domain/entities/registration_details.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// تنفيذ مؤقت يحاكي الخادم بتأخير بسيط، إلى أن تُربط واجهات الـ API الحقيقية.
/// الجلسة والحسابات المكتملة تُحفظ محلياً حتى لا تُعاد عملية التسجيل.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._storage) : _session = _storage.cachedSession;

  static const _networkDelay = Duration(milliseconds: 500);

  final SessionStorage _storage;
  User? _session;

  @override
  User? get cachedUser => _session;

  @override
  Future<Either<Failure, void>> requestOtp({required String phone}) async {
    final error = AuthValidators.phone(phone);
    if (error != null) return Left(ValidationFailure(error));

    await Future<void>.delayed(_networkDelay);
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final phoneError = AuthValidators.phone(phone);
    if (phoneError != null) return Left(ValidationFailure(phoneError));
    final otpError = AuthValidators.otp(otp);
    if (otpError != null) return Left(ValidationFailure(otpError));

    await Future<void>.delayed(_networkDelay);
    try {
      final existing = await _storage.findUserByPhone(phone);
      if (existing != null) {
        _session = existing;
        await _storage.writeSession(existing);
      }
      return Right(existing);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> register(RegistrationDetails details) async {
    final error = AuthValidators.name(details.firstName) ??
        AuthValidators.name(details.lastName) ??
        AuthValidators.email(details.email) ??
        AuthValidators.phone(details.phone);
    if (error != null) return Left(ValidationFailure(error));

    await Future<void>.delayed(_networkDelay);
    final user = User(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      name: details.fullName,
      phone: AuthValidators.normalizedPhone(details.phone),
      email: details.email.trim(),
    );
    try {
      await _persist(user);
      return Right(user);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User?>> currentUser() async => Right(_session);

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      _session = null;
      await _storage.clearSession();
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  Future<void> _persist(User user) async {
    _session = user;
    await _storage.saveUser(user);
    await _storage.writeSession(user);
  }
}
