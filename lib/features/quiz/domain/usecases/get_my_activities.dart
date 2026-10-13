import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class GetMyActivities implements UseCase<List<Quiz>, NoParams> {
  const GetMyActivities(this.repository);
  final QuizRepository repository;

  @override
  Future<Either<Failure, List<Quiz>>> call(NoParams params) {
    return repository.getMyActivities();
  }
}
