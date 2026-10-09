import 'package:equatable/equatable.dart';

/// باقة اشتراك من `packages/all`. الدفع خارج التطبيق عبر وكيل، والتفعيل بكود.
class SubscriptionPackage extends Equatable {
  const SubscriptionPackage({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.durationDays,
    this.subjects = const [],
  });

  final String id;
  final String name;

  /// بالليرة السورية.
  final double price;
  final String? description;

  /// مدة الباقة بالأيام، أو `null` إن لم يحددها الخادم.
  final int? durationDays;

  /// المواد التي تفتحها الباقة.
  final List<PackageSubject> subjects;

  bool get isFree => price == 0;

  @override
  List<Object?> get props => [id, name, price, description, durationDays, subjects];
}

/// مادة ضمن باقة، كما تُعرض في نافذة «المواد المتاحة».
class PackageSubject extends Equatable {
  const PackageSubject({required this.id, required this.name, this.imageUrl});

  final String id;
  final String name;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, imageUrl];
}
