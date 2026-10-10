import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/course.dart';
import '../entities/course_details.dart';
import '../entities/lesson_details.dart';
import '../entities/subject.dart';

abstract class CoursesRepository {
  Future<Either<Failure, List<Course>>> getCourses();
  Future<Either<Failure, List<Course>>> getMyCourses();
  Future<Either<Failure, CourseDetails>> getCourseDetails(String subjectId);
  Future<Either<Failure, LessonDetails>> getLesson(String lessonId);
  Future<Either<Failure, void>> attendLesson(String lessonId);
  Future<Either<Failure, List<Subject>>> getSubjects();
  Future<Either<Failure, List<Subject>>> searchSubjects(String query);
}
