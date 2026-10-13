import 'package:equatable/equatable.dart';

import 'comment.dart';
import 'lesson.dart';
import 'semester.dart';

/// صفحة الدرس: الدرس نفسه وفصله بكل دروسه وتعليقاته، من `lessions/details`.
class LessonDetails extends Equatable {
  const LessonDetails({required this.lesson, required this.semester, this.comments = const []});

  final Lesson lesson;
  final Semester semester;

  /// بترتيب الخادم.
  final List<Comment> comments;

  @override
  List<Object?> get props => [lesson, semester, comments];
}
