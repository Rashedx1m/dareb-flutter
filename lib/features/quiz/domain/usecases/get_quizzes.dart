import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class GetQuizzes implements UseCase<List<Quiz>, NoParams> {
  const GetQuizzes(this.repository);
  final QuizRepository repository;

  @override
  Future<Either<Failure, List<Quiz>>> call(NoParams params) {
    return repository.getQuizzes();
  }
}

class GetQuiz implements UseCase<Quiz, String> {
  const GetQuiz(this.repository);
  final QuizRepository repository;

  @override
  Future<Either<Failure, Quiz>> call(String params) {
    return repository.getQuiz(params);
  }
}
