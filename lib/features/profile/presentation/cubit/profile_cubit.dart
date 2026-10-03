import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/profile_image.dart';
import '../../../auth/domain/entities/profile_update.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../auth/domain/usecases/refresh_profile_usecase.dart';
import '../../../auth/domain/usecases/update_profile_image_usecase.dart';
import '../../../auth/domain/usecases/update_profile_usecase.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this._getCurrentUser,
    required this._refreshProfile,
    required this._updateProfile,
    required this._updateProfileImage,
    required this._logout,
  }) : super(const ProfileState());

  final GetCurrentUserUseCase _getCurrentUser;
  final RefreshProfileUseCase _refreshProfile;
  final UpdateProfileUseCase _updateProfile;
  final UpdateProfileImageUseCase _updateProfileImage;
  final LogoutUseCase _logout;

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
    emit(state.copyWith(saveStatus: SaveStatus.saving));
    final result = await _updateProfile(update);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(saveStatus: SaveStatus.failure, saveError: failure.message),
        (user) => state.copyWith(saveStatus: SaveStatus.saved, user: user),
      ),
    );
  }

  /// يرفع صورة الملف الشخصي، ويعرض المستخدم بصورته الجديدة.
  Future<void> changeAvatar(ProfileImage image) async {
    emit(state.copyWith(avatarStatus: SaveStatus.saving));
    final result = await _updateProfileImage(image);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(avatarStatus: SaveStatus.failure, avatarError: failure.message),
        (user) => state.copyWith(avatarStatus: SaveStatus.saved, user: user),
      ),
    );
  }

  Future<void> logout() async {
    await _logout(const NoParams());
    if (isClosed) return;
    emit(state.copyWith(loggedOut: true));
  }
}

enum SaveStatus { idle, saving, saved, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.user,
    this.loggedOut = false,
    this.saveStatus = SaveStatus.idle,
    this.saveError,
    this.avatarStatus = SaveStatus.idle,
    this.avatarError,
  });

  /// `null` إلى أن تُقرأ الجلسة.
  final User? user;
  final bool loggedOut;

  /// حالة حفظ ورقة التعديل.
  final SaveStatus saveStatus;
  final String? saveError;

  /// حالة رفع صورة الملف الشخصي.
  final SaveStatus avatarStatus;
  final String? avatarError;

  ProfileState copyWith({
    User? user,
    bool? loggedOut,
    SaveStatus? saveStatus,
    String? saveError,
    SaveStatus? avatarStatus,
    String? avatarError,
  }) {
    return ProfileState(
      user: user ?? this.user,
      loggedOut: loggedOut ?? this.loggedOut,
      saveStatus: saveStatus ?? this.saveStatus,
      // الرسائل لا تُعرض إلا مع حالة failure الخاصة بها، فبقاؤها آمن.
      saveError: saveError ?? this.saveError,
      avatarStatus: avatarStatus ?? this.avatarStatus,
      avatarError: avatarError ?? this.avatarError,
    );
  }

  @override
  List<Object?> get props => [user, loggedOut, saveStatus, saveError, avatarStatus, avatarError];
}
