import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/profile_update.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../auth/domain/usecases/refresh_profile_usecase.dart';
import '../../../auth/domain/usecases/update_profile_usecase.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this._getCurrentUser,
    required this._refreshProfile,
    required this._updateProfile,
    required this._logout,
  }) : super(const ProfileState());

  final GetCurrentUserUseCase _getCurrentUser;
  final RefreshProfileUseCase _refreshProfile;
  final UpdateProfileUseCase _updateProfile;
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
  });

  /// `null` إلى أن تُقرأ الجلسة.
  final User? user;
  final bool loggedOut;

  /// حالة حفظ صفحة التعديل.
  final SaveStatus saveStatus;
  final String? saveError;

  ProfileState copyWith({
    User? user,
    bool? loggedOut,
    SaveStatus? saveStatus,
    String? saveError,
  }) {
    return ProfileState(
      user: user ?? this.user,
      loggedOut: loggedOut ?? this.loggedOut,
      saveStatus: saveStatus ?? this.saveStatus,
      // الرسالة لا تُعرض إلا مع حالة failure، فبقاؤها آمن.
      saveError: saveError ?? this.saveError,
    );
  }

  @override
  List<Object?> get props => [user, loggedOut, saveStatus, saveError];
}
