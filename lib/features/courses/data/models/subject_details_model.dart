import '../../domain/entities/subject_details.dart';
import 'course_model.dart';

/// رد `subjects/details?id=`: `{content, exams, dailyActivities}`. `content` بطاقة
/// المادة كما في `courses/paginate` ومعها `points_count`.
class SubjectDetailsModel extends SubjectDetails {
  const SubjectDetailsModel({
    required super.course,
    required super.pointsCount,
    required super.exams,
    required super.activities,
  });

  factory SubjectDetailsModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>;
    return SubjectDetailsModel(
      course: CourseModel.fromJson(content),
      pointsCount: content['points_count'] as int,
      exams: _exams(json['exams']),
      activities: _exams(json['dailyActivities']),
    );
  }

  static List<SubjectExamModel> _exams(Object? list) => [
        for (final item in ((list as List?) ?? const []).cast<Map<String, dynamic>>()) SubjectExamModel.fromJson(item),
      ];
}

/// عنصر من `exams` أو `dailyActivities`: `{id, expiry_date, type, is_free, exam}`،
/// والاختبار نفسه في `exam` بعنوانه وأستاذه وعدد أسئلته. `is_free` الخارجي للمادة
/// و`exam.is_free` للاختبار، ويُقرأ الثاني. شكل النشاطات لم يظهر بعد (قائمتها فارغة
/// على خادم التدريب)، ويُفترض مثل الاختبارات.
class SubjectExamModel extends SubjectExam {
  const SubjectExamModel({
    required super.id,
    required super.title,
    required super.instructor,
    required super.questionsCount,
    required super.isFree,
    required super.isSubscribed,
  });

  /// في البحث قد يأتي الاختبار نفسه بلا غلاف `exam`، فيُقرأ من المستوى الأعلى.
  factory SubjectExamModel.fromJson(Map<String, dynamic> json) {
    final exam = (json['exam'] as Map<String, dynamic>?) ?? json;
    return SubjectExamModel(
      id: '${exam['id']}',
      title: exam['title'] as String,
      instructor: (exam['professor'] as String?) ?? '',
      questionsCount: exam['questions_count'] as int,
      isFree: exam['is_free'] as bool,
      isSubscribed: exam['is_subscription'] as bool,
    );
  }
}
