import '../../domain/entities/lesson_details.dart';
import 'lesson_model.dart';
import 'semester_model.dart';

/// رد `lessions/details?id=`: حقول الدرس في المستوى الأعلى ومعها `semester`
/// بكل دروسه و`comments` (فارغة دائماً، ولا تُقرأ بعد). الاختبارات الشقيقة في
/// `semester.lessions` تأتي بلا مفتاح `exam`.
class LessonDetailsModel extends LessonDetails {
  const LessonDetailsModel({required super.lesson, required super.semester});

  factory LessonDetailsModel.fromJson(Map<String, dynamic> json) {
    return LessonDetailsModel(
      lesson: LessonModel.fromJson(json),
      semester: SemesterModel.fromJson(json['semester'] as Map<String, dynamic>),
    );
  }
}
