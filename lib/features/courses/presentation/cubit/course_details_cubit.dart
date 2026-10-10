import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/course_details.dart';
import '../../domain/usecases/get_course_details.dart';

part 'course_details_state.dart';

/// صفحة الدورة (`/courses/:id`) بفصولها ودروسها.
class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  CourseDetailsCubit(this._getCourseDetails) : super(const CourseDetailsState());

  final GetCourseDetails _getCourseDetails;

  /// [subjectId] هو معرّف المادة الذي تحمله بطاقة الدورة.
  Future<void> load(String subjectId) async {
    emit(state.copyWith(status: CourseDetailsStatus.loading));
    final result = await _getCourseDetails(subjectId);
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: CourseDetailsStatus.failure, error: f.message),
        (details) => state.copyWith(status: CourseDetailsStatus.success, details: details),
      ),
    );
  }
}
