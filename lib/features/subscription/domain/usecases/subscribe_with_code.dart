import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/subscription_repository.dart';

class SubscribeWithCode implements UseCase<void, String> {
  const SubscribeWithCode(this.repository);
  final SubscriptionRepository repository;

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.subscribeWithCode(params);
  }
}
