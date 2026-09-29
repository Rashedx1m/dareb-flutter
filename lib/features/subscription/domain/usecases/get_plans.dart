import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/plan.dart';
import '../repositories/subscription_repository.dart';

class GetPlans implements UseCase<List<Plan>, NoParams> {
  const GetPlans(this.repository);
  final SubscriptionRepository repository;

  @override
  Future<Either<Failure, List<Plan>>> call(NoParams params) {
    return repository.getPlans();
  }
}
