import '../../domain/entities/course_details.dart';
import 'course_model.dart';
import 'semester_model.dart';

/// رد `courses/details?subject_id=`: بطاقة المادة نفسها ومعها `semesters`، ونقاطها
/// ونافذة التعريف بها (`story_*`).
class CourseDetailsModel extends CourseDetails {
  const CourseDetailsModel({
    required super.course,
    required super.semesters,
    required super.pointsCount,
    super.storyImageUrl,
    super.storyText,
    required super.isFirstStory,
  });

  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailsModel(
      course: CourseModel.fromJson(json),
      semesters: [
        for (final semester in (json['semesters'] as List).cast<Map<String, dynamic>>())
          SemesterModel.fromJson(semester),
      ],
      pointsCount: json['points_count'] as int,
      storyImageUrl: json['story_image'] as String?,
      storyText: json['story_text'] as String?,
      isFirstStory: json['is_first_story'] as bool,
    );
  }
}
