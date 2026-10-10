import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/course_details.dart';
import '../repositories/courses_repository.dart';

/// معامله معرّف المادة، فهو معرّف الدورة نفسه.
class GetCourseDetails implements UseCase<CourseDetails, String> {
  const GetCourseDetails(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, CourseDetails>> call(String subjectId) {
    return repository.getCourseDetails(subjectId);
  }
}
