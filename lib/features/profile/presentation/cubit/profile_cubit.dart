import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/mock_catalog.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._authRepository) : super(ProfileState(user: MockCatalog.user));

  final AuthRepository _authRepository;

  /// يقرأ مستخدم الجلسة الحالية إن وُجد، وإلا يبقى على بيانات العرض التجريبية.
  Future<void> load() async {
    final result = await _authRepository.currentUser();
    final user = result.getOrElse(() => null);
    if (user == null || isClosed) return;
    emit(state.copyWith(user: user));
  }

  Future<void> logout() async {
    await _authRepository.logout();
    if (isClosed) return;
    emit(state.copyWith(loggedOut: true));
  }
}

class ProfileState extends Equatable {
  const ProfileState({required this.user, this.loggedOut = false});

  final User user;
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
