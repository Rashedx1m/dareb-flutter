import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subscription_package.dart';
import '../repositories/subscription_repository.dart';

class GetPackages implements UseCase<List<SubscriptionPackage>, NoParams> {
  const GetPackages(this.repository);
  final SubscriptionRepository repository;

  @override
  Future<Either<Failure, List<SubscriptionPackage>>> call(NoParams params) {
    return repository.getPackages();
  }
}
