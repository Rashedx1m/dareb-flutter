import '../../../../core/data/mock_catalog.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_details.dart';
import '../models/subject_model.dart';

/// مصدر الدورات والمواد. يرمي استثناءات [ApiClient] عند الفشل.
abstract class CoursesRemoteDataSource {
  Future<List<Course>> getCourses();
  Future<List<Course>> getMyCourses();
  Future<CourseDetails> getCourseDetails(String subjectId);
  Future<List<SubjectModel>> getSubjects();
  Future<List<Course>> searchCourses(String query);
}

class CoursesRemoteDataSourceImpl extends CoursesMockDataSource {
  const CoursesRemoteDataSourceImpl(this._client);
  final ApiClient _client;

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
  Future<List<Course>> getCourses() async {
    await Future<void>.delayed(MockCatalog.latency);
    return MockCatalog.courses;
  }

  @override
  Future<List<Course>> getMyCourses() async {
    await Future<void>.delayed(MockCatalog.latency);
    return MockCatalog.courses.where((c) => c.isSubscribed).toList();
  }

  @override
  Future<CourseDetails> getCourseDetails(String subjectId) async {
    await Future<void>.delayed(MockCatalog.latency);
    for (final course in MockCatalog.courses) {
      if (course.id == subjectId) return CourseDetails(course: course, semesters: const []);
    }
    throw const ServerException('الدورة غير موجودة');
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    final q = query.trim();
    return MockCatalog.courses.where((c) {
      return c.title.contains(q) ||
          c.instructor.contains(q) ||
          c.subjectName.contains(q);
    }).toList();
  }
}
