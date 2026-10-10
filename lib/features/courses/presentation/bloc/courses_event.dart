part of 'courses_bloc.dart';

abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object?> get props => [];
}

class CoursesStarted extends CoursesEvent {
  const CoursesStarted();
}

class CourseOpened extends CoursesEvent {
  const CourseOpened(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class CoursesSearched extends CoursesEvent {
  const CoursesSearched(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}
