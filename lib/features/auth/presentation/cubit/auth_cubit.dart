import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/registration_details.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/request_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required RequestOtpUseCase requestOtpUseCase,
    required RegisterUseCase registerUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
  })  : _requestOtp = requestOtpUseCase,
        _register = registerUseCase,
        _verifyOtp = verifyOtpUseCase,
        super(const AuthState());

  final RequestOtpUseCase _requestOtp;
  final RegisterUseCase _register;
  final VerifyOtpUseCase _verifyOtp;

  Future<void> requestOtp(String phone) async {
    _emit(state.copyWith(status: AuthStatus.loading));
    final result = await _requestOtp(phone);
    _emit(
      result.fold(
        _failure,
        (_) => state.copyWith(status: AuthStatus.otpRequested),
      ),
    );
  }

  Future<void> verifyOtp({required String phone, required String otp}) async {
    _emit(state.copyWith(status: AuthStatus.loading));
    final result = await _verifyOtp(VerifyOtpParams(phone: phone, otp: otp));
    _emit(
      result.fold(
        _failure,
        (user) => user == null
            ? state.copyWith(status: AuthStatus.otpVerified)
            : state.copyWith(status: AuthStatus.authenticated, user: user),
      ),
    );
  }

  Future<void> register(RegistrationDetails details) async {
    _emit(state.copyWith(status: AuthStatus.loading));
    final result = await _register(details);
    _emit(
      result.fold(
        _failure,
        (user) => state.copyWith(status: AuthStatus.authenticated, user: user),
      ),
    );
  }

  AuthState _failure(Failure failure) =>
      state.copyWith(status: AuthStatus.failure, error: failure.message);

  /// الاستدعاءات غير متزامنة، وقد تُغلق الصفحة (ومعها الـ Cubit) قبل وصول
  /// النتيجة، فالحارس يمنع استثناء الإصدار بعد الإغلاق.
  void _emit(AuthState next) {
    if (isClosed) return;
    emit(next);
  }
}
