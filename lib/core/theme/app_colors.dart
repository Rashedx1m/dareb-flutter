import 'package:flutter/material.dart';

/// ألوان مستخرجة من لقطات فيجما (تطبيق درب).
/// إذا نسخت كود اللون من اللوحة اليمنى في فيجما، عدّل القيم هنا فقط.
abstract final class AppColors {
  static const primary = Color(0xFF34BBBD);
  static const primaryDark = Color(0xFF2A9698);
  static const primarySoft = Color(0xFFE6F7F7);
  static const primaryMid = Color(0xFFB3E4E5);
  static const headerTeal = Color(0xFF34BBBD);
  static const navy = Color(0xFF355C8A);
  static const textPrimary = Color(0xFF1C2434);
  static const textSecondary = Color(0xFF7B8794);
  static const textMuted = Color(0xFFA0AAB5);
  static const background = Color(0xFFF5F7F9);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFD0D0D0);
  static const fieldBorder = Color(0xFFD0D0D0);
  static const keypadBg = Color(0xFFD1D5DB);
  static const keypadKey = Color(0xFFFFFFFF);
  static const danger = Color(0xFFE74C3C);
  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFF5A623);
  static const shadow = Color(0x14000000);
  static const sourceSelected = Color(0xFF8EA6F2);
  static const iconBlue = Color(0xFF7CA4F2);
  static const accentBlue = Color(0xFF5B8DEF); // تعبئة شريط خطوات التسجيل والكلمة المميزة في العناوين
  static const chipBlue = Color(0xFF7B9EF5); // أزرار المواد في الصفحة الرئيسية
  static const navMuted = Color(0xFFC5CDD6);
  static const stepTrack = Color(0xFFF1F5F9); // مسار شريط الخطوات (الجزء غير المكتمل)
  static const stepKnob = Color(0xFF61D8D9); // مؤشر (المقبض) الدائري على الشريط
  static const stepLabel = Color(0xFF3E4948); // نص الخطوات غير النشطة
  // صفحات الملف الشخصي والدعم (مأخوذة من لقطات التصميم).
  static const blueStrong = Color(0xFF5380D9); // أزرار التشغيل وعناوين السياسات وإطار الحقل النشط
  static const statTeal = Color(0xFF39CED0); // أرقام إحصاءات الملف الشخصي
  static const statLabel = Color(0xFF565F5E);
  static const nameDark = Color(0xFF0D1C2F);
  static const avatarBg = Color(0xFFE1E7FD);
  static const listText = Color(0xFF5A5A5A); // عناصر القوائم وعناوين أقسامها
  static const questionText = Color(0xFF414141);
  static const sheetTitle = Color(0xFF242424);
  static const closeIcon = Color(0xFF767676);
  static const hint = Color(0xFFA1A1A1);
  static const divider = Color(0xFFEBEBEB);
  static const cardBorder = Color(0xFFEDEDED);
  static const statDivider = Color(0xFFDDDDDD);
}
