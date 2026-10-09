import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/di/injection.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/domain/entities/lookup_option.dart';
import 'package:educational_app/features/auth/domain/entities/profile_update.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/repositories/registration_options_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_branches.dart';
import 'package:educational_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:educational_app/features/auth/domain/usecases/get_governorates.dart';
import 'package:educational_app/features/auth/domain/usecases/get_schools.dart';
import 'package:educational_app/features/auth/domain/usecases/logout.dart';
import 'package:educational_app/features/auth/domain/usecases/refresh_profile.dart';
import 'package:educational_app/features/auth/domain/usecases/update_profile.dart';
import 'package:educational_app/features/auth/domain/usecases/update_profile_image.dart';
import 'package:educational_app/features/auth/presentation/cubit/registration_options_cubit.dart';
import 'package:educational_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:educational_app/features/profile/presentation/pages/profile_page.dart';
import 'package:educational_app/features/support/domain/entities/contact_links.dart';
import 'package:educational_app/features/support/domain/entities/contact_message.dart';
import 'package:educational_app/features/support/domain/repositories/support_repository.dart';
import 'package:educational_app/features/support/domain/usecases/send_contact_message.dart';
import 'package:educational_app/features/support/presentation/cubit/contact_cubit.dart';
import 'package:educational_app/features/support/presentation/widgets/contact_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _user = User(
  id: '30',
  name: 'Rashed Eybo',
  phone: '0937857596',
  firstName: 'Rashed',
  lastName: 'Eybo',
  school: School(id: '7', name: 'مدرسة يامن', governorateId: 'damascus'),
  points: 22,
  enrolledCoursesCount: 9,
  semestersCount: 7,
  medalsCount: 12,
);

class _FakeAuthRepository extends Fake implements AuthRepository {
  ProfileUpdate? submitted;
  bool loggedOut = false;

  @override
  Future<Either<Failure, User?>> currentUser() async => const Right(_user);

  @override
  Future<Either<Failure, User>> refreshProfile() async => const Right(_user);

