part of 'checkout_cubit.dart';

enum CheckoutStatus { initial, loading, success, failure }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.package,
    this.methods = const [],
    this.selectedMethodId,
    this.error,
  });

  /// خيار «كاش مباشر مع الأدمن»، وهو ليس وكيلاً على الخادم.
  static const cashId = 'cash';

  final CheckoutStatus status;
  final SubscriptionPackage? package;
  final List<PaymentMethod> methods;
  final String? selectedMethodId;
  final String? error;

  /// الوكيل المختار، أو `null` للدفع نقداً.
  PaymentMethod? get selectedMethod => methods.where((m) => m.id == selectedMethodId).firstOrNull;

  @override
  List<Object?> get props => [status, package, methods, selectedMethodId, error];
}
