import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'تعذر قراءة البيانات المحلية']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'البيانات غير صحيحة']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'فشل تسجيل الدخول']);
}