  @override
  Future<Either<Failure, User>> updateProfile(ProfileUpdate update) async {
    submitted = update;
    return const Right(
      User(id: '30', name: 'Rashid Eybo', phone: '0937857596', firstName: 'Rashid', lastName: 'Eybo'),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    loggedOut = true;
    return const Right(null);
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
  Future<Either<Failure, List<LookupOption>>> getSchools({SchoolKind? kind, String? governorateId}) async {
    return Right(switch (governorateId) {
      'damascus' => const [LookupOption(id: '7', name: 'مدرسة يامن')],
      'aleppo' => const [LookupOption(id: '9', name: 'مدرسة الأمل')],
      _ => const [],
    });
  }
}

class _FakeSupportRepository implements SupportRepository {
  ContactMessage? sent;

  @override
  Future<Either<Failure, void>> sendContactMessage(ContactMessage message) async {
    sent = message;
    return const Right(null);
  }

  @override
  Future<Either<Failure, ContactLinks>> getContactLinks() async => const Right(ContactLinks());
}

void main() {
  late _FakeAuthRepository auth;
  late _FakeSupportRepository support;

  setUp(() {
    support = _FakeSupportRepository();
    sl.registerFactory(() => ContactCubit(SendContactMessage(support)));
  });
  tearDown(sl.reset);

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view
      // خط الاختبار يعطي كل حرف عرضاً يساوي حجمه، فالنص العربي أعرض منه على الجهاز.
      ..physicalSize = const Size(1800, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    auth = _FakeAuthRepository();
    final options = _FakeOptionsRepository();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ProfileCubit(
                  getCurrentUser: GetCurrentUser(auth),
                  refreshProfile: RefreshProfile(auth),
                  updateProfile: UpdateProfile(auth),
                  updateProfileImage: UpdateProfileImage(auth),
                  logout: Logout(auth),
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
            child: const ProfilePage(),
          ),
        ),
        GoRoute(path: '/:page', builder: (_, state) => Scaffold(body: Text('page ${state.pathParameters['page']}'))),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('يعرض الاسم والإحصاءات وعناصر القائمة كما في التصميم', (tester) async {
    await pumpPage(tester);

    expect(find.text(AppStrings.profileTitle), findsOneWidget);
    expect(find.text('Rashed Eybo'), findsOneWidget);
    for (final (value, label) in [
      ('7', AppStrings.statSemesters),
      ('22', AppStrings.statPoints),
      ('9', AppStrings.statCourses),
      ('12', AppStrings.statMedals),
    ]) {
      expect(find.text(value), findsOneWidget, reason: label);
      expect(find.text(label), findsOneWidget);
    }
    for (final item in [
      AppStrings.faq,
      AppStrings.contact,
      AppStrings.subscription,
      AppStrings.achievements,
      AppStrings.about,
      AppStrings.privacyPolicy,
      AppStrings.downloadedCourses,
      AppStrings.usagePolicy,
      AppStrings.myTests,
      AppStrings.editProfileItem,
      AppStrings.logout,
    ]) {
      expect(find.text(item), findsOneWidget, reason: item);
    }
  });

  testWidgets('عناصر الصفحات تفتح مساراتها', (tester) async {
    await pumpPage(tester);

    await tap(tester, find.text(AppStrings.downloadedCourses));

    expect(find.text('page downloads'), findsOneWidget);
  });

  testWidgets('تسجيل الخروج يطلب التأكيد، والرجوع يلغيه', (tester) async {
    await pumpPage(tester);

    await tap(tester, find.text(AppStrings.logout));
    expect(find.text(AppStrings.logoutConfirm), findsOneWidget);
    await tap(tester, find.text(AppStrings.back));
    expect(auth.loggedOut, isFalse);

    await tap(tester, find.text(AppStrings.logout));
    await tap(tester, find.text(AppStrings.confirm));
    expect(auth.loggedOut, isTrue);
    expect(find.text('page login'), findsOneWidget);
  });

  testWidgets('ورقة التعديل: المحافظة ثم المدرسة، والحفظ يحدّث الصفحة', (tester) async {
    await pumpPage(tester);

    await tap(tester, find.text(AppStrings.editProfileItem));
    expect(find.text(AppStrings.editSheetTitle), findsOneWidget);
    expect(find.text('Rashed'), findsOneWidget);
    expect(find.text('مدرسة يامن'), findsOneWidget);

    await tap(tester, find.text('مدرسة يامن'));
    await tap(tester, find.text('حلب'));
    await tap(tester, find.text('مدرسة الأمل'));
    await tester.enterText(find.text('Rashed'), 'Rashid');
    await tap(tester, find.text(AppStrings.editAction));

    expect(auth.submitted, const ProfileUpdate(firstName: 'Rashid', lastName: 'Eybo', schoolId: '9'));
    expect(find.text(AppStrings.editSheetTitle), findsNothing);
    expect(find.text('Rashid Eybo'), findsOneWidget);
    expect(find.text(AppStrings.accountSaved), findsOneWidget);
  });

  testWidgets('تواصل معنا يبدأ باسم المستخدم ورقمه ويرسل الوصف', (tester) async {
    await pumpPage(tester);

    await tap(tester, find.text(AppStrings.contact));
    expect(find.byType(ContactSheet), findsOneWidget);
    expect(find.text('0937857596'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, AppStrings.descriptionHint), 'سؤال عن الاشتراك');
    await tap(tester, find.text(AppStrings.confirm));

    expect(
      support.sent,
      const ContactMessage(firstName: 'Rashed', lastName: 'Eybo', phone: '0937857596', text: 'سؤال عن الاشتراك'),
    );
    expect(find.byType(ContactSheet), findsNothing);
    expect(find.text(AppStrings.messageSent), findsOneWidget);
  });
}
