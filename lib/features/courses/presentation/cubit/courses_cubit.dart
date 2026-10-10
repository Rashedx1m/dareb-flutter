import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/course.dart';
import '../../domain/usecases/get_courses.dart';

part 'courses_state.dart';

/// صفحة كل الدورات (`/courses`).
class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit(this._getCourses) : super(const CoursesState());

  final GetCourses _getCourses;

  Future<void> load() async {
    emit(state.copyWith(status: CoursesStatus.loading));
    final result = await _getCourses(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: CoursesStatus.failure, error: f.message),
        (courses) => state.copyWith(status: CoursesStatus.success, courses: courses),
      ),
    );
  }
}
