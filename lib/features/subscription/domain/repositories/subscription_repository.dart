import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_method.dart';
import '../entities/subscription_package.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<SubscriptionPackage>>> getPackages();

  /// المواد التي تفتحها الباقة (`packages/details`).
  Future<Either<Failure, List<PackageSubject>>> getPackageSubjects(String packageId);

  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods();

  /// يفعّل الاشتراك بكود يصل المستخدم بعد الدفع (`subscriptions/add`).
  Future<Either<Failure, void>> subscribeWithCode(String code);
}
