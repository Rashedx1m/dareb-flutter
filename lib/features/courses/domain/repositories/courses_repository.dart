import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/comment.dart';
import '../entities/course.dart';
import '../entities/course_details.dart';
import '../entities/lesson_details.dart';
import '../entities/search_results.dart';
import '../entities/subject.dart';
import '../entities/subject_details.dart';

abstract class CoursesRepository {
  Future<Either<Failure, List<Course>>> getCourses();
  Future<Either<Failure, List<Course>>> getMyCourses();
  Future<Either<Failure, CourseDetails>> getCourseDetails(String subjectId);
  Future<Either<Failure, LessonDetails>> getLesson(String lessonId);
  Future<Either<Failure, void>> attendLesson(String lessonId);
  Future<Either<Failure, void>> addComment(NewComment comment);
  Future<Either<Failure, List<Subject>>> getSubjects();
  Future<Either<Failure, SubjectDetails>> getSubjectDetails(String subjectId);
  Future<Either<Failure, SearchResults>> search(String query);
}
