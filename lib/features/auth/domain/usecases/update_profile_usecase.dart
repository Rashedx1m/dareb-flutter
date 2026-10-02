import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile_update.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<User, ProfileUpdate> {
  const UpdateProfileUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(ProfileUpdate params) {
    return repository.updateProfile(params);
  }
}
