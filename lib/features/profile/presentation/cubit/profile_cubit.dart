import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/profile_image.dart';
import '../../../auth/domain/entities/profile_update.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../../auth/domain/usecases/refresh_profile.dart';
import '../../../auth/domain/usecases/update_profile.dart';
import '../../../auth/domain/usecases/update_profile_image.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this._getCurrentUser,
    required this._refreshProfile,
    required this._updateProfile,
    required this._updateProfileImage,
    required this._logout,
  }) : super(const ProfileState());

  final GetCurrentUser _getCurrentUser;
  final RefreshProfile _refreshProfile;
  final UpdateProfile _updateProfile;
  final UpdateProfileImage _updateProfileImage;
  final Logout _logout;

  /// يعرض مستخدم الجلسة المحفوظ فوراً، ثم نسخته المحدّثة من الخادم.
  /// الموجّه يمنع فتح الصفحة بلا جلسة.
  Future<void> load() async {
    final cached = (await _getCurrentUser(const NoParams())).getOrElse(() => null);
    if (isClosed) return;
    if (cached != null) emit(state.copyWith(user: cached));

    final fresh = await _refreshProfile(const NoParams());
    if (isClosed) return;
    // فشل التحديث (انقطاع مثلاً) يُبقي النسخة المحفوظة معروضة.
    fresh.forEach((user) => emit(state.copyWith(user: user)));
  }

  /// يحفظ تعديلات الملف، والمستخدم الذي يعيده الخادم يحل محل المعروض.
  Future<void> save(ProfileUpdate update) async {
    emit(state.copyWith(saveStatus: SaveStatus.sending));
    final result = await _updateProfile(update);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(saveStatus: SaveStatus.failure, saveError: failure.message),
        (user) => state.copyWith(saveStatus: SaveStatus.done, user: user),
      ),
    );
  }

  /// يرفع صورة الملف الشخصي، ويعرض المستخدم بصورته الجديدة.
  Future<void> changeAvatar(ProfileImage image) async {
    emit(state.copyWith(avatarStatus: SaveStatus.sending));
    final result = await _updateProfileImage(image);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(avatarStatus: SaveStatus.failure, avatarError: failure.message),
        (user) => state.copyWith(avatarStatus: SaveStatus.done, user: user),
      ),
    );
  }

  Future<void> logout() async {
    await _logout(const NoParams());
    if (isClosed) return;
    emit(state.copyWith(loggedOut: true));
  }
}
