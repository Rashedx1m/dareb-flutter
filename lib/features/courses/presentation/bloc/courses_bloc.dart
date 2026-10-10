import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_details.dart';
import '../../domain/usecases/get_course_details.dart';
import '../../domain/usecases/get_courses.dart';
import '../../domain/usecases/search_courses.dart';

part 'courses_event.dart';
part 'courses_state.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  CoursesBloc({
    required this._getCourses,
    required this._getCourseDetails,
    required this._searchCourses,
  }) : super(const CoursesState()) {
    on<CoursesStarted>(_onStarted);
    on<CourseOpened>(_onOpened);
    on<CoursesSearched>(_onSearched);
  }

  final GetCourses _getCourses;
  final GetCourseDetails _getCourseDetails;
  final SearchCourses _searchCourses;

  Future<void> _onStarted(CoursesStarted event, Emitter<CoursesState> emit) async {
    emit(state.copyWith(status: CoursesStatus.loading));
    final result = await _getCourses(const NoParams());
    result.fold(
      (f) => emit(state.copyWith(status: CoursesStatus.failure, error: f.message)),
      (list) => emit(state.copyWith(status: CoursesStatus.success, courses: list, filtered: list)),
    );
  }

  Future<void> _onOpened(CourseOpened event, Emitter<CoursesState> emit) async {
    emit(state.copyWith(status: CoursesStatus.loading));
    final result = await _getCourseDetails(event.id);
    result.fold(
      (f) => emit(state.copyWith(status: CoursesStatus.failure, error: f.message)),
      (details) => emit(state.copyWith(status: CoursesStatus.success, selected: details)),
    );
  }

  Future<void> _onSearched(CoursesSearched event, Emitter<CoursesState> emit) async {
    final result = await _searchCourses(event.query);
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (list) => emit(state.copyWith(filtered: list, query: event.query)),
    );
  }
}
