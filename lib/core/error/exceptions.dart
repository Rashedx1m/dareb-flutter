/// استثناءات طبقة البيانات. لا تصل إلى الواجهة أبداً: المستودع يحوّلها إلى
/// [Failure] عبر `guard`، لذلك رسائلها الافتراضية بالعربية كما في `failures.dart`.
class ServerException implements Exception {
  const ServerException([this.message = 'حدث خطأ في الخادم']);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'تعذر قراءة البيانات المحلية']);
  final String message;
}

class AuthException implements Exception {
  const AuthException([this.message = 'فشل تسجيل الدخول']);
  final String message;
}
/// رد 422: حقول ناقصة أو غير صالحة. الرسالة أول خطأ أعاده الخادم.
class ValidationException implements Exception {
  const ValidationException([this.message = 'البيانات غير صحيحة']);
  final String message;
}