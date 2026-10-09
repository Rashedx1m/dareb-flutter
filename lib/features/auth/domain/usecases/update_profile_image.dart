import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile_image.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileImage implements UseCase<User, ProfileImage> {
  const UpdateProfileImage(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(ProfileImage params) {
    return repository.updateProfileImage(params);
  }
}
