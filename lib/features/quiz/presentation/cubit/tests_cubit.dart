import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/usecases/get_my_activities.dart';
import '../../domain/usecases/get_my_exams.dart';

part 'tests_state.dart';

/// شاشة «اختباراتي»: قائمتا الاختبارات والنشاطات من مسارَين منفصلين.
class TestsCubit extends Cubit<TestsState> {
  TestsCubit({required this._getMyExams, required this._getMyActivities}) : super(const TestsState());

  final GetMyExams _getMyExams;
  final GetMyActivities _getMyActivities;

  Future<void> load() async {
    emit(state.copyWith(status: TestsStatus.loading));
    final exams = await _getMyExams(const NoParams());
    if (isClosed) return;
    final failed = exams.fold<TestsState?>(
      (f) => state.copyWith(status: TestsStatus.failure, error: f.message),
      (_) => null,
    );
    if (failed != null) {
      emit(failed);
      return;
    }
    final activities = await _getMyActivities(const NoParams());
    if (isClosed) return;
    emit(
      activities.fold(
        (f) => state.copyWith(status: TestsStatus.failure, error: f.message),
        (list) => state.copyWith(
          status: TestsStatus.success,
          exams: exams.getOrElse(() => const []),
          activities: list,
        ),
      ),
    );
  }
}
