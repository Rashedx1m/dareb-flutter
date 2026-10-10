part of 'courses_cubit.dart';

enum CoursesStatus { initial, loading, success, failure }

class CoursesState extends Equatable {
  const CoursesState({
    this.status = CoursesStatus.initial,
    this.courses = const [],
    this.error,
  });

  final CoursesStatus status;
  final List<Course> courses;

  /// يُعرض فقط مع `failure`.
  final String? error;

  CoursesState copyWith({CoursesStatus? status, List<Course>? courses, String? error}) {
    return CoursesState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, courses, error];
}
