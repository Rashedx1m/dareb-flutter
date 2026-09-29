import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/courses_repository.dart';
import '../datasources/courses_remote_data_source.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  const CoursesRepositoryImpl(this._remote);
  final CoursesRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Course>>> getCourses() => guard(_remote.getCourses);

  @override
  Future<Either<Failure, List<Course>>> getMyCourses() => guard(_remote.getMyCourses);

  @override
  Future<Either<Failure, Course>> getCourse(String id) => guard(() => _remote.getCourse(id));

  @override
  Future<Either<Failure, List<Category>>> getCategories() => guard(_remote.getCategories);

  @override
  Future<Either<Failure, List<Course>>> searchCourses(String query) {
    return guard(() => _remote.searchCourses(query));
  }
}
