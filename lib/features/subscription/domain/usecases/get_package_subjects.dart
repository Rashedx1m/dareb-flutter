import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subscription_package.dart';
import '../repositories/subscription_repository.dart';

class GetPackageSubjects implements UseCase<List<PackageSubject>, String> {
  const GetPackageSubjects(this.repository);
  final SubscriptionRepository repository;

  @override
  Future<Either<Failure, List<PackageSubject>>> call(String params) {
    return repository.getPackageSubjects(params);
  }
}
