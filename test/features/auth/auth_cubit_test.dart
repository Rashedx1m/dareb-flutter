import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/domain/entities/registration_details.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:educational_app/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:educational_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:educational_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = User(id: 'u1', name: 'أحمد المصري', phone: '0501234567');

const _details = RegistrationDetails(
  firstName: 'أحمد',
  lastName: 'المصري',
  email: 'ahmed@darb.app',
  source: AppSource.school,
  schoolId: '7',
  gender: Gender.male,
  age: 17,
  branchId: '1',
);

/// مستودع مزيّف يسمح بضبط النتيجة والتحكم بزمن وصولها.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.failure, this.delay = Duration.zero, this.existingUser});

  final Failure? failure;
  final Duration delay;
  final User? existingUser;

  @override
  Future<Either<Failure, void>> requestOtp({required String phone}) => _result(null);

  @override
  Future<Either<Failure, User?>> verifyOtp({required String phone, required String otp}) =>
      _result(existingUser);

  @override
  Future<Either<Failure, User>> register(RegistrationDetails details) => _result(_user);

  @override
  Future<Either<Failure, User?>> currentUser() async => Right(_user);

  @override
  User? get cachedUser => existingUser ?? _user;

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  Future<Either<Failure, T>> _result<T>(T value) async {
    await Future<void>.delayed(delay);
    final error = failure;
    return error != null ? Left(error) : Right(value);
  }
}

AuthCubit _cubit(_FakeAuthRepository repository) {
  return AuthCubit(
    requestOtpUseCase: RequestOtpUseCase(repository),
    registerUseCase: RegisterUseCase(repository),
    verifyOtpUseCase: VerifyOtpUseCase(repository),
  );
}

void main() {
  test('requestOtp ينتقل من التحميل إلى otpRequested', () async {
    final cubit = _cubit(_FakeAuthRepository());
    final states = <AuthStatus>[];
    final sub = cubit.stream.listen((s) => states.add(s.status));

    await cubit.requestOtp('0501234567');
    // البث غير متزامن، فنمنح حلقة الأحداث دورة قبل إلغاء الاشتراك.
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states, [AuthStatus.loading, AuthStatus.otpRequested]);
  });

  test('verifyOtp ينتقل إلى otpVerified', () async {
    final cubit = _cubit(_FakeAuthRepository());
    await cubit.verifyOtp(phone: '0501234567', otp: '1234');
    expect(cubit.state.status, AuthStatus.otpVerified);
  });

  test('verifyOtp يعيد الجلسة إن كان الحساب مكتملاً', () async {
    final cubit = _cubit(_FakeAuthRepository(existingUser: _user));
    await cubit.verifyOtp(phone: '0501234567', otp: '1234');
    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user, _user);
  });

  test('register يحفظ المستخدم في الحالة', () async {
    final cubit = _cubit(_FakeAuthRepository());
    await cubit.register(_details);

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user, _user);
  });

  test('الفشل يحمل رسالة الخطأ', () async {
    final cubit = _cubit(_FakeAuthRepository(failure: const ValidationFailure('رقم الهاتف غير صحيح')));
    await cubit.requestOtp('123');

    expect(cubit.state.status, AuthStatus.failure);
    expect(cubit.state.error, 'رقم الهاتف غير صحيح');
  });

  test('رسالة الخطأ لا تبقى عالقة بعد محاولة ناجحة', () async {
    final cubit = _cubit(_FakeAuthRepository());
    // نبدأ من حالة فشل سابقة.
    final failing = _cubit(_FakeAuthRepository(failure: const ValidationFailure('خطأ')));
    await failing.requestOtp('123');
    expect(failing.state.error, isNotNull);

    await cubit.requestOtp('0501234567');
    expect(cubit.state.error, isNull);
  });

  test('لا يرمي استثناءً إذا أُغلق الـ Cubit قبل وصول النتيجة', () async {
    final cubit = _cubit(_FakeAuthRepository(delay: const Duration(milliseconds: 50)));

    final pending = cubit.requestOtp('0501234567');
    await cubit.close();

    await expectLater(pending, completes);
  });
}
