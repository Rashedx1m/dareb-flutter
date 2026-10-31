import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/widgets/error_view.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:educational_app/features/auth/domain/usecases/refresh_profile.dart';
import 'package:educational_app/features/courses/domain/entities/course.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:educational_app/core/utils/external_link.dart';
import 'package:educational_app/features/home/domain/entities/home_banner.dart';
import 'package:educational_app/features/home/domain/entities/home_feed.dart';
import 'package:educational_app/features/home/domain/entities/news_item.dart';
import 'package:educational_app/features/home/domain/repositories/home_repository.dart';
import 'package:educational_app/features/home/domain/usecases/get_home.dart';
import 'package:educational_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:educational_app/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _user = User(id: 'u1', name: 'أحمد المصري', phone: '0501234567', points: 55, enrolledCoursesCount: 6);

const _feed = HomeFeed(
  sliders: [],
  subjects: [
    Subject(id: '1', name: 'العلوم', imageUrl: 'x', isFree: true, isSubscribed: false),
    Subject(id: '2', name: 'الرياضيات', imageUrl: 'y', isFree: true, isSubscribed: false),
  ],
  news: [NewsItem(id: '9', imageUrl: 'n', link: 'https://www.google.com/')],
  courses: [
    Course(
      id: '1',
      title: 'دورة الرياضيات',
      subjectName: 'الرياضيات',
      instructor: 'أ.عمر النابلسي',
      description: '',
      imageUrl: 'c',
      price: 0,
      semestersCount: 9,
      semesterRate: 0,
      lessonsCount: 12,
      lessonRate: 0,
      subscriptionsCount: 22,
      isFree: true,
      isSubscribed: false,
    ),
  ],
  completionRate: 0.4,
  subjectCount: 22,
);

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository(this.result);
  final Either<Failure, HomeFeed> result;

  @override
  Future<Either<Failure, HomeFeed>> getHome() async => result;
}

HomeFeed _feedWith(double completionRate, int subjectCount) {
  return HomeFeed(
    sliders: _feed.sliders,
    subjects: _feed.subjects,
    news: _feed.news,
    courses: _feed.courses,
    completionRate: completionRate,
    subjectCount: subjectCount,
  );
}

/// يعيد الردود بالترتيب ويكرر الأخير، ويعدّ الطلبات.
class _QueueHomeRepository implements HomeRepository {
  _QueueHomeRepository(this.feeds);
  final List<HomeFeed> feeds;
  var calls = 0;

  @override
  Future<Either<Failure, HomeFeed>> getHome() async {
    final feed = feeds[calls < feeds.length ? calls : feeds.length - 1];
    calls++;
    return Right(feed);
  }
}

class _FakeAuthRepository extends Fake implements AuthRepository {
  @override
  Future<Either<Failure, User?>> currentUser() async => const Right(_user);

  @override
  Future<Either<Failure, User>> refreshProfile() async => const Right(_user);
}

Future<void> _pump(
  WidgetTester tester,
  Either<Failure, HomeFeed> home, {
  LinkOpener openLink = _noopLink,
}) async {
  tester.view
    ..physicalSize = const Size(1800, 3600)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final auth = _FakeAuthRepository();
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => HomeCubit(
          getHome: GetHome(_FakeHomeRepository(home)),
          getCurrentUser: GetCurrentUser(auth),
          refreshProfile: RefreshProfile(auth),
        )..load(),
        child: HomePage(openLink: openLink),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<bool> _noopLink(Uri uri) async => true;

void main() {
  testWidgets('تعرض التقدم والمواد والدورات بلا زر اختباراتي', (tester) async {
    await _pump(tester, const Right(_feed));

    expect(find.textContaining('أحمد المصري'), findsOneWidget);
    expect(find.text(AppStrings.curriculumProgress), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text(AppStrings.subjects), findsOneWidget);
    expect(find.text('العلوم'), findsOneWidget);
    expect(find.text('دورة الرياضيات'), findsOneWidget);
    expect(find.text(AppStrings.myTests), findsNothing);
    expect(find.text(AppStrings.checkAccount), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('السلايدر من الخادم يفتح رابطه ويخفي بانر الحساب', (tester) async {
    final opened = <Uri>[];
    const sliders = [
      HomeBanner(id: '1', imageUrl: 's1', link: 'https://www.google.com/'),
      HomeBanner(id: '2', imageUrl: 's2', link: 'https://example.com/'),
    ];
    await _pump(
      tester,
      Right(HomeFeed(
        sliders: sliders,
        subjects: _feed.subjects,
        news: _feed.news,
        courses: _feed.courses,
        completionRate: _feed.completionRate,
        subjectCount: _feed.subjectCount,
      )),
      openLink: (uri) async {
        opened.add(uri);
        return true;
      },
    );

    expect(find.text(AppStrings.checkAccount), findsNothing);
    expect(find.byType(PageView), findsOneWidget);
    await tester.tap(find.byType(PageView));
    await tester.pump();
    expect(opened.single.toString(), 'https://www.google.com/');
  });

  testWidgets('الفشل يعرض الرسالة وزر إعادة المحاولة', (tester) async {
    await _pump(tester, const Left(ServerFailure('تعذر جلب الصفحة')));

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('تعذر جلب الصفحة'), findsOneWidget);
  });

  // الرئيسية تبويب يبقى حياً، فكانت النسبة وعدد الكورسات لا يتغيّران بعد مشاهدة درس أو
  // تفعيل كود حتى يُسحب للتحديث (2026-10-23).
  group('التحديث عند العودة', () {
    late _QueueHomeRepository home;
    late GoRouter router;

    Future<void> pumpShell(WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(1800, 3600)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      home = _QueueHomeRepository([_feedWith(0, 1), _feedWith(0.5, 2)]);
      final auth = _FakeAuthRepository();
      router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (_, _, shell) => shell,
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/home',
                  builder: (_, _) => BlocProvider(
                    create: (_) => HomeCubit(
                      getHome: GetHome(home),
                      getCurrentUser: GetCurrentUser(auth),
                      refreshProfile: RefreshProfile(auth),
                    )..load(),
                    child: const HomePage(openLink: _noopLink),
                  ),
                ),
              ]),
              StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const Text('profile'))]),
            ],
          ),
          GoRoute(path: '/lesson', builder: (_, _) => const Scaffold(body: Text('lesson'))),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('1 ${AppStrings.coursesCount}'), findsOneWidget);
    }

    testWidgets('العودة إلى التبويب تحدّث النسبة وعدد الكورسات', (tester) async {
      await pumpShell(tester);

      router.go('/profile');
      await tester.pumpAndSettle();
      router.go('/home');
      await tester.pumpAndSettle();

      expect(find.text('50%'), findsOneWidget);
      expect(find.text('2 ${AppStrings.coursesCount}'), findsOneWidget);
      expect(home.calls, 2);
    });

    testWidgets('إغلاق صفحة فُتحت فوق الرئيسية يحدّثها', (tester) async {
      await pumpShell(tester);

      router.push('/lesson');
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('50%'), findsOneWidget);
      expect(home.calls, 2);
    });
  });
}
