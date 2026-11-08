import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/achievements/presentation/cubit/achievements_cubit.dart';
import '../../features/achievements/presentation/pages/achievements_page.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/registration_options_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/courses/presentation/cubit/course_details_cubit.dart';
import '../../features/courses/presentation/cubit/courses_cubit.dart';
import '../../features/courses/presentation/cubit/lesson_cubit.dart';
import '../../features/courses/presentation/cubit/my_courses_cubit.dart';
import '../../features/courses/presentation/cubit/subject_details_cubit.dart';
import '../../features/courses/presentation/cubit/subjects_cubit.dart';
import '../../features/courses/presentation/pages/categories_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/courses/presentation/pages/my_courses_page.dart';
import '../../features/courses/presentation/pages/subject_page.dart';
import '../../features/courses/presentation/pages/video_page.dart';
import '../../features/downloads/presentation/cubit/downloads_cubit.dart';
import '../../features/downloads/presentation/pages/downloads_page.dart';
import '../../features/gallery/presentation/cubit/gallery_cubit.dart';
import '../../features/gallery/presentation/pages/album_page.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/gallery/presentation/pages/photo_viewer_page.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/points/presentation/cubit/points_cubit.dart';
import '../../features/points/presentation/pages/points_page.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/quiz/presentation/cubit/quiz_cubit.dart';
import '../../features/quiz/presentation/cubit/quiz_result_cubit.dart';
import '../../features/quiz/presentation/cubit/tests_cubit.dart';
import '../../features/quiz/presentation/pages/quiz_page.dart';
import '../../features/quiz/presentation/pages/quiz_result_page.dart';
import '../../features/quiz/presentation/pages/quiz_review_page.dart';
import '../../features/quiz/presentation/pages/tests_page.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/subscription/presentation/cubit/checkout_cubit.dart';
import '../../features/subscription/presentation/cubit/subscription_cubit.dart';
import '../../features/subscription/presentation/pages/checkout_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../../features/support/presentation/pages/faq_page.dart';
import '../../features/support/presentation/pages/policy_page.dart';
import '../../features/support/presentation/support_content.dart';
import '../constants/app_strings.dart';
import '../di/injection.dart';
import '../network/session_expiry.dart';
import '../widgets/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// مسارات تدفق الدخول، وهي وحدها المتاحة بلا جلسة (مع شاشة البداية).
const _authRoutes = {'/login', '/register', '/otp'};

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    // انتهاء الجلسة يحدث خارج الواجهة (رد 401)، فيُعاد تقييم redirect عنده.
    refreshListenable: sl<SessionExpiry>(),
    redirect: (context, state) {
      final location = state.matchedLocation;
      // شاشة البداية تقرر وجهتها بنفسها بعد عرض الشعار.
      if (location == '/') return null;
      final loggedIn = sl<AuthRepository>().cachedUser != null;
      final onAuthRoute = _authRoutes.contains(location);
      if (!loggedIn && !onAuthRoute) return '/login';
      if (loggedIn && onAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashPage()),
      GoRoute(
        path: '/login',
        builder: (_, _) => BlocProvider(create: (_) => sl<AuthCubit>(), child: const LoginPage()),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<AuthCubit>()),
            // القوائم تُطلب بتوكن الحساب الجديد المحفوظ عند التحقق من الرمز.
            BlocProvider(create: (_) => sl<RegistrationOptionsCubit>()..load()),
          ],
          child: RegisterPage(phone: state.extra as String?),
        ),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: OtpPage(phone: state.extra! as String),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (_, _) => BlocProvider(
                create: (_) => sl<HomeCubit>()..load(),
                child: const HomePage(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/gallery',
              builder: (_, _) => BlocProvider(
                create: (_) => sl<GalleryCubit>()..loadAlbums(),
                child: const GalleryPage(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/my-courses',
              builder: (_, _) => BlocProvider(
                create: (_) => sl<MyCoursesCubit>()..load(),
                child: const MyCoursesPage(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (_, _) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => sl<ProfileCubit>()..load()),
                  // المحافظات ومدارسها لورقة التعديل، لا تُطلب إلا عند فتحها أول مرة.
                  BlocProvider(create: (_) => sl<RegistrationOptionsCubit>()..load()),
                ],
                child: const ProfilePage(),
              ),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/courses',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<CoursesCubit>()..load(),
          child: const CoursesPage(),
        ),
      ),
      GoRoute(
        path: '/courses/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<CourseDetailsCubit>()..load(id),
            child: CourseDetailPage(courseId: id),
          );
        },
      ),
      GoRoute(
        path: '/courses/:id/video/:lessonId',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return BlocProvider(
            // الانتقال بين دروس الفصل يُبقي الصفحة نفسها؛ المفتاح ينشئ Cubit للدرس الجديد.
            key: ValueKey(lessonId),
            create: (_) => sl<LessonCubit>()..load(lessonId),
            child: VideoPage(courseId: state.pathParameters['id']!, lessonId: lessonId),
          );
        },
      ),
      GoRoute(
        path: '/gallery/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<GalleryCubit>()..loadAlbum(id),
            child: AlbumPage(albumId: id),
          );
        },
      ),
      GoRoute(
        path: '/gallery/:id/photo/:index',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<GalleryCubit>()..loadAlbum(id),
            child: PhotoViewerPage(
              albumId: id,
              initialIndex: int.tryParse(state.pathParameters['index'] ?? '0') ?? 0,
            ),
          );
        },
      ),
      // شاشة «اختباراتي» ليست تبويباً في الشريط السفلي (استبدلها المعرض حسب
      // التصميم)؛ تُفتح كمسار مستقل.
      GoRoute(
        path: '/tests',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<TestsCubit>()..load(),
          child: const TestsPage(),
        ),
      ),
      GoRoute(
        path: '/categories',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<SubjectsCubit>()..load(),
          child: const CategoriesPage(),
        ),
      ),
      GoRoute(
        path: '/categories/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<SubjectDetailsCubit>()..load(id),
            child: SubjectPage(subjectId: id),
          );
        },
      ),
      GoRoute(
        path: '/search',
        builder: (_, _) => BlocProvider(create: (_) => sl<SearchCubit>(), child: const SearchPage()),
      ),
      GoRoute(
        path: '/quiz/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<QuizCubit>()..load(id),
            child: QuizPage(quizId: id),
          );
        },
      ),
      GoRoute(
        path: '/quiz/:id/result',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<QuizResultCubit>()..load(id),
            child: QuizResultPage(quizId: id),
          );
        },
      ),
      GoRoute(
        path: '/quiz/:id/review',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<QuizResultCubit>()..load(id),
            child: QuizReviewPage(quizId: id),
          );
        },
      ),
      GoRoute(
        path: '/subscription',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<SubscriptionCubit>()..load(),
          child: const SubscriptionPage(),
        ),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CheckoutCubit>()..load(state.uri.queryParameters['package']),
          child: const CheckoutPage(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<NotificationsCubit>()..load(),
          child: const NotificationsPage(),
        ),
      ),
      GoRoute(
        path: '/achievements',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<AchievementsCubit>()..load(),
          child: const AchievementsPage(),
        ),
      ),
      GoRoute(
        path: '/points',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<PointsCubit>()..load(),
          child: const PointsPage(),
        ),
      ),
      GoRoute(path: '/faq', builder: (_, _) => const FaqPage()),
      GoRoute(
        path: '/privacy',
        builder: (_, _) => const PolicyPage(title: AppStrings.privacyPolicy, sections: privacySections),
      ),
      GoRoute(
        path: '/usage-policy',
        builder: (_, _) => const PolicyPage(title: AppStrings.usagePolicy, sections: usageSections),
      ),
      GoRoute(
        path: '/downloads',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<DownloadsCubit>()..load(),
          child: const DownloadsPage(),
        ),
      ),
    ],
  );
}
