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

class GetMyCourses implements UseCase<List<Course>, NoParams> {
  const GetMyCourses(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, List<Course>>> call(NoParams params) {
    return repository.getMyCourses();
  }
}

class GetCourse implements UseCase<Course, String> {
  const GetCourse(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, Course>> call(String params) {
    return repository.getCourse(params);
  }
}

class GetCategories implements UseCase<List<Category>, NoParams> {
  const GetCategories(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) {
    return repository.getCategories();
  }
}

class SearchCourses implements UseCase<List<Course>, String> {
  const SearchCourses(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, List<Course>>> call(String params) {
    return repository.searchCourses(params);
  }
}
