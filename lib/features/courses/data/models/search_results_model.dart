import '../../domain/entities/search_results.dart';
import 'subject_details_model.dart';
import 'subject_model.dart';

/// رد `home-page/search?text=`: `{subjects, exams, dailyActivities}`. المواد بطاقات
/// قصيرة (`id, name, image, is_free, is_subscription`)، والاختبارات والنشاطات لم
/// تظهر في نتيجة بعد، فتُقرأ بشكل `subjects/details`.
class SearchResultsModel extends SearchResults {
  const SearchResultsModel({super.subjects, super.exams, super.activities});

  factory SearchResultsModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String key) => ((json[key] as List?) ?? const []).cast<Map<String, dynamic>>();
    return SearchResultsModel(
      subjects: [for (final subject in list('subjects')) SubjectModel.fromJson(subject)],
      exams: [for (final exam in list('exams')) SubjectExamModel.fromJson(exam)],
      activities: [for (final activity in list('dailyActivities')) SubjectExamModel.fromJson(activity)],
    );
  }
}
