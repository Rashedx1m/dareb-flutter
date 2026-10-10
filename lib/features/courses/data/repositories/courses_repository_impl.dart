import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_details.dart';
import '../../domain/entities/lesson_details.dart';
import '../../domain/entities/subject.dart';
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
  Future<Either<Failure, CourseDetails>> getCourseDetails(String subjectId) {
    return guard(() => _remote.getCourseDetails(subjectId));
  }

  @override
  Future<Either<Failure, LessonDetails>> getLesson(String lessonId) => guard(() => _remote.getLesson(lessonId));

  @override
  Future<Either<Failure, void>> attendLesson(String lessonId) => guard(() => _remote.attendLesson(lessonId));

  @override
  Future<Either<Failure, List<Subject>>> getSubjects() => guard(_remote.getSubjects);

  /// الخادم يعيد كل المواد لنص فارغ، فلا يُرسل.
  @override
  Future<Either<Failure, List<Subject>>> searchSubjects(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const Right([]);
    return guard(() => _remote.searchSubjects(trimmed));
  }
}
