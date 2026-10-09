import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class RequestOtp implements UseCase<void, String> {
  const RequestOtp(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.requestOtp(phone: params);
  }
}
