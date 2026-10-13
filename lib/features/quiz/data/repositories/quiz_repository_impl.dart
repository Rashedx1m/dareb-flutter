import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_remote_data_source.dart';

class QuizRepositoryImpl implements QuizRepository {
  const QuizRepositoryImpl(this._remote);
  final QuizRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Quiz>>> getMyExams() => guard(_remote.getMyExams);

  @override
  Future<Either<Failure, List<Quiz>>> getMyActivities() => guard(_remote.getMyActivities);

  @override
  Future<Either<Failure, QuizDetails>> getQuiz(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return const Left(ValidationFailure(AppStrings.errorExamRequired));
    return guard(() => _remote.getQuiz(trimmed));
  }

  @override
  Future<Either<Failure, QuizScore>> attendExam(List<String> answerIds) async {
    if (answerIds.isEmpty) return const Left(ValidationFailure(AppStrings.errorAnswersRequired));
    return guard(() => _remote.attendExam(answerIds));
  }
}
