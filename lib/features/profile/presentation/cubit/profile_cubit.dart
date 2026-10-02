import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../auth/domain/usecases/refresh_profile_usecase.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this._getCurrentUser,
    required this._refreshProfile,
    required this._logout,
  }) : super(const ProfileState());

  final GetCurrentUserUseCase _getCurrentUser;
  final RefreshProfileUseCase _refreshProfile;
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

  Future<void> logout() async {
    await _logout(const NoParams());
    if (isClosed) return;
    emit(state.copyWith(loggedOut: true));
  }
}

class ProfileState extends Equatable {
  const ProfileState({this.user, this.loggedOut = false});

  /// `null` إلى أن تُقرأ الجلسة.
  final User? user;
  final bool loggedOut;

  ProfileState copyWith({User? user, bool? loggedOut}) {
    return ProfileState(
      user: user ?? this.user,
      loggedOut: loggedOut ?? this.loggedOut,
    );
  }

  @override
  List<Object?> get props => [user, loggedOut];
}
