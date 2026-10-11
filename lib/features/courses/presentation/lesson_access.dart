import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../domain/entities/lesson.dart';

/// الدرس يُفتح في التطبيق إن لم يكن مقفلاً ولم يكن اختباراً (لا صفحة للاختبار بعد).
bool canOpenLesson(Lesson lesson) => !lesson.isLocked && lesson.type != LessonType.exam;

/// يشرح سبب عدم فتح الدرس المقفل، ويعرض طريقاً إلى صفحة الاشتراك.
void showLockedLessonMessage(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text(AppStrings.subscribersOnlyLesson),
        action: SnackBarAction(label: AppStrings.subscribe, onPressed: () => context.push('/subscription')),
      ),
    );
}
