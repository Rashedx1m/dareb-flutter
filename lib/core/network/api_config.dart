/// إعدادات الاتصال بالخادم. يمكن تغيير العنوان عند التشغيل دون تعديل الكود:
/// `flutter run --dart-define=API_BASE_URL=https://...`
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://training.tamkeen-dev.com/dareb/public/api',
  );
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);
}