import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/usecases/get_packages.dart';
import '../../domain/usecases/get_payment_methods.dart';

part 'checkout_state.dart';

/// صفحة إتمام الشراء: الباقة المختارة ووكلاء التحويل، مع خيار الدفع نقداً للإدارة.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({required this._getPackages, required this._getPaymentMethods})
      : super(const CheckoutState());

  final GetPackages _getPackages;
  final GetPaymentMethods _getPaymentMethods;
  String? _packageId;

  /// الباقة تُقرأ بمعرّفها من المسار، فتعمل الصفحة حتى لو فُتحت مباشرة.
  Future<void> load(String? packageId) async {
    _packageId = packageId;
    emit(const CheckoutState(status: CheckoutStatus.loading));
    final (packages, methods) = await (
      _getPackages(const NoParams()),
      _getPaymentMethods(const NoParams()),
    ).wait;
    if (isClosed) return;

    final data = packages.flatMap((p) => methods.map((m) => (packages: p, methods: m)));
    emit(
      data.fold(
        (failure) => CheckoutState(status: CheckoutStatus.failure, error: failure.message),
        (data) {
          final package = data.packages.where((p) => p.id == packageId).firstOrNull;
          if (package == null) {
            return const CheckoutState(status: CheckoutStatus.failure, error: AppStrings.packageNotFound);
          }
          return CheckoutState(
            status: CheckoutStatus.success,
            package: package,
            methods: data.methods,
            selectedMethodId: data.methods.isEmpty ? CheckoutState.cashId : data.methods.first.id,
          );
        },
      ),
    );
  }

  Future<void> retry() => load(_packageId);

  void selectMethod(String id) {
    emit(
      CheckoutState(
        status: state.status,
        package: state.package,
        methods: state.methods,
        selectedMethodId: id,
      ),
    );
  }
}
