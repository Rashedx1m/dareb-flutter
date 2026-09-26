import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/storage/session_storage.dart';
import 'package:educational_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:educational_app/features/auth/domain/entities/registration_details.dart';
import 'package:flutter_test/flutter_test.dart';

const _details = RegistrationDetails(
  firstName: 'أحمد',
  lastName: 'المصري',
  email: 'ahmed@darb.app',
  phone: '0501234567',
  school: 'مدرسة حكومية',
  source: 'المدرسة',
  schoolKind: 'مدرسة',
  gender: 'ذكر',
  age: 17,
  track: 'بكالوريا علمي',
);

void main() {
  late MemorySessionStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    storage = MemorySessionStorage();
    repository = AuthRepositoryImpl(storage);
  });

  group('requestOtp', () {
    test('يرفض رقماً فارغاً', () async {
      final result = await repository.requestOtp(phone: '  ');
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<ValidationFailure>()), (_) => fail('توقعنا فشلاً'));
    });

    test('يرفض رقماً قصيراً أو يحوي حروفاً', () async {
      expect((await repository.requestOtp(phone: '123')).isLeft(), isTrue);
      expect((await repository.requestOtp(phone: '05012abcd')).isLeft(), isTrue);
    });

    test('يقبل رقماً صحيحاً مع مسافات وشرطات', () async {
      final result = await repository.requestOtp(phone: '050 123-4567');
      expect(result.isRight(), isTrue);
    });
  });

  group('verifyOtp', () {
    test('يرفض رمزاً غير مكتمل', () async {
      final result = await repository.verifyOtp(phone: '0501234567', otp: '12');
      expect(result.isLeft(), isTrue);
    });

    test('يرفض رمزاً غير رقمي', () async {
      final result = await repository.verifyOtp(phone: '0501234567', otp: 'ab12');
      expect(result.isLeft(), isTrue);
    });

    test('يقبل رمزاً من أربعة أرقام', () async {
      final result = await repository.verifyOtp(phone: '0501234567', otp: '1234');
      expect(result.isRight(), isTrue);
    });
  });

  group('register', () {
    test('يرفض بريداً إلكترونياً غير صالح', () async {
      final result = await repository.register(
        const RegistrationDetails(
          firstName: 'أحمد',
          lastName: 'المصري',
          email: 'ahmed-at-darb',
          phone: '0501234567',
          school: 'مدرسة حكومية',
          source: 'المدرسة',
          schoolKind: 'مدرسة',
          gender: 'ذكر',
          age: 17,
          track: 'بكالوريا علمي',
        ),
      );
      expect(result.isLeft(), isTrue);
    });

    test('يبني المستخدم من الاسم الأول والكنية', () async {
      final result = await repository.register(_details);
      final user = result.getOrElse(() => throw StateError('توقعنا نجاحاً'));
      expect(user.name, 'أحمد المصري');
      expect(user.phone, '0501234567');
      expect(user.email, 'ahmed@darb.app');
    });
  });

  group('الجلسة', () {
    test('تبدأ فارغة قبل التسجيل', () async {
      final result = await repository.currentUser();
      expect(result.getOrElse(() => throw StateError('خطأ')), isNull);
    });

    test('تُفتح بعد التسجيل وتُغلق بعد الخروج', () async {
      await repository.register(_details);
      expect((await repository.currentUser()).getOrElse(() => null), isNotNull);

      await repository.logout();
      expect((await repository.currentUser()).getOrElse(() => null), isNull);
    });

    test('تبقى محفوظة بعد إنشاء مستودع جديد على نفس التخزين', () async {
      await repository.register(_details);

      final restored = AuthRepositoryImpl(storage);
      final user = (await restored.currentUser()).getOrElse(() => null);
      expect(user?.name, 'أحمد المصري');
      expect(user?.phone, '0501234567');
    });

    test('الدخول برقم مسجّل يعيد الجلسة دون إعادة التسجيل', () async {
      await repository.register(_details);
      await repository.logout();

      final result = await repository.verifyOtp(phone: '050 123-4567', otp: '1234');
      final user = result.getOrElse(() => null);
      expect(user?.name, 'أحمد المصري');
      expect((await repository.currentUser()).getOrElse(() => null), isNotNull);
    });

    test('رمز التحقق لحساب جديد لا يفتح جلسة', () async {
      final result = await repository.verifyOtp(phone: '0501234567', otp: '1234');
      expect(result.getOrElse(() => throw StateError('توقعنا نجاحاً')), isNull);
      expect((await repository.currentUser()).getOrElse(() => null), isNull);
    });
  });
}
