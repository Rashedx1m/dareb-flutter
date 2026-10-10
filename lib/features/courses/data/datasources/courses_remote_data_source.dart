import '../../../../core/data/mock_catalog.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/subject.dart';
import '../models/course_details_model.dart';
import '../models/course_model.dart';
import '../models/lesson_details_model.dart';
import '../models/subject_model.dart';

/// مصدر الدورات والمواد. يرمي استثناءات [ApiClient] عند الفشل.
abstract class CoursesRemoteDataSource {
  Future<List<CourseModel>> getCourses();
  Future<List<Course>> getMyCourses();
  Future<CourseDetailsModel> getCourseDetails(String subjectId);
  Future<LessonDetailsModel> getLesson(String lessonId);
  Future<void> attendLesson(String lessonId);
  Future<List<SubjectModel>> getSubjects();
  Future<List<Subject>> searchSubjects(String query);
}

class CoursesRemoteDataSourceImpl extends CoursesMockDataSource {
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

/// ما لم يُربط بالخادم بعد، من [MockCatalog]. يرثه [CoursesRemoteDataSourceImpl].
abstract class CoursesMockDataSource implements CoursesRemoteDataSource {
  const CoursesMockDataSource();

  @override
  Future<List<Course>> getMyCourses() async {
    await Future<void>.delayed(MockCatalog.latency);
    return MockCatalog.courses.where((c) => c.isSubscribed).toList();
  }

  @override
  Future<List<Subject>> searchSubjects(String query) async {
    return [
      for (final c in MockCatalog.courses)
        if (c.subjectName.contains(query))
          Subject(id: c.id, name: c.subjectName, imageUrl: c.imageUrl, isFree: c.isFree, isSubscribed: c.isSubscribed),
    ];
  }
}
