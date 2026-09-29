import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/course.dart';
import '../../domain/usecases/get_courses.dart';

part 'my_courses_state.dart';

/// الدورات التي بدأها المستخدم (صفحة «دوراتي»).
class MyCoursesCubit extends Cubit<MyCoursesState> {
  MyCoursesCubit(this._getMyCourses) : super(const MyCoursesState());

  final GetMyCourses _getMyCourses;

  Future<void> load() async {
    emit(state.copyWith(status: MyCoursesStatus.loading));
    final result = await _getMyCourses(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: MyCoursesStatus.failure, error: f.message),
        (courses) => state.copyWith(status: MyCoursesStatus.success, courses: courses),
      ),
    );
  }
}
