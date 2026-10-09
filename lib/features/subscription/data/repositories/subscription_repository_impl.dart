import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl(this._remote);
  final SubscriptionRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<SubscriptionPackage>>> getPackages() => guard(_remote.getPackages);

  @override
  Future<Either<Failure, List<PackageSubject>>> getPackageSubjects(String packageId) {
    return guard(() async => (await _remote.getPackage(packageId)).subjects);
  }

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods() => guard(_remote.getPaymentMethods);

  @override
  Future<Either<Failure, void>> subscribeWithCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return const Left(ValidationFailure(AppStrings.errorCodeRequired));
    return guard(() => _remote.subscribeWithCode(trimmed));
  }
}
