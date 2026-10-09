import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/registration_details.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Register implements UseCase<User, RegistrationDetails> {
  const Register(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(RegistrationDetails params) {
    return repository.register(params);
  }
}
