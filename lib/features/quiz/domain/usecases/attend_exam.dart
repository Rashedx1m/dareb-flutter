import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class AttendExam implements UseCase<QuizScore, List<String>> {
  const AttendExam(this.repository);
  final QuizRepository repository;

  @override
  Future<Either<Failure, QuizScore>> call(List<String> params) {
    return repository.attendExam(params);
  }
}
