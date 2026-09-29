import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/plan.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl(this._remote);
  final SubscriptionRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Plan>>> getPlans() {
    return guard(_remote.getPlans);
  }
}
