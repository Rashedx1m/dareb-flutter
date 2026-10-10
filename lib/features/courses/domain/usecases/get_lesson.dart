import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lesson_details.dart';
import '../repositories/courses_repository.dart';

class GetLesson implements UseCase<LessonDetails, String> {
  const GetLesson(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, LessonDetails>> call(String lessonId) {
    return repository.getLesson(lessonId);
  }
}
