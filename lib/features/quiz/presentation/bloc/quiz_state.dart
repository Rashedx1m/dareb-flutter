part of 'quiz_bloc.dart';

enum QuizStatus { initial, loading, success, taking, completed, failure }

class QuizState extends Equatable {
  const QuizState({
    this.status = QuizStatus.initial,
    this.quizzes = const [],
    this.current,
    this.currentIndex = 0,
    this.answers = const {},
    this.score = 0,
    this.error,
  });

  final QuizStatus status;
  final List<Quiz> quizzes;
  final QuizDetails? current;
  final int currentIndex;
  final Map<int, int> answers;
  final int score;
  final String? error;

  QuizState copyWith({
    QuizStatus? status,
    List<Quiz>? quizzes,
    QuizDetails? current,
    int? currentIndex,
    Map<int, int>? answers,
    int? score,
    String? error,
  }) {
    return QuizState(
      status: status ?? this.status,
      quizzes: quizzes ?? this.quizzes,
      current: current ?? this.current,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, quizzes, current, currentIndex, answers, score, error];
}
