part of 'quiz_result_cubit.dart';

enum QuizResultStatus { initial, loading, success, failure }

class QuizResultState extends Equatable {
  const QuizResultState({
    this.status = QuizResultStatus.initial,
    this.quiz,
    this.error,
  });

  final QuizResultStatus status;
  final QuizDetails? quiz;
  final String? error;

  QuizResultState copyWith({
    QuizResultStatus? status,
    QuizDetails? quiz,
    String? error,
  }) {
    return QuizResultState(
      status: status ?? this.status,
      quiz: quiz ?? this.quiz,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, quiz, error];
}
