import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/domain/entities/profile_image.dart';
import 'package:educational_app/features/auth/domain/entities/profile_update.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:educational_app/features/auth/domain/usecases/logout.dart';
import 'package:educational_app/features/auth/domain/usecases/refresh_profile.dart';
import 'package:educational_app/features/auth/domain/usecases/update_profile.dart';
import 'package:educational_app/features/auth/domain/usecases/update_profile_image.dart';
import 'package:educational_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = User(id: 'u1', name: 'أحمد', phone: '0501234567');
const _fresh = User(id: 'u1', name: 'أحمد', phone: '0501234567', points: 120);
const _renamed = User(id: 'u1', name: 'أحمد علي', phone: '0501234567');
const _withAvatar = User(id: 'u1', name: 'أحمد', phone: '0501234567', avatarUrl: 'https://x/storage/14/avatar.jpg');
const _update = ProfileUpdate(firstName: 'أحمد', lastName: 'علي', schoolId: '7');

class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository(
    this.user, {
    this.refreshed = const Right(_fresh),
    this.updated = const Right(_renamed),
    this.imageUploaded = const Right(_withAvatar),
  });

  User? user;

  /// رد `profile/get`.
  final Either<Failure, User> refreshed;

  /// رد `users/update`.
  final Either<Failure, User> updated;
  ProfileUpdate? submitted;

  /// رد `users/update-image`.
  final Either<Failure, User> imageUploaded;

  @override
  Future<Either<Failure, User?>> currentUser() async => Right(user);

  @override
  Future<Either<Failure, User>> refreshProfile() async => refreshed;

  @override
  Future<Either<Failure, User>> updateProfile(ProfileUpdate update) async {
    submitted = update;
    return updated;
  }

  @override
  Future<Either<Failure, User>> updateProfileImage(ProfileImage image) async => imageUploaded;

  @override
  Future<Either<Failure, void>> logout() async {
    user = null;
    return const Right(null);
  }
}

ProfileCubit _cubit(_FakeAuthRepository repository) => ProfileCubit(
      getCurrentUser: GetCurrentUser(repository),
      refreshProfile: RefreshProfile(repository),
      updateProfile: UpdateProfile(repository),
      updateProfileImage: UpdateProfileImage(repository),
      logout: Logout(repository),
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

  group('save', () {
    test('يمر بالحفظ ثم saved ويعرض المستخدم الذي أعاده الخادم', () async {
      final repository = _FakeAuthRepository(_user);
      final cubit = _cubit(repository);

      final statuses = cubit.stream.map((state) => state.saveStatus).take(2).toList();
      await cubit.save(_update);

      expect(await statuses, [SaveStatus.sending, SaveStatus.done]);
      expect(repository.submitted, _update);
      expect(cubit.state.user, _renamed);
    });

    test('الفشل يضبط failure برسالة الخادم', () async {
      final cubit = _cubit(
        _FakeAuthRepository(_user, updated: const Left(ValidationFailure('الحقل الجهات الدراسية لاغٍ'))),
      );

      await cubit.save(_update);

      expect(cubit.state.saveStatus, SaveStatus.failure);
      expect(cubit.state.saveError, 'الحقل الجهات الدراسية لاغٍ');
    });
  });

  group('changeAvatar', () {
    final image = ProfileImage(bytes: Uint8List(3), fileName: 'me.jpg');

    test('يمر بالرفع ثم saved ويعرض الصورة الجديدة', () async {
      final cubit = _cubit(_FakeAuthRepository(_user));

      final statuses = cubit.stream.map((state) => state.avatarStatus).take(2).toList();
      await cubit.changeAvatar(image);

      expect(await statuses, [SaveStatus.sending, SaveStatus.done]);
      expect(cubit.state.user?.avatarUrl, _withAvatar.avatarUrl);
    });

    test('الفشل يضبط failure برسالة الخادم', () async {
      final cubit = _cubit(
        _FakeAuthRepository(_user, imageUploaded: const Left(ValidationFailure('يجب أن يكون الحقل الصورة صورةً'))),
      );

      await cubit.changeAvatar(image);

      expect(cubit.state.avatarStatus, SaveStatus.failure);
      expect(cubit.state.avatarError, 'يجب أن يكون الحقل الصورة صورةً');
    });
  });

  test('logout ينهي الجلسة ويضبط loggedOut', () async {
    final repository = _FakeAuthRepository(_user);
    final cubit = _cubit(repository);
    await cubit.logout();

    expect(repository.user, isNull);
    expect(cubit.state.loggedOut, isTrue);
  });
}
