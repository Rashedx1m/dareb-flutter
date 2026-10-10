import 'package:equatable/equatable.dart';

import 'course.dart';
import 'semester.dart';

/// صفحة الدورة: بطاقتها وفصولها بدروسها، من `courses/details`.
class CourseDetails extends Equatable {
  const CourseDetails({required this.course, required this.semesters});

  final Course course;
  final List<Semester> semesters;

  @override
  List<Object?> get props => [course, semesters];
}
