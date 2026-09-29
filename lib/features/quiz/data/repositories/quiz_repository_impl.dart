import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_remote_data_source.dart';

class QuizRepositoryImpl implements QuizRepository {
  const QuizRepositoryImpl(this._remote);
  final QuizRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Quiz>>> getQuizzes() => guard(_remote.getQuizzes);

  @override
  Future<Either<Failure, Quiz>> getQuiz(String id) => guard(() => _remote.getQuiz(id));
}
