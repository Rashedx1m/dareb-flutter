part of 'my_courses_cubit.dart';

enum MyCoursesStatus { initial, loading, success, failure }

class MyCoursesState extends Equatable {
  const MyCoursesState({
    this.status = MyCoursesStatus.initial,
    this.courses = const [],
    this.error,
  });

  final MyCoursesStatus status;
  final List<Course> courses;
  final String? error;

  MyCoursesState copyWith({
    MyCoursesStatus? status,
    List<Course>? courses,
    String? error,
  }) {
    return MyCoursesState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, courses, error];
}
