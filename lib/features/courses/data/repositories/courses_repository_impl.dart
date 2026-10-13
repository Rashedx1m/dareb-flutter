import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_details.dart';
import '../../domain/entities/lesson_details.dart';
import '../../domain/entities/search_results.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/subject_details.dart';
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

  /// التعليق الفارغ لا يُرسل.
  @override
  Future<Either<Failure, void>> addComment(NewComment comment) async {
    final text = comment.text.trim();
    if (text.isEmpty) return const Left(ValidationFailure(AppStrings.errorCommentRequired));
    return guard(() => _remote.addComment(comment.lessonId, text));
  }

  @override
  Future<Either<Failure, List<Subject>>> getSubjects() => guard(_remote.getSubjects);

  @override
  Future<Either<Failure, SubjectDetails>> getSubjectDetails(String subjectId) {
    return guard(() => _remote.getSubjectDetails(subjectId));
  }

  /// الخادم يعيد كل المواد لنص فارغ، فلا يُرسل.
  @override
  Future<Either<Failure, SearchResults>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const Right(SearchResults.empty);
    return guard(() => _remote.search(trimmed));
  }
}
