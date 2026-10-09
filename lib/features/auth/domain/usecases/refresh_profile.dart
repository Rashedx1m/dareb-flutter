import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// مستخدم الجلسة كما هو الآن على الخادم، مع تحديث نسخته المحفوظة.
class RefreshProfile implements UseCase<User, NoParams> {
  const RefreshProfile(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.refreshProfile();
  }
}
