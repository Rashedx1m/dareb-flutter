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
  // الظلال والطبقات المعتمة فوق الصور (أسود بنسبة الشفافية المذكورة).
  static const shadowSoft = Color(0x0A000000);
  static const shadowLight = Color(0x0F000000);
  static const shadowStrong = Color(0x1A000000);
  static const overlay40 = Color(0x66000000);
  static const overlay60 = Color(0x99000000);
  static const overlay70 = Color(0xB3000000);
  static const overlay80 = Color(0xCC000000);
  static const videoBackground = Color(0xFF111111);
  static const viewerBackground = Color(0xF20E1114); // خلفية عارض الصور
  // الصفحة الرئيسية والمعرض والاختبارات والتنزيلات.
  static const cardBorderSoft = Color(0xFFEEF2F6);
  static const albumBorder = Color(0xFFE3ECF2);
  static const progressTrack = Color(0xFFE8EEF2);
  static const progressText = Color(0xFF8A9AA8);
  static const iconTileBlue = Color(0xFFEAF1FF);
  static const dotInactive = Color(0xFFD9DEE5);
  static const imageCaption = Color(0xFFE0E6EC); // نص فوق صورة الخبر
  static const tabTrack = Color(0xFFB0B8BC);
  static const tabLabel = Color(0xFFF2F5F6);
  static const quizCardBorder = Color(0xFFBFD3F3);
  static const metaText = Color(0xFF5C5C5C);
  // صفحة الدورة: «مسار التعلم» وبطاقات دروسه.
  static const pathTitle = Color(0xFF000000);
  static const lessonTitle = Color(0xFF171717);
  static const timelineLine = Color(0xFFF3F3F3);
  static const stepIdleFill = Color(0xFFF4F5F7); // دائرة الدرس المقفل في المسار
  static const stepIdleIcon = Color(0xFF8F9092);
  static const chipFill = Color(0xFFF4F4F4); // شارة المدة أو النوع في بطاقة الدرس
  static const watchedFill = Color(0xFFD3F8E2);
  static const watchedBorder = Color(0xFF8FCBAA);
  static const watchedText = Color(0xFF1E3A28);
  static const commentOwnFill = Color(0xFFEBFBFB); // تعليق الطالب نفسه في «النقاشات»
  static const searchCardBorder = Color(0xFF8D9DC1); // إطار حقل البحث وبطاقات نتائجه
  // الاشتراكات.
  static const onAccentBlue = Color(0xFFEBFAFA); // نص بطاقة الباقة المختارة
  static const iconMuted = Color(0xFFAFB6BC);
  static const controlFill = Color(0xFFD9D9D9); // الراديو المختار ومسار شريط التمرير
  static const subjectChip = Color(0xFFCCDCFA);
  static const subjectText = Color(0xFF3F3F3F);
  // ألوان العلامات التجارية لأيقونات التواصل.
  static const whatsapp = Color(0xFF25D366);
  static const telegram = Color(0xFF29A9EB);
  static const facebook = Color(0xFF1877F2);
  static const instagramGradient = [
    Color(0xFFFEDA75),
    Color(0xFFFA7E1E),
    Color(0xFFD62976),
    Color(0xFF962FBF),
    Color(0xFF4F5BD5),
  ];
}
