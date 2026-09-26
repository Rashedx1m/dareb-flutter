part of 'quiz_bloc.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

class QuizzesStarted extends QuizEvent {
  const QuizzesStarted();
}

class QuizOpened extends QuizEvent {
  const QuizOpened(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class QuizAnswerSelected extends QuizEvent {
  const QuizAnswerSelected({required this.questionIndex, required this.optionIndex});
  final int questionIndex;
  final int optionIndex;

  @override
  List<Object?> get props => [questionIndex, optionIndex];
}

class QuizNextPressed extends QuizEvent {
  const QuizNextPressed();
}
