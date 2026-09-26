part of 'auth_cubit.dart';

enum AuthStatus {
  initial,
  loading,

  /// تم إرسال رمز التحقق إلى الهاتف.
  otpRequested,

  /// تم التحقق من الرمز، وبقي استكمال بيانات الحساب.
  otpVerified,

  /// اكتمل إنشاء الحساب وفُتحت الجلسة.
  authenticated,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final User? user;
  final String? error;

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      // الخطأ لا يُورَّث بين الحالات: كل انتقال يصرّح برسالته أو يمسحها.
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, user, error];
}
