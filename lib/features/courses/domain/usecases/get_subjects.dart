import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subject.dart';
import '../repositories/courses_repository.dart';

class GetSubjects implements UseCase<List<Subject>, NoParams> {
  const GetSubjects(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, List<Subject>>> call(NoParams params) {
    return repository.getSubjects();
  }
}
