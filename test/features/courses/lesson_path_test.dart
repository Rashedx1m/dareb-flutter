import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/features/courses/domain/entities/lesson.dart';
import 'package:educational_app/features/courses/domain/entities/semester.dart';
import 'package:educational_app/features/courses/presentation/lesson_path.dart';
import 'package:flutter_test/flutter_test.dart';

Lesson _lesson(String id, {LessonType type = LessonType.video, bool isFree = true, bool isAttended = false}) =>
    Lesson(
      id: id,
      title: id,
      type: type,
      order: 0,
      isFree: isFree,
      isSubscribed: false,
      isAttended: isAttended,
    );

Semester _semester(String id, List<Lesson> lessons) => Semester(
      id: id,
      name: id,
      isFree: true,
      price: 0,
      lessonsCount: lessons.length,
      isSubscribed: false,
      lessons: lessons,
    );

/// حالة كل درس، ومعها «*» لدرس «قيد التشغيل» واسم الدرس السابق للمنتظر.
List<List<String>> _describe(List<Semester> semesters) => [
      for (final (_, lessons) in learningPath(semesters))
        [
          for (final item in lessons)
            '${item.lesson.id}:${item.step.name}${item.isCurrent ? '*' : ''}'
            '${item.previous == null ? '' : '<${item.previous!.id}'}',
        ],
    ];

void main() {
  group('learningPath', () {
    test('أول درس لم يُحضر «قيد التشغيل»، وما بعده ينتظره', () {
      expect(
        _describe([
          _semester('s1', [_lesson('1', isAttended: true), _lesson('2'), _lesson('3')]),
        ]),
        [
          ['1:open', '2:open*', '3:waiting<2'],
        ],
      );
    });

    test('المقفل والاختبار لا يوقفان ما بعدهما، ولا يُعدّان «قيد التشغيل»', () {
      expect(
        _describe([
          _semester('s1', [
            _lesson('1', isFree: false),
            _lesson('2', type: LessonType.exam),
            _lesson('3', type: LessonType.file),
          ]),
        ]),
        [
          ['1:locked', '2:exam', '3:open*'],
        ],
      );
    });

    test('الانتظار داخل الفصل وحده، و«قيد التشغيل» مرة واحدة في الدورة', () {
      expect(
        _describe([
          _semester('s1', [_lesson('1'), _lesson('2')]),
          _semester('empty', []),
          _semester('s2', [_lesson('3'), _lesson('4')]),
        ]),
        [
          ['1:open*', '2:waiting<1'],
          ['3:open', '4:waiting<3'],
        ],
      );
    });

    test('حين تُحضر كل الدروس لا يبقى «قيد التشغيل»', () {
      expect(
        _describe([
          _semester('s1', [_lesson('1', isAttended: true), _lesson('2', isAttended: true)]),
        ]),
        [
          ['1:open', '2:open'],
        ],
      );
    });
  });

  group('lessonDurationLabel', () {
    test('ما دون الساعة بالدقائق والثواني', () {
      expect(lessonDurationLabel('00:22:30'), '22:30 ${AppStrings.minutesUnit}');
    });

    test('ساعة فأكثر كما هي', () {
      expect(lessonDurationLabel('21:15:25'), '21:15:25 ${AppStrings.hoursUnit}');
    });

    test('رقم وحده يُعدّ دقائق', () {
      expect(lessonDurationLabel(' 7 '), '7 ${AppStrings.minutesUnit}');
    });
  });
}
