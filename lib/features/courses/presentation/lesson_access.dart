import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_sheet.dart';
import '../domain/entities/lesson.dart';

/// الدرس يُفتح في التطبيق إن لم يكن مقفلاً ولم يكن اختباراً (لا صفحة للاختبار بعد).
bool canOpenLesson(Lesson lesson) => !lesson.isLocked && lesson.type != LessonType.exam;

/// نافذة «اشترك الآن واحصل عليه» عند الضغط على درس مقفل، و«اشترك» يفتح صفحة الاشتراك.
Future<void> showSubscribeDialog(BuildContext context) async {
  final subscribe = await showConfirmDialog(
    context,
    title: AppStrings.subscribeToGetIt,
    confirmLabel: AppStrings.subscribeWord,
  );
  if (subscribe && context.mounted) await context.push('/subscription');
}

/// نافذة «أكمل الدرس السابق» عند الضغط على درس منتظر، و«ابدأ» يستدعي [onStart].
Future<void> showFinishPreviousDialog(BuildContext context, {required VoidCallback onStart}) async {
  final start = await showConfirmDialog(
    context,
    title: AppStrings.finishPreviousLesson,
    confirmLabel: AppStrings.startWord,
    icon: PhosphorIconsFill.warning,
    iconColor: AppColors.danger,
  );
  if (start) onStart();
}
