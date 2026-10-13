import '../../../core/constants/app_strings.dart';
import '../domain/entities/lesson.dart';
import '../domain/entities/semester.dart';

/// حالة الدرس في «مسار التعلم».
enum LessonStep {
  /// يُفتح الآن.
  open,

  /// مدفوع والطالب غير مشترك.
  locked,

  /// مفتوح، لكن قبله في فصله درس مفتوح لم يحضره الطالب بعد.
  waiting,

  /// اختبار: لا صفحة له في التطبيق بعد.
  exam,
}

/// درس في المسار مع حالته.
class PathLesson {
  const PathLesson(this.lesson, this.step, {this.previous, this.isCurrent = false});

  final Lesson lesson;
  final LessonStep step;

  /// للدرس المنتظر: الدرس الذي يكمله الطالب أولاً.
  final Lesson? previous;

  /// أول درس مفتوح لم يُحضر في الدورة كلها، وعليه «قيد التشغيل».
  final bool isCurrent;
}

/// دروس كل فصل بحالاتها، والفصل الفارغ لا يظهر.
///
/// الترتيب كما في التصميم («أكمل الدرس السابق»): الدرس المفتوح ينتظر حتى يحضر الطالب
/// ما قبله من دروس فصله المفتوحة. الخادم لا يفرض هذا الترتيب، والاختبار والدرس المقفل
/// لا يوقفان ما بعدهما لأن الطالب لا يستطيع إنهاءهما في التطبيق الآن.
List<(Semester, List<PathLesson>)> learningPath(List<Semester> semesters) {
  final path = <(Semester, List<PathLesson>)>[];
  var currentFound = false;
  for (final semester in semesters) {
    if (semester.lessons.isEmpty) continue;
    Lesson? pending;
    final lessons = <PathLesson>[];
    for (final lesson in semester.lessons) {
      if (lesson.type == LessonType.exam) {
        lessons.add(PathLesson(lesson, LessonStep.exam));
      } else if (lesson.isLocked) {
        lessons.add(PathLesson(lesson, LessonStep.locked));
      } else if (pending != null) {
        lessons.add(PathLesson(lesson, LessonStep.waiting, previous: pending));
      } else if (lesson.isAttended) {
        lessons.add(PathLesson(lesson, LessonStep.open));
      } else {
        lessons.add(PathLesson(lesson, LessonStep.open, isCurrent: !currentFound));
        pending = lesson;
        currentFound = true;
      }
    }
    path.add((semester, lessons));
  }
  return path;
}

/// مدة الدرس كما في التصميم: «22:30 دقيقة» لما دون الساعة. الخادم يرسل "HH:MM:SS"،
/// وقد يكتب المشرف رقماً وحده («7») فيُعدّ دقائق.
String lessonDurationLabel(String raw) {
  final value = raw.trim();
  final parts = value.split(':');
  if (parts.length == 3) {
    return int.tryParse(parts.first) == 0
        ? '${parts[1]}:${parts[2]} ${AppStrings.minutesUnit}'
        : '$value ${AppStrings.hoursUnit}';
  }
  return '$value ${AppStrings.minutesUnit}';
}
