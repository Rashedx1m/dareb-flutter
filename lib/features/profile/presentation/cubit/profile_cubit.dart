import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this._getCurrentUser, required this._logout})
      : super(const ProfileState());

  final GetCurrentUserUseCase _getCurrentUser;
  final LogoutUseCase _logout;

  /// يقرأ مستخدم الجلسة الحالية. الموجّه يمنع فتح الصفحة بلا جلسة.
  Future<void> load() async {
    final result = await _getCurrentUser(const NoParams());
    final user = result.getOrElse(() => null);
    if (user == null || isClosed) return;
    emit(state.copyWith(user: user));
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
