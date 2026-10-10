import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subject.dart';
import '../repositories/courses_repository.dart';

/// يبحث في أسماء المواد. نص فارغ يعطي قائمة فارغة دون طلب.
class SearchSubjects implements UseCase<List<Subject>, String> {
  const SearchSubjects(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, List<Subject>>> call(String query) {
    return repository.searchSubjects(query);
  }
}
