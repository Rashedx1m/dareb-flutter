part of 'courses_bloc.dart';

enum CoursesStatus { initial, loading, success, failure }

class CoursesState extends Equatable {
  const CoursesState({
    this.status = CoursesStatus.initial,
    this.courses = const [],
    this.filtered = const [],
    this.selected,
    this.query = '',
    this.error,
  });

  final CoursesStatus status;
  final List<Course> courses;
  final List<Course> filtered;
  final CourseDetails? selected;
  final String query;
  final String? error;

  CoursesState copyWith({
    CoursesStatus? status,
    List<Course>? courses,
    List<Course>? filtered,
    CourseDetails? selected,
    String? query,
    String? error,
  }) {
    return CoursesState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      filtered: filtered ?? this.filtered,
      selected: selected ?? this.selected,
      query: query ?? this.query,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, courses, filtered, selected, query, error];
}
