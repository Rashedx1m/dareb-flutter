import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// مستخدم الجلسة الحالية، أو `null` إذا لم تُفتح جلسة.
class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  const GetCurrentUserUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User?>> call(NoParams params) {
    return repository.currentUser();
  }
}
