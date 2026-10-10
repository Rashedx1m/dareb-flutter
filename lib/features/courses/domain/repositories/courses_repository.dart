import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/course.dart';
import '../entities/subject.dart';

abstract class CoursesRepository {
  Future<Either<Failure, List<Course>>> getCourses();
  Future<Either<Failure, List<Course>>> getMyCourses();
  Future<Either<Failure, Course>> getCourse(String id);
  Future<Either<Failure, List<Subject>>> getSubjects();
  Future<Either<Failure, List<Course>>> searchCourses(String query);
}
