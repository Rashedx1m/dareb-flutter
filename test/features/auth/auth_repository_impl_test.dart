import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/exceptions.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:educational_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:educational_app/features/auth/data/models/auth_session_model.dart';
import 'package:educational_app/features/auth/data/models/user_model.dart';
import 'package:educational_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:educational_app/features/auth/domain/entities/profile_update.dart';
import 'package:educational_app/features/auth/domain/entities/registration_details.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

final _complete = UserModel(id: '30', phone: '0930000000', firstName: 'Rashed', lastName: 'Eybo');
final _incomplete = UserModel(id: '30', phone: '0930000000');

const _details = RegistrationDetails(
  firstName: 'Rashed',
  lastName: 'Eybo',
  email: 'test@example.com',
  source: AppSource.facebook,
  schoolId: '7',
  gender: Gender.male,
  age: 37,
  branchId: '1',
);

/// خادم مزيّف: يسجّل الاستدعاءات، ويرمي [error] إن ضُبط.
class _FakeRemote implements AuthRemoteDataSource {
  AuthSessionModel? session;
  UserModel? profile;
  Exception? error;
  final calls = <String>[];

  /// يُنفَّذ أثناء طلب `profile/get`، لمحاكاة ما يحدث قبل وصول الرد.
  Future<void> Function()? whileFetchingProfile;

  @override
  Future<void> login(String phone) async {
    calls.add('login $phone');
    if (error != null) throw error!;
  }

  @override
  Future<AuthSessionModel> activate({
    required String phone,
    required String code,
    required String deviceId,
  }) async {
    calls.add('activate $phone $code $deviceId');
    if (error != null) throw error!;
    return session!;
  }

  @override
  Future<UserModel> getProfile() async {
    calls.add('getProfile');
    await whileFetchingProfile?.call();
    if (error != null) throw error!;
    return profile!;
  }

  @override
  Future<UserModel> completeProfile(RegistrationDetails details) async {
    calls.add('completeProfile ${details.firstName}');
    if (error != null) throw error!;
    return _complete;
  }

  @override
  Future<UserModel> updateProfile(ProfileUpdate update) async {
    calls.add('updateProfile ${update.firstName} ${update.lastName} ${update.schoolId}');
    if (error != null) throw error!;
    return profile!;
  }

  @override
  Future<void> logout() async {
    calls.add('logout');
    if (error != null) throw error!;
  }
}

class _MemoryLocal implements AuthLocalDataSource {
  @override
  String? token;

  @override
  UserModel? cachedUser;

  @override
  String get deviceId => 'dev-1';

  @override
  Future<void> saveToken(String token) async => this.token = token;

  @override
  Future<void> saveUser(UserModel user) async => cachedUser = user;

  @override
  Future<void> clear() async {
    token = null;
    cachedUser = null;
  }
}

