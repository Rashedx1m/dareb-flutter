import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/course.dart';

abstract class CoursesRepository {
  Future<Either<Failure, List<Course>>> getCourses();
  Future<Either<Failure, List<Course>>> getMyCourses();
  Future<Either<Failure, Course>> getCourse(String id);
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<Course>>> searchCourses(String query);
}
