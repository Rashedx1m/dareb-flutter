import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/quiz.dart';
import '../../domain/usecases/attend_exam.dart';
import '../../domain/usecases/get_quiz.dart';

part 'quiz_state.dart';

/// صفحة حل الاختبار: جلب الأسئلة، اختيار إجابة لكل سؤال، ثم الحضور.
class QuizCubit extends Cubit<QuizState> {
  QuizCubit({required this._getQuiz, required this._attendExam}) : super(const QuizState());

  final GetQuiz _getQuiz;
  final AttendExam _attendExam;

  Future<void> load(String id) async {
    emit(state.copyWith(status: QuizStatus.loading));
    final result = await _getQuiz(id);
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: QuizStatus.failure, error: f.message),
        (quiz) => state.copyWith(status: QuizStatus.success, quiz: quiz, selected: const {}),
      ),
    );
  }

  void select(String questionId, String answerId) {
    emit(state.copyWith(selected: {...state.selected, questionId: answerId}));
  }

  bool get allAnswered {
    final quiz = state.quiz;
    if (quiz == null || quiz.questions.isEmpty) return false;
    return quiz.questions.every((q) => state.selected.containsKey(q.id));
  }

  Future<void> submit() async {
    if (!allAnswered || state.attend == AttendStatus.sending) return;
    emit(state.copyWith(attend: AttendStatus.sending));
    final result = await _attendExam(state.selected.values.toList());
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(attend: AttendStatus.failure, attendError: f.message),
        (_) => state.copyWith(attend: AttendStatus.done),
      ),
    );
  }
}
