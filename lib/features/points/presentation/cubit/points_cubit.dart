import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/point_record.dart';
import '../../domain/usecases/get_points_history.dart';

part 'points_state.dart';

class PointsCubit extends Cubit<PointsState> {
  PointsCubit(this._getPointsHistory) : super(const PointsState());

  final GetPointsHistory _getPointsHistory;

  Future<void> load() async {
    emit(state.copyWith(status: PointsStatus.loading));
    final result = await _getPointsHistory(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: PointsStatus.failure, error: f.message),
        (items) => state.copyWith(status: PointsStatus.success, items: items),
      ),
    );
  }
}
