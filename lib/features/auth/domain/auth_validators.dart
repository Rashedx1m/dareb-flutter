import '../../../core/constants/app_strings.dart';

/// قواعد التحقق من حقول المصادقة، مصدر واحد تستخدمه الصفحات والمستودع معاً
/// حتى لا تتكرر الرسائل أو تختلف بين طبقة وأخرى.
abstract final class AuthValidators {
  /// طول رمز التحقق المرسل عبر الرسائل القصيرة.
  static const otpLength = 4;

  static final _digits = RegExp(r'^[0-9]+$');
  static final _nonDigits = RegExp(r'[\s\-()]');
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  /// يوحّد رقم الهاتف للمقارنة والتخزين (بدون مسافات أو شرطات).
  static String normalizedPhone(String value) =>
      value.trim().replaceAll(_nonDigits, '');

  /// يعيد رسالة الخطأ، أو `null` إذا كان الرقم صالحاً.
  static String? phone(String value) {
    final normalized = normalizedPhone(value);
    if (normalized.isEmpty) return AppStrings.errorPhoneRequired;
    final bare = normalized.startsWith('+') ? normalized.substring(1) : normalized;
    if (!_digits.hasMatch(bare) || bare.length < 9 || bare.length > 15) {
      return AppStrings.errorPhoneInvalid;
    }
    return null;
  }

  static String? email(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return AppStrings.errorEmailRequired;
    if (!_email.hasMatch(normalized)) return AppStrings.errorEmailInvalid;
    return null;
  }

  static String? name(String value) {
    if (value.trim().isEmpty) return AppStrings.errorFieldsRequired;
    return null;
  }

  static String? otp(String value) {
    final normalized = value.trim();
    if (normalized.length < otpLength) return AppStrings.errorOtpIncomplete;
    if (!_digits.hasMatch(normalized)) return AppStrings.errorOtpInvalid;
    return null;
  }
}
