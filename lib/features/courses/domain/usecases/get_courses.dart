import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/course.dart';
import '../repositories/courses_repository.dart';

class GetCourses implements UseCase<List<Course>, NoParams> {
  const GetCourses(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, List<Course>>> call(NoParams params) {
    return repository.getCourses();
  }
}
