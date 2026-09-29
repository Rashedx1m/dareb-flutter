import '../../../../core/data/mock_catalog.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/course.dart';

/// مصدر الدورات والمواد. يرمي [ServerException] عند الفشل.
abstract class CoursesRemoteDataSource {
  Future<List<Course>> getCourses();
  Future<List<Course>> getMyCourses();
  Future<Course> getCourse(String id);
  Future<List<Category>> getCategories();
  Future<List<Course>> searchCourses(String query);
}

/// تنفيذ تجريبي من [MockCatalog]، يُستبدل بتنفيذ الـ API في حقن الاعتماديات فقط.
class CoursesMockDataSource implements CoursesRemoteDataSource {
  const CoursesMockDataSource();

  @override
  Future<List<Course>> getCourses() async {
    await Future<void>.delayed(MockCatalog.latency);
    return MockCatalog.courses;
  }

  @override
  Future<List<Course>> getMyCourses() async {
    await Future<void>.delayed(MockCatalog.latency);
    return MockCatalog.courses.where((c) => c.progress > 0).toList();
  }

  @override
  Future<Course> getCourse(String id) async {
    await Future<void>.delayed(MockCatalog.latency);
    for (final course in MockCatalog.courses) {
      if (course.id == id) return course;
    }
    throw const ServerException('الدورة غير موجودة');
  }

  @override
  Future<List<Category>> getCategories() async => MockCatalog.categories;

  @override
  Future<List<Course>> searchCourses(String query) async {
    final q = query.trim();
    return MockCatalog.courses.where((c) {
      return c.title.contains(q) ||
          c.instructor.contains(q) ||
          c.categoryName.contains(q);
    }).toList();
  }
}
