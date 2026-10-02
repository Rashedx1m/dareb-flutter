import 'package:flutter/foundation.dart';

/// انتهاء الجلسة من جهة الخادم (رد 401 على طلب يحمل توكن): يمسح الجلسة
/// المحلية ثم يُعلم مستمعيه، فيعيد الموجّه تقييم `redirect` ويفتح صفحة الدخول.
class SessionExpiry extends ChangeNotifier {
  SessionExpiry(this._clearSession);

  /// يمسح التوكن والمستخدم المحفوظين. يُمرَّر من حقن الاعتماديات حتى لا يعرف
  /// `core` ميزة المصادقة.
  final Future<void> Function() _clearSession;

  Future<void> expire() async {
    await _clearSession();
    notifyListeners();
  }
}
