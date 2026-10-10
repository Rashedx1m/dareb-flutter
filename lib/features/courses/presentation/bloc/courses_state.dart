part of 'courses_bloc.dart';

enum CoursesStatus { initial, loading, success, failure }

class CoursesState extends Equatable {
  const CoursesState({
    this.status = CoursesStatus.initial,
    this.courses = const [],
    this.filtered = const [],
    this.subjects = const [],
    this.selected,
    this.query = '',
    this.selectedCategoryId,
    this.error,
  });

  final CoursesStatus status;
  final List<Course> courses;
  final List<Course> filtered;
  final List<Subject> subjects;
  final Course? selected;
  final String query;
  final String? selectedCategoryId;
  final String? error;

  CoursesState copyWith({
    CoursesStatus? status,
    List<Course>? courses,
    List<Course>? filtered,
    List<Subject>? subjects,
    Course? selected,
    String? query,
    String? selectedCategoryId,
    String? error,
  }) {
    return CoursesState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      filtered: filtered ?? this.filtered,
      subjects: subjects ?? this.subjects,
      selected: selected ?? this.selected,
      query: query ?? this.query,
      selectedCategoryId: selectedCategoryId,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        courses,
        filtered,
        subjects,
        selected,
        query,
        selectedCategoryId,
        error,
      ];
}
