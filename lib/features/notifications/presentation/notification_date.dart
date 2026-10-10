import '../../../core/constants/app_strings.dart';

/// وقت الإشعار كما في التصميم: «25 أبريل 2025 / 12:00 صباحًا»، بنظام 12 ساعة.
/// يدوياً لا بـ `DateFormat`: العربية فيه تكتب «ص/م» وتحتاج تهيئة عند التشغيل.
String notificationDateLabel(DateTime date) {
  final month = AppStrings.months[date.month - 1];
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? AppStrings.am : AppStrings.pm;
  return '${date.day} $month ${date.year} / $hour:$minute $period';
}
