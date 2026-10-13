import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/quiz.dart';

abstract class QuizRepository {
  Future<Either<Failure, List<Quiz>>> getMyExams();
  Future<Either<Failure, List<Quiz>>> getMyActivities();
  Future<Either<Failure, QuizDetails>> getQuiz(String id);
  Future<Either<Failure, QuizScore>> attendExam(List<String> answerIds);
}
