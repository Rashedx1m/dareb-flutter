import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class GetQuiz implements UseCase<QuizDetails, String> {
  const GetQuiz(this.repository);
  final QuizRepository repository;

  @override
  Future<Either<Failure, QuizDetails>> call(String params) {
    return repository.getQuiz(params);
  }
}
