import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/course.dart';
import '../repositories/courses_repository.dart';

class SearchCourses implements UseCase<List<Course>, String> {
  const SearchCourses(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, List<Course>>> call(String params) {
    return repository.searchCourses(params);
  }
}
