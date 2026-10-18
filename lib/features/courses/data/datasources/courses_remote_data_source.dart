import '../../../../core/network/api_client.dart';
import '../models/course_details_model.dart';
import '../models/course_model.dart';
import '../models/lesson_details_model.dart';
import '../models/search_results_model.dart';
import '../models/subject_details_model.dart';
import '../models/subject_model.dart';

/// مصدر الدورات والمواد. يرمي استثناءات [ApiClient] عند الفشل.
abstract class CoursesRemoteDataSource {
  Future<List<CourseModel>> getCourses();
  Future<List<CourseModel>> getMyCourses();
  Future<CourseDetailsModel> getCourseDetails(String subjectId);
  Future<LessonDetailsModel> getLesson(String lessonId);
  Future<void> attendLesson(String lessonId);
  Future<void> addComment(String lessonId, String text);
  Future<List<SubjectModel>> getSubjects();
  Future<SubjectDetailsModel> getSubjectDetails(String subjectId);
  Future<SearchResultsModel> search(String query);
}

class CoursesRemoteDataSourceImpl implements CoursesRemoteDataSource {
  const CoursesRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  /// `courses/paginate` بلا `page` ولا `perPage` يعيد القائمة كاملة. التقسيم فيه
  /// ليس بشكل Laravel: `data` مصفوفة عارية بلا `last_page`.
  @override
  Future<List<CourseModel>> getCourses() {
    return _client.get(
      '/courses/paginate',
      parse: (data) => [
        for (final json in (data as List).cast<Map<String, dynamic>>()) CourseModel.fromJson(json),
      ],
    );
  }

  /// يرد `{subjects: [{id, price, subject}]}`: `id` رقم الاشتراك و`price` ما دُفع،
  /// و`subject` بطاقة الدورة نفسها بـ `is_subscription: true`. المادة التي تظهر في
  /// أكثر من اشتراك تُعرض مرة واحدة.
  @override
  Future<List<CourseModel>> getMyCourses() {
    return _client.get(
      '/subscriptions/my',
      parse: (data) {
        // بلا اشتراكات يعيد الخادم `data: []` بدل `{subjects: []}` (2026-10-18).
        if (data is List && data.isEmpty) return const [];
        final items = ((data as Map<String, dynamic>)['subjects'] as List).cast<Map<String, dynamic>>();
        final courses = <String, CourseModel>{};
        for (final item in items) {
          final course = CourseModel.fromJson(item['subject'] as Map<String, dynamic>);
          courses.putIfAbsent(course.id, () => course);
        }
        return courses.values.toList();
      },
    );
  }

  /// بمعرّف المادة لا الدورة. معرّف غير موجود يُرفض بـ 422 («الحقل المواد لاغٍ»)
  /// لا 404.
  @override
  Future<CourseDetailsModel> getCourseDetails(String subjectId) {
    return _client.get(
      '/courses/details',
      query: {'subject_id': subjectId},
      parse: (data) => CourseDetailsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// درس غير موجود يعود 404 برسالة Laravel إنجليزية، فيستبدلها [ApiClient].
  @override
  Future<LessonDetailsModel> getLesson(String lessonId) {
    return _client.get(
      '/lessions/details',
      query: {'id': lessonId},
      parse: (data) => LessonDetailsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// يرد 201 بسجل الحضور `{id, lession_id, user_id, created_at, updated_at}`، و
  /// `lession_id` فيه نص لا رقم. لا يُقرأ منه شيء: الأثر يظهر في `is_attended`
  /// ونسب `lession_rate` عند الطلب التالي.
  @override
  Future<void> attendLesson(String lessonId) async {
    await _client.post('/lessions/attend-lession', fields: {'lession_id': lessonId});
  }

  /// يعمل بلا توكن، ويرد `{content, exams, dailyActivities}`.
  @override
  Future<SubjectDetailsModel> getSubjectDetails(String subjectId) {
    return _client.get(
      '/subjects/details',
      query: {'id': subjectId},
      parse: (data) => SubjectDetailsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// كما في مجموعة Postman: `lession_id` و`comment`. لم يُجرَّب على الخادم بعد،
  /// والرد لا يُقرأ: التعليق يظهر عند إعادة جلب الدرس.
  @override
  Future<void> addComment(String lessonId, String text) async {
    await _client.post('/comments/add-comment', fields: {'lession_id': lessonId, 'comment': text});
  }

  /// يرد `{subjects, exams, dailyActivities}`. يطابق اسم المادة فقط، لا اسم الأستاذ
  /// ولا عنوان الدورة.
  @override
  Future<SearchResultsModel> search(String query) {
    return _client.get(
      '/home-page/search',
      query: {'text': query},
      parse: (data) => SearchResultsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// قائمة المواد تتبع الجلسة: بتوكن مختلف أو بلا توكن تعود مواد أخرى.
  @override
  Future<List<SubjectModel>> getSubjects() {
    return _client.get(
      '/subjects/all',
      parse: (data) => [
        for (final json in (data as List).cast<Map<String, dynamic>>()) SubjectModel.fromJson(json),
      ],
    );
  }
}
