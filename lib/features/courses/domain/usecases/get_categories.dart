import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/course.dart';
import '../repositories/courses_repository.dart';

class GetCategories implements UseCase<List<Category>, NoParams> {
  const GetCategories(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) {
    return repository.getCategories();
  }
}
