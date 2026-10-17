import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/widgets/error_view.dart';
import 'package:educational_app/features/achievements/presentation/cubit/achievements_cubit.dart';
import 'package:educational_app/features/achievements/presentation/pages/achievements_page.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:educational_app/features/auth/domain/usecases/refresh_profile.dart';
import 'package:educational_app/features/courses/domain/entities/course.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/get_my_courses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _user = User(
  id: 'u1',
  name: 'أ.عمر النابلسي',
  phone: '0501234567',
  points: 22,
  enrolledCoursesCount: 9,
  semestersCount: 9,
  medalsCount: 12,
);

const _course = Course(
  id: '1',
  title: 'دورة الرياضيات',
  subjectName: 'الرياضيات',
  instructor: 'أ.عمر النابلسي',
  description: '',
  imageUrl: 'x',
  price: 0,
  semestersCount: 9,
  semesterRate: 40,
  lessonsCount: 30,
  lessonRate: 20,
  subscriptionsCount: 1,
  isFree: true,
  isSubscribed: true,
  subjectRate: 20,
  pointsCount: 600,
  pointRate: 40,
);

class _FakeAuthRepository extends Fake implements AuthRepository {
  @override
  Future<Either<Failure, User?>> currentUser() async => const Right(_user);

  @override
  Future<Either<Failure, User>> refreshProfile() async => const Right(_user);
}

class _FakeCoursesRepository extends Fake implements CoursesRepository {
  _FakeCoursesRepository(this.result);
  final Either<Failure, List<Course>> result;

  @override
  Future<Either<Failure, List<Course>>> getMyCourses() async => result;
}

Future<void> _pump(WidgetTester tester, Either<Failure, List<Course>> courses) async {
  tester.view
    ..physicalSize = const Size(1200, 2600)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final auth = _FakeAuthRepository();
  final router = GoRouter(
    initialLocation: '/achievements',
    routes: [
      GoRoute(
        path: '/achievements',
        builder: (_, _) => BlocProvider(
          create: (_) => AchievementsCubit(
            getCurrentUser: GetCurrentUser(auth),
            refreshProfile: RefreshProfile(auth),
            getMyCourses: GetMyCourses(_FakeCoursesRepository(courses)),
          )..load(),
          child: const AchievementsPage(),
        ),
      ),
      GoRoute(path: '/notifications', builder: (_, _) => const SizedBox()),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('تعرض الاسم والإحصاءات وتقدّم المادة', (tester) async {
    await _pump(tester, const Right([_course]));

    expect(find.text('أ.عمر النابلسي'), findsOneWidget);
    expect(find.text(AppStrings.statPoints), findsWidgets);
    expect(find.text('الرياضيات'), findsOneWidget);
    expect(find.text('20%'), findsWidgets);
    expect(find.text('40%'), findsWidgets);
  });

  testWidgets('بلا مواد تعرض رسالة الفراغ مع الملف', (tester) async {
    await _pump(tester, const Right([]));

    expect(find.text('أ.عمر النابلسي'), findsOneWidget);
    expect(find.text(AppStrings.achievementsEmpty), findsOneWidget);
  });

  testWidgets('الفشل يعرض الرسالة وزر إعادة المحاولة', (tester) async {
    await _pump(tester, const Left(ServerFailure('تعذر جلب الإنجازات')));

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('تعذر جلب الإنجازات'), findsOneWidget);
  });
}
