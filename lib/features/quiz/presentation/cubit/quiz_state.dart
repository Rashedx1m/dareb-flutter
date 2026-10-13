part of 'quiz_cubit.dart';

enum QuizStatus { initial, loading, success, failure }

enum AttendStatus { idle, sending, done, failure }

class QuizState extends Equatable {
  const QuizState({
    this.status = QuizStatus.initial,
    this.quiz,
    this.selected = const {},
    this.attend = AttendStatus.idle,
    this.error,
    this.attendError,
  });

  final QuizStatus status;
  final QuizDetails? quiz;

  /// معرّف السؤال إلى معرّف الخيار المختار.
  final Map<String, String> selected;
  final AttendStatus attend;
  final String? error;
  final String? attendError;

  QuizState copyWith({
    QuizStatus? status,
    QuizDetails? quiz,
    Map<String, String>? selected,
    AttendStatus? attend,
    String? error,
    String? attendError,
  }) {
    return QuizState(
      status: status ?? this.status,
      quiz: quiz ?? this.quiz,
      selected: selected ?? this.selected,
      attend: attend ?? this.attend,
      error: error,
      attendError: attendError,
    );
  }

  @override
  List<Object?> get props => [status, quiz, selected, attend, error, attendError];
}
