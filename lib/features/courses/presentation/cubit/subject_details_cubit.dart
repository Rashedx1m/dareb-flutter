import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/subject_details.dart';
import '../../domain/usecases/get_subject_details.dart';

part 'subject_details_state.dart';

/// صفحة المادة (`/categories/:id`) بتبويباتها: المحتوى والاختبارات والنشاطات اليومية.
class SubjectDetailsCubit extends Cubit<SubjectDetailsState> {
  SubjectDetailsCubit(this._getSubjectDetails) : super(const SubjectDetailsState());

  final GetSubjectDetails _getSubjectDetails;

  Future<void> load(String subjectId) async {
    emit(state.copyWith(status: SubjectDetailsStatus.loading));
    final result = await _getSubjectDetails(subjectId);
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: SubjectDetailsStatus.failure, error: f.message),
        (details) => state.copyWith(status: SubjectDetailsStatus.success, details: details),
      ),
    );
  }
}
