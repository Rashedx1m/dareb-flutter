import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase implements UseCase<User?, VerifyOtpParams> {
  const VerifyOtpUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User?>> call(VerifyOtpParams params) {
    return repository.verifyOtp(phone: params.phone, otp: params.otp);
  }
}

class VerifyOtpParams extends Equatable {
  const VerifyOtpParams({required this.phone, required this.otp});
  final String phone;
  final String otp;

  @override
  List<Object?> get props => [phone, otp];
}
