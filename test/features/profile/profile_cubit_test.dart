import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:educational_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:educational_app/features/auth/domain/usecases/refresh_profile_usecase.dart';
import 'package:educational_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = User(id: 'u1', name: 'أحمد', phone: '0501234567');
const _fresh = User(id: 'u1', name: 'أحمد', phone: '0501234567', points: 120);

class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository(this.user, {this.refreshed = const Right(_fresh)});

  User? user;

  /// رد `profile/get`.
  final Either<Failure, User> refreshed;

  @override
  Future<Either<Failure, User?>> currentUser() async => Right(user);

  @override
  Future<Either<Failure, User>> refreshProfile() async => refreshed;

  @override
  Future<Either<Failure, void>> logout() async {
    user = null;
    return const Right(null);
  }
}

ProfileCubit _cubit(_FakeAuthRepository repository) => ProfileCubit(
      getCurrentUser: GetCurrentUserUseCase(repository),
      refreshProfile: RefreshProfileUseCase(repository),
      logout: LogoutUseCase(repository),
    );

void main() {
  test('يعرض المستخدم المحفوظ فوراً ثم نسخته المحدّثة من الخادم', () async {
    final cubit = _cubit(_FakeAuthRepository(_user));
    expect(cubit.state.user, isNull);

    final users = cubit.stream.map((state) => state.user).take(2).toList();
    await cubit.load();

    expect(await users, [_user, _fresh]);
  });

  test('فشل التحديث يُبقي المستخدم المحفوظ معروضاً', () async {
    final cubit = _cubit(
      _FakeAuthRepository(_user, refreshed: const Left(ServerFailure('تعذّر الاتصال بالخادم'))),
    );

    await cubit.load();

    expect(cubit.state.user, _user);
  });

  test('logout ينهي الجلسة ويضبط loggedOut', () async {
    final repository = _FakeAuthRepository(_user);
    final cubit = _cubit(repository);
    await cubit.logout();

    expect(repository.user, isNull);
    expect(cubit.state.loggedOut, isTrue);
  });
}
