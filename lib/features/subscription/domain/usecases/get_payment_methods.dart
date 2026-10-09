import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/payment_method.dart';
import '../repositories/subscription_repository.dart';

class GetPaymentMethods implements UseCase<List<PaymentMethod>, NoParams> {
  const GetPaymentMethods(this.repository);
  final SubscriptionRepository repository;

  @override
  Future<Either<Failure, List<PaymentMethod>>> call(NoParams params) {
    return repository.getPaymentMethods();
  }
}
