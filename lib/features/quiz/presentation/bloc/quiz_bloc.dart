import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/usecases/get_my_activities.dart';
import '../../domain/usecases/get_my_exams.dart';
import '../../domain/usecases/get_quiz.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc({
    required this._getMyExams,
    required this._getMyActivities,
    required this._getQuiz,
  }) : super(const QuizState()) {
    on<QuizzesStarted>(_onStarted);
    on<QuizOpened>(_onOpened);
    on<QuizAnswerSelected>(_onAnswered);
    on<QuizNextPressed>(_onNext);
  }

  final GetMyExams _getMyExams;
  final GetMyActivities _getMyActivities;
  final GetQuiz _getQuiz;

  Future<void> _onStarted(QuizzesStarted event, Emitter<QuizState> emit) async {
    emit(state.copyWith(status: QuizStatus.loading));
    final exams = await _getMyExams(const NoParams());
    if (isClosed) return;
    final activities = await _getMyActivities(const NoParams());
    if (isClosed) return;
    emit(
      exams.fold(
        (f) => state.copyWith(status: QuizStatus.failure, error: f.message),
        (examList) => activities.fold(
          (f) => state.copyWith(status: QuizStatus.failure, error: f.message),
          (activityList) => state.copyWith(status: QuizStatus.success, quizzes: [...examList, ...activityList]),
        ),
      ),
    );
  }

  Future<void> _onOpened(QuizOpened event, Emitter<QuizState> emit) async {
    emit(state.copyWith(status: QuizStatus.loading, answers: {}, currentIndex: 0));
    final result = await _getQuiz(event.id);
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: QuizStatus.failure, error: f.message),
        (quiz) => state.copyWith(status: QuizStatus.taking, current: quiz),
      ),
    );
  }

  void _onAnswered(QuizAnswerSelected event, Emitter<QuizState> emit) {
    final answers = Map<int, int>.from(state.answers)..[event.questionIndex] = event.optionIndex;
    emit(state.copyWith(answers: answers));
  }

  void _onNext(QuizNextPressed event, Emitter<QuizState> emit) {
    final quiz = state.current;
    if (quiz == null) return;
    if (state.currentIndex + 1 >= quiz.questions.length) {
      var correct = 0;
      for (var i = 0; i < quiz.questions.length; i++) {
        final selected = state.answers[i];
        if (selected != null && quiz.questions[i].answers[selected].isCorrect) correct++;
      }
      emit(state.copyWith(status: QuizStatus.completed, score: correct));
      return;
    }
    emit(state.copyWith(currentIndex: state.currentIndex + 1));
  }
}
