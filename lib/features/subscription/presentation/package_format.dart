import '../../../core/constants/app_strings.dart';
import '../domain/entities/subscription_package.dart';

/// السعر كما في التصميم: «55 ألف» للآلاف الكاملة، وإلا الرقم بلا أصفار زائدة.
String formatPrice(double price) {
  if (price >= 1000 && price % 1000 == 0) return '${price ~/ 1000} ${AppStrings.thousand}';
  if (price == price.roundToDouble()) return '${price.toInt()}';
  return price.toStringAsFixed(2);
}

/// «سنة» أو «7 أيام تجربة»، ويظهر في التصميم أصغر من السعر.
String? packagePeriodLabel(SubscriptionPackage package) {
  final period = _period(package.durationDays);
  if (period == null) return null;
  return package.isFree ? '$period ${AppStrings.trial}' : period;
}

String? _period(int? days) => switch (days) {
      null || <= 0 => null,
      365 => AppStrings.year,
      30 || 31 => AppStrings.month,
      1 => AppStrings.day,
      <= 10 => '$days ${AppStrings.days}',
      _ => '$days ${AppStrings.day}',
    };
