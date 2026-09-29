import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/plan.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<Plan>>> getPlans();
}
