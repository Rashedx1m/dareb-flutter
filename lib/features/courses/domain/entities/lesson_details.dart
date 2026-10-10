import 'package:equatable/equatable.dart';

import 'lesson.dart';
import 'semester.dart';

/// صفحة الدرس: الدرس نفسه وفصله بكل دروسه، من `lessions/details`.
class LessonDetails extends Equatable {
  const LessonDetails({required this.lesson, required this.semester});

  final Lesson lesson;
  final Semester semester;

  @override
  List<Object?> get props => [lesson, semester];
}
