import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/course.dart';
import '../../domain/usecases/get_courses.dart';

part 'courses_event.dart';
part 'courses_state.dart';

class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  CoursesBloc({
    required this._getCourses,
    required this._getCourse,
    required this._searchCourses,
    required this._getCategories,
  }) : super(const CoursesState()) {
    on<CoursesStarted>(_onStarted);
    on<CourseOpened>(_onOpened);
    on<CoursesSearched>(_onSearched);
    on<CoursesCategoryFiltered>(_onFiltered);
  }

  final GetCourses _getCourses;
  final GetCourse _getCourse;
  final SearchCourses _searchCourses;
  final GetCategories _getCategories;

  Future<void> _onStarted(CoursesStarted event, Emitter<CoursesState> emit) async {
    emit(state.copyWith(status: CoursesStatus.loading));
    final courses = await _getCourses(const NoParams());
    final categories = await _getCategories(const NoParams());
    courses.fold(
      (f) => emit(state.copyWith(status: CoursesStatus.failure, error: f.message)),
      (list) {
        categories.fold(
          (f) => emit(state.copyWith(status: CoursesStatus.failure, error: f.message)),
          (cats) => emit(
            state.copyWith(
              status: CoursesStatus.success,
              courses: list,
              filtered: list,
              categories: cats,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onOpened(CourseOpened event, Emitter<CoursesState> emit) async {
    emit(state.copyWith(status: CoursesStatus.loading));
    final result = await _getCourse(event.id);
    result.fold(
      (f) => emit(state.copyWith(status: CoursesStatus.failure, error: f.message)),
      (course) => emit(state.copyWith(status: CoursesStatus.success, selected: course)),
    );
  }

  Future<void> _onSearched(CoursesSearched event, Emitter<CoursesState> emit) async {
    final result = await _searchCourses(event.query);
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (list) => emit(state.copyWith(filtered: list, query: event.query)),
    );
  }

  void _onFiltered(CoursesCategoryFiltered event, Emitter<CoursesState> emit) {
    final filtered = event.categoryId == null
        ? state.courses
        : state.courses.where((c) => c.categoryId == event.categoryId).toList();
    emit(state.copyWith(filtered: filtered, selectedCategoryId: event.categoryId));
  }
}
