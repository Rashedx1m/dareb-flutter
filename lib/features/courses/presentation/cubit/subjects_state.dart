part of 'subjects_cubit.dart';

enum SubjectsStatus { initial, loading, success, failure }

class SubjectsState extends Equatable {
  const SubjectsState({
    this.status = SubjectsStatus.initial,
    this.subjects = const [],
    this.error,
  });

  final SubjectsStatus status;
  final List<Subject> subjects;

  /// يُعرض فقط مع `failure`.
  final String? error;

  SubjectsState copyWith({SubjectsStatus? status, List<Subject>? subjects, String? error}) {
    return SubjectsState(
      status: status ?? this.status,
      subjects: subjects ?? this.subjects,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, subjects, error];
}
