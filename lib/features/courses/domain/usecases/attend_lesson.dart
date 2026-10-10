import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/courses_repository.dart';

/// يسجّل حضور الدرس، فيصير `isAttended` وترتفع نسب الإنجاز في الفصل والمادة.
class AttendLesson implements UseCase<void, String> {
  const AttendLesson(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, void>> call(String lessonId) {
    return repository.attendLesson(lessonId);
  }
}
