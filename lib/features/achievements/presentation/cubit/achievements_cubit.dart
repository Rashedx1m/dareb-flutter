import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/usecases/get_achievements.dart';

part 'achievements_state.dart';

class AchievementsCubit extends Cubit<AchievementsState> {
  AchievementsCubit(this._getAchievements) : super(const AchievementsState());

  final GetAchievements _getAchievements;

  Future<void> load() async {
    emit(state.copyWith(status: AchievementsStatus.loading));
    final result = await _getAchievements(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: AchievementsStatus.failure, error: f.message),
        (items) => state.copyWith(status: AchievementsStatus.success, items: items),
      ),
    );
  }
}
