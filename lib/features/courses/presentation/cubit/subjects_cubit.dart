import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/subject.dart';
import '../../domain/usecases/get_subjects.dart';

part 'subjects_state.dart';

/// صفحة المواد (`/categories`).
class SubjectsCubit extends Cubit<SubjectsState> {
  SubjectsCubit(this._getSubjects) : super(const SubjectsState());

  final GetSubjects _getSubjects;

  Future<void> load() async {
    emit(state.copyWith(status: SubjectsStatus.loading));
    final result = await _getSubjects(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: SubjectsStatus.failure, error: f.message),
        (subjects) => state.copyWith(status: SubjectsStatus.success, subjects: subjects),
      ),
    );
  }
}
