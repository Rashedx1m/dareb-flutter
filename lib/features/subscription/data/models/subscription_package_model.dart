import '../../domain/entities/subscription_package.dart';

/// باقة كما يعيدها الخادم. لا باقات على خادم التدريب بعد، فالقراءة متسامحة:
/// الحقل الغائب يأخذ قيمة افتراضية، والسعر والمدة يُقبلان رقماً أو نصاً.
class SubscriptionPackageModel extends SubscriptionPackage {
  const SubscriptionPackageModel({
    required super.id,
    required super.name,
    required super.price,
    super.description,
    super.durationDays,
    super.subjects,
  });

  factory SubscriptionPackageModel.fromJson(Map<String, dynamic> json) {
    final subjects = json['subjects'];
    return SubscriptionPackageModel(
      id: '${json['id']}',
      name: (json['name'] ?? json['title'] ?? '') as String,
      price: _number(json['price'])?.toDouble() ?? 0,
      description: json['description'] as String?,
      durationDays: _number(json['duration'] ?? json['days'])?.toInt(),
      subjects: [
        if (subjects is List)
          for (final subject in subjects.cast<Map<String, dynamic>>()) _subject(subject),
      ],
    );
  }

  /// المادة بشكل `subjects/all`: `{id, name, image}`.
  static PackageSubject _subject(Map<String, dynamic> json) {
    return PackageSubject(
      id: '${json['id']}',
      name: json['name'] as String,
      imageUrl: json['image'] as String?,
    );
  }

  static num? _number(Object? value) => switch (value) {
        num() => value,
        String() => num.tryParse(value),
        _ => null,
      };
}
