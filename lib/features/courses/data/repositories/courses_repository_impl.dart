import 'package:dartz/dartz.dart';

import '../../../../core/data/mock_catalog.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/courses_repository.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  @override
  Future<Either<Failure, List<Course>>> getCourses() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const Right(MockCatalog.courses);
  }

  @override
  Future<Either<Failure, List<Course>>> getMyCourses() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return Right(MockCatalog.courses.where((c) => c.progress > 0).toList());
  }

  @override
  Future<Either<Failure, Course>> getCourse(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return Right(MockCatalog.courses.firstWhere((c) => c.id == id));
    } catch (_) {
      return const Left(ServerFailure('الدورة غير موجودة'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    return const Right(MockCatalog.categories);
  }

  @override
  Future<Either<Failure, List<Course>>> searchCourses(String query) async {
    final q = query.trim();
    final results = MockCatalog.courses.where((c) {
      return c.title.contains(q) ||
          c.instructor.contains(q) ||
          c.categoryName.contains(q);
    }).toList();
    return Right(results);
  }
}
