import 'package:dartz/dartz.dart';

import '../../../../core/data/mock_catalog.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  @override
  Future<Either<Failure, List<Quiz>>> getQuizzes() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const Right(MockCatalog.quizzes);
  }

  @override
  Future<Either<Failure, Quiz>> getQuiz(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return Right(MockCatalog.quizzes.firstWhere((q) => q.id == id));
    } catch (_) {
      return const Left(ServerFailure('الاختبار غير موجود'));
    }
  }
}
