import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subject_details.dart';
import '../repositories/courses_repository.dart';

/// صفحة المادة بمعرّفها: دورتها واختباراتها ونشاطاتها اليومية.
class GetSubjectDetails implements UseCase<SubjectDetails, String> {
  const GetSubjectDetails(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, SubjectDetails>> call(String subjectId) {
    return repository.getSubjectDetails(subjectId);
  }
}