void main() {
  late _FakeRemote remote;
  late _MemoryLocal local;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemote();
    local = _MemoryLocal();
    repository = AuthRepositoryImpl(remote: remote, local: local);
  });

  group('requestOtp', () {
    test('يرفض رقماً غير صالح دون الاتصال بالخادم', () async {
      final result = await repository.requestOtp(phone: '123');

      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<ValidationFailure>()), (_) => fail('توقعنا فشلاً'));
      expect(remote.calls, isEmpty);
    });

    test('يرسل الرقم بعد إزالة المسافات والشرطات', () async {
      final result = await repository.requestOtp(phone: '093 785-7596');

      expect(result.isRight(), isTrue);
      expect(remote.calls, ['login 0937857596']);
    });

    test('خطأ الخادم يصل Failure برسالته', () async {
      remote.error = const ServerException('تعذر الإرسال');

      expect(
        await repository.requestOtp(phone: '0930000000'),
        const Left<Failure, void>(ServerFailure('تعذر الإرسال')),
      );
    });
  });

  group('verifyOtp', () {
    test('يرفض رمزاً غير مكتمل دون الاتصال بالخادم', () async {
      final result = await repository.verifyOtp(phone: '0930000000', otp: '12');

      expect(result.isLeft(), isTrue);
      expect(remote.calls, isEmpty);
    });

    test('حساب مكتمل: يحفظ التوكن والمستخدم ويفتح الجلسة', () async {
      remote.session = AuthSessionModel(token: '30|abc', user: _complete);

      final result = await repository.verifyOtp(phone: '0930000000', otp: '1111');

      expect(result, Right<Failure, User?>(_complete));
      expect(remote.calls, ['activate 0930000000 1111 dev-1']);
      expect(local.token, '30|abc');
      expect(repository.cachedUser, _complete);
    });

    test('حساب جديد: يحفظ التوكن فقط ويعيد null لإكمال التسجيل', () async {
      remote.session = AuthSessionModel(token: '30|abc', user: _incomplete);

      final result = await repository.verifyOtp(phone: '0930000000', otp: '1111');

      expect(result, const Right<Failure, User?>(null));
      expect(local.token, '30|abc');
      expect(repository.cachedUser, isNull);
    });

    test('رمز خاطئ: يعيد رسالة الخادم ولا يحفظ شيئاً', () async {
      remote.error = const ServerException('الكود المدخل غير صحيح');

      final result = await repository.verifyOtp(phone: '0930000000', otp: '0000');

      expect(result, const Left<Failure, User?>(ServerFailure('الكود المدخل غير صحيح')));
      expect(local.token, isNull);
    });
  });

  group('register', () {
    test('يرفض اسماً فارغاً أو بريداً خاطئاً دون الاتصال بالخادم', () async {
      const noName = RegistrationDetails(
        firstName: ' ',
        lastName: 'Eybo',
        email: 'test@example.com',
        source: AppSource.other,
        schoolId: '7',
        gender: Gender.male,
        age: 37,
        branchId: '1',
      );

      expect((await repository.register(noName)).isLeft(), isTrue);
      expect(remote.calls, isEmpty);
    });

    test('يُكمل الحساب ويفتح الجلسة', () async {
      final result = await repository.register(_details);

      expect(result, Right<Failure, User>(_complete));
      expect(remote.calls, ['completeProfile Rashed']);
      expect(repository.cachedUser, _complete);
    });

    test('رفض الخادم (422) يصل برسالته ولا يفتح جلسة', () async {
      remote.error = const ValidationException('الحقل الجهات الدراسية مطلوب.');

      final result = await repository.register(_details);

      expect(result, const Left<Failure, User>(ValidationFailure('الحقل الجهات الدراسية مطلوب.')));
      expect(repository.cachedUser, isNull);
    });
  });

  group('refreshProfile', () {
    final updated = UserModel(
      id: '30',
      phone: '0930000000',
      firstName: 'Rashed',
      lastName: 'Eybo',
      points: 120,
      enrolledCoursesCount: 3,
    );

    setUp(() {
      local
        ..token = '30|abc'
        ..cachedUser = _complete;
      remote.profile = updated;
    });

    test('يجلب المستخدم من الخادم ويحدّث النسخة المحفوظة', () async {
      final result = await repository.refreshProfile();

      expect(result, Right<Failure, User>(updated));
      expect(remote.calls, ['getProfile']);
      expect(repository.cachedUser, updated);
    });

    test('فشل الخادم يصل Failure ويُبقي النسخة المحفوظة', () async {
      remote.error = const ServerException('تعذّر الاتصال بالخادم');

      final result = await repository.refreshProfile();

      expect(result, const Left<Failure, User>(ServerFailure('تعذّر الاتصال بالخادم')));
      expect(repository.cachedUser, _complete);
    });

    test('خروج قبل وصول الرد: لا يُعاد حفظ المستخدم', () async {
      remote.whileFetchingProfile = local.clear;

      await repository.refreshProfile();

      expect(repository.cachedUser, isNull);
    });
  });

  group('updateProfile', () {
    const update = ProfileUpdate(firstName: 'Rashid', lastName: 'Eybo', schoolId: '9');
    final renamed = UserModel(
      id: '30',
      phone: '0930000000',
      firstName: 'Rashid',
      lastName: 'Eybo',
      school: const School(id: '9', name: 'مدرسة الأمل', governorateId: 'aleppo'),
    );

    setUp(() {
      local
        ..token = '30|abc'
        ..cachedUser = _complete;
      remote.profile = renamed;
    });

    test('يرسل التعديل ويحفظ المستخدم الذي يعيده الخادم', () async {
      final result = await repository.updateProfile(update);

      expect(result, Right<Failure, User>(renamed));
      expect(remote.calls, ['updateProfile Rashid Eybo 9']);
      expect(repository.cachedUser, renamed);
    });

    test('يرفض اسماً فارغاً دون الاتصال بالخادم', () async {
      final result = await repository.updateProfile(
        const ProfileUpdate(firstName: 'Rashed', lastName: '  ', schoolId: '7'),
      );

      expect(result.isLeft(), isTrue);
      expect(remote.calls, isEmpty);
    });

    test('رفض الخادم (422) يصل برسالته ويُبقي النسخة المحفوظة', () async {
      remote.error = const ValidationException('الحقل الجهات الدراسية لاغٍ');

      final result = await repository.updateProfile(update);

      expect(result, const Left<Failure, User>(ValidationFailure('الحقل الجهات الدراسية لاغٍ')));
      expect(repository.cachedUser, _complete);
    });
  });

  group('logout', () {
    test('يبلغ الخادم ويمسح الجلسة', () async {
      local
        ..token = '30|abc'
        ..cachedUser = _complete;

      final result = await repository.logout();

      expect(result.isRight(), isTrue);
      expect(remote.calls, ['logout']);
      expect(local.token, isNull);
      expect(repository.cachedUser, isNull);
    });

    test('يمسح الجلسة حتى لو فشل الخادم', () async {
      local.token = '30|abc';
      remote.error = const AuthException();

      final result = await repository.logout();

      expect(result.isRight(), isTrue);
      expect(local.token, isNull);
    });
  });
}
