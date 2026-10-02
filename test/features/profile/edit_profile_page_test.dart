import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/domain/entities/lookup_option.dart';
import 'package:educational_app/features/auth/domain/entities/profile_update.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/repositories/registration_options_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:educational_app/features/auth/domain/usecases/get_registration_options.dart';
import 'package:educational_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:educational_app/features/auth/domain/usecases/refresh_profile_usecase.dart';
import 'package:educational_app/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:educational_app/features/auth/presentation/cubit/registration_options_cubit.dart';
import 'package:educational_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:educational_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _school = School(id: '7', name: 'مدرسة يامن', governorateId: 'damascus');
const _user = User(
  id: '30',
  name: 'Rashed Eybo',
  phone: '0930000000',
  firstName: 'Rashed',
  lastName: 'Eybo',
  school: _school,
);

class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository(this.cached, this.fresh);

  final User cached;
  final User fresh;
  ProfileUpdate? submitted;

  /// إن ضُبط، لا يصل رد `profile/get` إلا بعد إكماله.
  Completer<void>? refreshGate;

  @override
  Future<Either<Failure, User?>> currentUser() async => Right(cached);

  @override
  Future<Either<Failure, User>> refreshProfile() async {
    await refreshGate?.future;
    return Right(fresh);
  }

  @override
  Future<Either<Failure, User>> updateProfile(ProfileUpdate update) async {
    submitted = update;
    return const Right(_user);
  }
}

class _FakeOptionsRepository implements RegistrationOptionsRepository {
  @override
  Future<Either<Failure, List<LookupOption>>> getGovernorates() async => const Right([
        LookupOption(id: 'damascus', name: 'دمشق'),
        LookupOption(id: 'aleppo', name: 'حلب'),
      ]);

  @override
  Future<Either<Failure, List<LookupOption>>> getBranches() async => const Right([]);

  @override
  Future<Either<Failure, List<LookupOption>>> getSchools({
    SchoolKind? kind,
    String? governorateId,
  }) async {
    return Right(switch (governorateId) {
      'damascus' => const [LookupOption(id: '7', name: 'مدرسة يامن')],
      'aleppo' => const [LookupOption(id: '9', name: 'مدرسة الأمل')],
      _ => const [],
    });
  }
}

void main() {
  late _FakeAuthRepository auth;

  /// الصفحة تُفتح فوق صفحة أخرى كما في التطبيق، لأنها تُغلق نفسها بعد الحفظ.
  Future<void> pumpPage(
    WidgetTester tester, {
    User cached = _user,
    User fresh = _user,
    Completer<void>? refreshGate,
  }) async {
    tester.view
      // خط الاختبار يعطي كل حرف عرضاً يساوي حجمه، فالنص العربي أعرض منه على الجهاز.
      ..physicalSize = const Size(1800, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    auth = _FakeAuthRepository(cached, fresh)..refreshGate = refreshGate;
    final options = _FakeOptionsRepository();
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('profile'))),
        GoRoute(
          path: '/edit',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ProfileCubit(
                  getCurrentUser: GetCurrentUserUseCase(auth),
                  refreshProfile: RefreshProfileUseCase(auth),
                  updateProfile: UpdateProfileUseCase(auth),
                  logout: LogoutUseCase(auth),
                )..load(),
              ),
              BlocProvider(
                create: (_) => RegistrationOptionsCubit(
                  getGovernorates: GetGovernorates(options),
                  getSchools: GetSchools(options),
                  getBranches: GetBranches(options),
                )..load(),
              ),
            ],
            child: const EditProfilePage(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.push('/edit');
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  ElevatedButton saveButton(WidgetTester tester) => tester.widget<ElevatedButton>(
        find.ancestor(of: find.text(AppStrings.saveChanges), matching: find.byType(ElevatedButton)),
      );

  testWidgets('يبدأ بالاسم والمحافظة والمدرسة الحالية', (tester) async {
    await pumpPage(tester);

    expect(find.text('Rashed'), findsOneWidget);
    expect(find.text('Eybo'), findsOneWidget);
    expect(find.text('0930000000'), findsOneWidget);
    expect(find.text('دمشق'), findsOneWidget);
    expect(find.text('مدرسة يامن'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('النسخة المحفوظة بلا مدرسة تُستبدل بما يصل من الخادم بعدها', (tester) async {
    // كما يُحفظ المستخدم من رد auth/active.
    const cached = User(id: '30', name: 'Rashed Eybo', phone: '0930000000', firstName: 'Rashed', lastName: 'Eybo');
    final gate = Completer<void>();
    await pumpPage(tester, cached: cached, refreshGate: gate);

    // قبل وصول رد الخادم: النموذج من النسخة المحفوظة، فلا مدرسة.
    expect(find.text(AppStrings.pickStudyPlace), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.text('دمشق'), findsOneWidget);
    expect(find.text('مدرسة يامن'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('تغيير المحافظة يمسح المدرسة، والحفظ يرسل مدرسة المحافظة الجديدة', (tester) async {
    await pumpPage(tester);

    await tap(tester, find.text('دمشق'));
    await tap(tester, find.text('حلب'));

    expect(find.text('مدرسة يامن'), findsNothing);
    expect(saveButton(tester).onPressed, isNull);

    await tap(tester, find.text(AppStrings.pickStudyPlace));
    await tap(tester, find.text('مدرسة الأمل'));
    await tester.enterText(find.text('Rashed'), 'Rashid');
    await tap(tester, find.text(AppStrings.saveChanges));

    expect(auth.submitted, const ProfileUpdate(firstName: 'Rashid', lastName: 'Eybo', schoolId: '9'));
    // نجح الحفظ: أُغلقت الصفحة وظهرت رسالة النجاح.
    expect(find.byType(EditProfilePage), findsNothing);
    expect(find.text(AppStrings.accountSaved), findsOneWidget);
  });
}
