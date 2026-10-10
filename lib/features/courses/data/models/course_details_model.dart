import '../../domain/entities/course_details.dart';
import 'course_model.dart';
import 'semester_model.dart';

/// رد `courses/details?subject_id=`: بطاقة المادة نفسها ومعها `semesters`.
class CourseDetailsModel extends CourseDetails {
  const CourseDetailsModel({required super.course, required super.semesters});

  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailsModel(
      course: CourseModel.fromJson(json),
      semesters: [
        for (final semester in (json['semesters'] as List).cast<Map<String, dynamic>>())
          SemesterModel.fromJson(semester),
      ],
    );
  }
}
