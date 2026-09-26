import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/quiz.dart';

abstract class QuizRepository {
  Future<Either<Failure, List<Quiz>>> getQuizzes();
  Future<Either<Failure, Quiz>> getQuiz(String id);
}
