part of 'subscription_cubit.dart';

enum PackagesStatus { initial, loading, success, failure }

/// خانتا الكود في التصميم. كلاهما يُرسل إلى `subscriptions/add`، والفرق في الوصف فقط.
enum CodeOption { subjectOrCurriculum, multipleSubjects }

enum ActivationStatus { idle, sending, done, failure }

class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.status = PackagesStatus.initial,
    this.packages = const [],
    this.error,
    this.selectedPackageId,
    this.selectedCode,
    this.activation = ActivationStatus.idle,
    this.activationError,
  });

  final PackagesStatus status;
  final List<SubscriptionPackage> packages;
  final String? error;

  /// واحد فقط من الاثنين غير `null`.
  final String? selectedPackageId;
  final CodeOption? selectedCode;

  final ActivationStatus activation;
  final String? activationError;

  bool get hasChoice => selectedPackageId != null || selectedCode != null;

  SubscriptionState copyWith({
    PackagesStatus? status,
    List<SubscriptionPackage>? packages,
    String? error,
    ActivationStatus? activation,
    String? activationError,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      error: error ?? this.error,
      selectedPackageId: selectedPackageId,
      selectedCode: selectedCode,
      activation: activation ?? this.activation,
      activationError: activationError ?? this.activationError,
    );
  }

  /// اختيار باقة يلغي خانة الكود والعكس.
  SubscriptionState withChoice({String? packageId, CodeOption? code}) {
    return SubscriptionState(
      status: status,
      packages: packages,
      error: error,
      selectedPackageId: packageId,
      selectedCode: code,
      activation: activation,
      activationError: activationError,
    );
  }

  @override
  List<Object?> get props =>
      [status, packages, error, selectedPackageId, selectedCode, activation, activationError];
}
