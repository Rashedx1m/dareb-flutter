import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/registration_details.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// يطلب إرسال رمز تحقق إلى رقم الهاتف. التطبيق لا يستخدم كلمات مرور،
  /// الدخول والتسجيل يتمّان عبر الهاتف ورمز التحقق فقط.
  Future<Either<Failure, void>> requestOtp({required String phone});

  /// يتحقق من الرمز ويعيد المستخدم إن كان الحساب مكتملاً مسبقاً،
  /// أو `null` إن لزم استكمال التسجيل لأول مرة.
  Future<Either<Failure, User?>> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<Either<Failure, User>> register(RegistrationDetails details);

  /// المستخدم الحالي، أو `null` إذا لم تُفتح جلسة بعد.
  Future<Either<Failure, User?>> currentUser();

  /// الجلسة المحمّلة محلياً دون انتظار. تُحدَّث مع كل حفظ أو خروج.
  User? get cachedUser;

  Future<Either<Failure, void>> logout();
}
