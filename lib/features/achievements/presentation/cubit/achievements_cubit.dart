import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/usecases/refresh_profile.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/usecases/get_my_courses.dart';

part 'achievements_state.dart';

/// شاشة الإنجازات فوق `profile/get` و`subscriptions/my`: الملف ونسب المواد،
/// بلا شبكة أوسمة وهمية لأن `profile/points|medals|cups` فارغة.
class AchievementsCubit extends Cubit<AchievementsState> {
  AchievementsCubit({
    required this._getCurrentUser,
    required this._refreshProfile,
    required this._getMyCourses,
  }) : super(const AchievementsState());

  final GetCurrentUser _getCurrentUser;
  final RefreshProfile _refreshProfile;
  final GetMyCourses _getMyCourses;

  Future<void> load() async {
    emit(state.copyWith(status: AchievementsStatus.loading));
    final (cached, fresh, courses) = await (
      _getCurrentUser(const NoParams()),
      _refreshProfile(const NoParams()),
      _getMyCourses(const NoParams()),
    ).wait;
    if (isClosed) return;

    emit(
      courses.fold(
        (failure) => state.copyWith(status: AchievementsStatus.failure, error: failure.message),
        (items) => state.copyWith(
          status: AchievementsStatus.success,
          user: fresh.fold((_) => cached.getOrElse(() => null), (user) => user),
          courses: items,
        ),
      ),
    );
  }
}
