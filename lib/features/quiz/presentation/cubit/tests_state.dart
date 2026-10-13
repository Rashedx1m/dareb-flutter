part of 'tests_cubit.dart';

enum TestsStatus { initial, loading, success, failure }

class TestsState extends Equatable {
  const TestsState({
    this.status = TestsStatus.initial,
    this.exams = const [],
    this.activities = const [],
    this.error,
  });

  final TestsStatus status;
  final List<Quiz> exams;
  final List<Quiz> activities;
  final String? error;

  TestsState copyWith({
    TestsStatus? status,
    List<Quiz>? exams,
    List<Quiz>? activities,
    String? error,
  }) {
    return TestsState(
      status: status ?? this.status,
      exams: exams ?? this.exams,
      activities: activities ?? this.activities,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, exams, activities, error];
}
