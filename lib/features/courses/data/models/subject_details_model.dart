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
    // الاشتراك يكون بالمادة لا بالاختبار، فاختباراتها ونشاطاتها تتبعها.
    final subscribed = content['is_subscription'] as bool;
    return SubjectDetailsModel(
      course: CourseModel.fromJson(content),
      pointsCount: content['points_count'] as int,
      exams: _exams(json['exams'], subscribed: subscribed),
      activities: _exams(json['dailyActivities'], subscribed: subscribed),
    );
  }

  static List<SubjectExamModel> _exams(Object? list, {required bool subscribed}) => [
        for (final item in ((list as List?) ?? const []).cast<Map<String, dynamic>>())
          SubjectExamModel.fromJson(item, subjectSubscribed: subscribed),
      ];
}

/// عنصر من `exams` أو `dailyActivities`: ربط بين المادة والاختبار
/// `{id, expiry_date, type, is_free, exam}`، والاختبار نفسه في `exam` بعنوانه وأستاذه
/// وعدد أسئلته. النوعان صفحة واحدة في لوحة التحكم («الأختبارات العامة»): نوع
/// «الأختبارات» يصل في `exams`، ونوع «الأختبارات العامة» في `dailyActivities`.
///
/// «مجاني» هو `is_free` الخارجي، أي حقل «مجاني» الذي يضبطه المشرف لكل ربط.
/// `exam.is_free` الداخلي `false` دائماً ولا حقل له في اللوحة: المادة 1 مدفوعة وربطها
/// 12 مجاني (2026-10-18). ولا نوع اشتراك للاختبار في اللوحة، فالاشتراك بمادته.
class SubjectExamModel extends SubjectExam {
  const SubjectExamModel({
    required super.id,
    required super.title,
    required super.instructor,
    required super.questionsCount,
    required super.isFree,
    required super.isSubscribed,
  });

  /// في البحث قد يأتي الاختبار نفسه بلا غلاف `exam`، فيُقرأ كله من المستوى الأعلى.
  /// [subjectSubscribed] اشتراك الطالب بمادة الاختبار حين يُعرف، كما في صفحة المادة.
  factory SubjectExamModel.fromJson(Map<String, dynamic> json, {bool subjectSubscribed = false}) {
    final exam = (json['exam'] as Map<String, dynamic>?) ?? json;
    return SubjectExamModel(
      id: '${exam['id']}',
      title: exam['title'] as String,
      instructor: (exam['professor'] as String?) ?? '',
      questionsCount: exam['questions_count'] as int,
      isFree: json['is_free'] as bool,
      isSubscribed: subjectSubscribed || exam['is_subscription'] as bool,
    );
  }
}
