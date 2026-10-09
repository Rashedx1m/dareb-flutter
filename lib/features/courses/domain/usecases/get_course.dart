import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/course.dart';
import '../repositories/courses_repository.dart';

class GetCourse implements UseCase<Course, String> {
  const GetCourse(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, Course>> call(String params) {
    return repository.getCourse(params);
  }
}
