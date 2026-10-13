import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/quiz.dart';
import '../../domain/usecases/get_quiz.dart';

part 'quiz_result_state.dart';

/// شاشتا النتيجة والمراجعة: تجلبان `exams/result` بمعرّف المسار.
class QuizResultCubit extends Cubit<QuizResultState> {
  QuizResultCubit(this._getQuiz) : super(const QuizResultState());

  final GetQuiz _getQuiz;

  Future<void> load(String id) async {
    emit(state.copyWith(status: QuizResultStatus.loading));
    final result = await _getQuiz(id);
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: QuizResultStatus.failure, error: f.message),
        (quiz) => state.copyWith(status: QuizResultStatus.success, quiz: quiz),
      ),
    );
  }
}
