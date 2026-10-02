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
import '../../features/courses/presentation/bloc/courses_bloc.dart';
import '../../features/courses/presentation/cubit/my_courses_cubit.dart';
import '../../features/courses/presentation/pages/categories_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/courses/presentation/pages/my_courses_page.dart';
import '../../features/courses/presentation/pages/video_page.dart';
import '../../features/gallery/presentation/cubit/gallery_cubit.dart';
import '../../features/gallery/presentation/pages/album_page.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/gallery/presentation/pages/photo_viewer_page.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/simple_pages.dart';
import '../../features/quiz/presentation/bloc/quiz_bloc.dart';
import '../../features/quiz/presentation/pages/quiz_page.dart';
import '../../features/quiz/presentation/pages/quiz_result_page.dart';
import '../../features/quiz/presentation/pages/tests_page.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/subscription/presentation/cubit/plans_cubit.dart';
import '../../features/subscription/presentation/pages/checkout_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
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
              path: '/courses',
              builder: (_, _) => BlocProvider(
                create: (_) => sl<CoursesBloc>()..add(const CoursesStarted()),
                child: const CoursesPage(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (_, _) => BlocProvider(
                create: (_) => sl<ProfileCubit>()..load(),
                child: const ProfilePage(),
              ),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/courses/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<CoursesBloc>()..add(CourseOpened(id)),
            child: CourseDetailPage(courseId: id),
          );
        },
      ),
      GoRoute(
        path: '/courses/:id/video/:lessonId',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final lessonId = state.pathParameters['lessonId']!;
          return BlocProvider(
            create: (_) => sl<CoursesBloc>()..add(CourseOpened(id)),
            child: VideoPage(courseId: id, lessonId: lessonId),
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
      // شاشة «إختباراتي» ليست تبويباً في الشريط السفلي (استبدلها المعرض حسب
      // التصميم)؛ تُفتح كمسار مستقل.
      GoRoute(
        path: '/tests',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<QuizBloc>()..add(const QuizzesStarted()),
          child: const TestsPage(),
        ),
      ),
      GoRoute(
        path: '/categories',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<CoursesBloc>()..add(const CoursesStarted()),
          child: const CategoriesPage(),
        ),
      ),
      GoRoute(
        path: '/categories/:id',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CoursesBloc>()..add(const CoursesStarted()),
          child: CategoriesPage(initialId: state.pathParameters['id']),
        ),
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
            create: (_) => sl<QuizBloc>()..add(QuizOpened(id)),
            child: QuizPage(quizId: id),
          );
        },
      ),
      GoRoute(
        path: '/quiz/:id/result',
        builder: (context, state) {
          final extra = state.extra as Map<String, int>? ?? const {'score': 0, 'total': 0};
          return QuizResultPage(score: extra['score'] ?? 0, total: extra['total'] ?? 0);
        },
      ),
      GoRoute(
        path: '/subscription',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<PlansCubit>()..load(),
          child: const SubscriptionPage(),
        ),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<PlansCubit>()..load(preferredId: state.uri.queryParameters['plan']),
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
        path: '/edit-profile',
        builder: (_, _) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ProfileCubit>()..load()),
            // المحافظات ومدارسها لتغيير الجهة الدراسية. تُطلب مع فتح الصفحة لا عند
            // بناء النموذج، فتصل بالتوازي مع المستخدم.
            BlocProvider(lazy: false, create: (_) => sl<RegistrationOptionsCubit>()..load()),
          ],
          child: const EditProfilePage(),
        ),
      ),
      GoRoute(path: '/about', builder: (_, _) => const AboutPage()),
      GoRoute(path: '/contact', builder: (_, _) => const ContactPage()),
      GoRoute(path: '/faq', builder: (_, _) => const FaqPage()),
      GoRoute(
        path: '/my-courses',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<MyCoursesCubit>()..load(),
          child: const MyCoursesPage(),
        ),
      ),
    ],
  );
}
