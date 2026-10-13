import 'package:equatable/equatable.dart';

import 'course.dart';
import 'semester.dart';

/// صفحة الدورة: بطاقتها وفصولها بدروسها، من `courses/details`.
class CourseDetails extends Equatable {
  const CourseDetails({
    required this.course,
    required this.semesters,
    required this.pointsCount,
    this.storyImageUrl,
    this.storyText,
    required this.isFirstStory,
  });

  final Course course;
  final List<Semester> semesters;

  /// نقاط الدورة، وتظهر بجانب أيقونة العملات تحت اسم الأستاذ.
  final int pointsCount;

  /// صورة نافذة التعريف بالدورة ونصها، وقد لا يكتبهما المشرف.
  final String? storyImageUrl;
  final String? storyText;

  /// يرسله الخادم ليُظهر نافذة التعريف. لم يتأكد بعد متى يصير `false`.
  final bool isFirstStory;

  /// نافذة التعريف تظهر إن طلبها الخادم وكان فيها ما يُعرض.
  bool get hasStory =>
      isFirstStory && ((storyText?.trim().isNotEmpty ?? false) || (storyImageUrl?.isNotEmpty ?? false));

  @override
  List<Object?> get props => [course, semesters, pointsCount, storyImageUrl, storyText, isFirstStory];
}
