import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/achievements/data/datasources/achievements_remote_data_source.dart';
import '../../features/achievements/data/repositories/achievements_repository_impl.dart';
import '../../features/achievements/domain/repositories/achievements_repository.dart';
import '../../features/achievements/domain/usecases/get_achievements.dart';
import '../../features/achievements/presentation/cubit/achievements_cubit.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/registration_options_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/registration_options_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/registration_options_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/get_registration_options.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/request_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/registration_options_cubit.dart';
import '../../features/courses/data/datasources/courses_remote_data_source.dart';
import '../../features/courses/data/repositories/courses_repository_impl.dart';
import '../../features/courses/domain/repositories/courses_repository.dart';
import '../../features/courses/domain/usecases/get_courses.dart';
import '../../features/courses/presentation/bloc/courses_bloc.dart';
import '../../features/courses/presentation/cubit/my_courses_cubit.dart';
import '../../features/gallery/data/datasources/gallery_remote_data_source.dart';
import '../../features/gallery/data/repositories/gallery_repository_impl.dart';
import '../../features/gallery/domain/repositories/gallery_repository.dart';
import '../../features/gallery/domain/usecases/get_albums.dart';
import '../../features/gallery/presentation/cubit/gallery_cubit.dart';
import '../../features/home/data/datasources/news_remote_data_source.dart';
import '../../features/home/data/repositories/news_repository_impl.dart';
import '../../features/home/domain/repositories/news_repository.dart';
import '../../features/home/domain/usecases/get_news.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/quiz/data/datasources/quiz_remote_data_source.dart';
import '../../features/quiz/data/repositories/quiz_repository_impl.dart';
import '../../features/quiz/domain/repositories/quiz_repository.dart';
import '../../features/quiz/domain/usecases/get_quizzes.dart';
import '../../features/quiz/presentation/bloc/quiz_bloc.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../../features/subscription/data/datasources/subscription_remote_data_source.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/subscription/domain/usecases/get_plans.dart';
import '../../features/subscription/presentation/cubit/plans_cubit.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

/// لكل ميزة: مصدر البيانات ← المستودع ← الـ UseCases ← الـ Cubit/Bloc.
/// ربط الـ API يعني استبدال تسجيل مصدر البيانات التجريبي `*MockDataSource` فقط.
Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    // كل طلب يقرأ توكن الجلسة المحفوظ لحظة إرساله.
    ..registerLazySingleton(() => ApiClient(readToken: () => sl<AuthLocalDataSource>().token));

  _initAuth();
  _initCourses();
  _initQuiz();
  _initHome();
  _initGallery();
  _initNotifications();
  _initAchievements();
  _initSubscription();
  _initProfile();
}

void _initAuth() {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()))
    ..registerLazySingleton<AuthLocalDataSource>(() => SharedPrefsAuthLocalDataSource(sl()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remote: sl(), local: sl()))
    ..registerLazySingleton(() => RequestOtpUseCase(sl()))
    ..registerLazySingleton(() => RegisterUseCase(sl()))
    ..registerLazySingleton(() => VerifyOtpUseCase(sl()))
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl()))
    ..registerLazySingleton(() => LogoutUseCase(sl()))
    ..registerLazySingleton<RegistrationOptionsRemoteDataSource>(
      () => RegistrationOptionsRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<RegistrationOptionsRepository>(
      () => RegistrationOptionsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetGovernorates(sl()))
    ..registerLazySingleton(() => GetSchools(sl()))
    ..registerLazySingleton(() => GetBranches(sl()))
    ..registerFactory(
      () => AuthCubit(
        requestOtpUseCase: sl(),
        registerUseCase: sl(),
        verifyOtpUseCase: sl(),
      ),
    )
    ..registerFactory(
      () => RegistrationOptionsCubit(getGovernorates: sl(), getSchools: sl(), getBranches: sl()),
    );
}

void _initCourses() {
  sl
    ..registerLazySingleton<CoursesRemoteDataSource>(CoursesMockDataSource.new)
    ..registerLazySingleton<CoursesRepository>(() => CoursesRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetCourses(sl()))
    ..registerLazySingleton(() => GetMyCourses(sl()))
    ..registerLazySingleton(() => GetCourse(sl()))
    ..registerLazySingleton(() => GetCategories(sl()))
    ..registerLazySingleton(() => SearchCourses(sl()))
    ..registerFactory(
      () => CoursesBloc(
        getCourses: sl(),
        getCourse: sl(),
        searchCourses: sl(),
        getCategories: sl(),
      ),
    )
    ..registerFactory(() => MyCoursesCubit(sl()))
    ..registerFactory(() => SearchCubit(sl()));
}

void _initQuiz() {
  sl
    ..registerLazySingleton<QuizRemoteDataSource>(QuizMockDataSource.new)
    ..registerLazySingleton<QuizRepository>(() => QuizRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetQuizzes(sl()))
    ..registerLazySingleton(() => GetQuiz(sl()))
    ..registerFactory(() => QuizBloc(getQuizzes: sl(), getQuiz: sl()));
}

void _initHome() {
  sl
    ..registerLazySingleton<NewsRemoteDataSource>(NewsMockDataSource.new)
    ..registerLazySingleton<NewsRepository>(() => NewsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetNews(sl()))
    ..registerFactory(
      () => HomeCubit(
        getCourses: sl(),
        getCategories: sl(),
        getNews: sl(),
        getCurrentUser: sl(),
      ),
    );
}

void _initGallery() {
  sl
    ..registerLazySingleton<GalleryRemoteDataSource>(GalleryMockDataSource.new)
    ..registerLazySingleton<GalleryRepository>(() => GalleryRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetAlbums(sl()))
    ..registerLazySingleton(() => GetAlbum(sl()))
    ..registerFactory(() => GalleryCubit(getAlbums: sl(), getAlbum: sl()));
}

void _initNotifications() {
  sl
    ..registerLazySingleton<NotificationsRemoteDataSource>(NotificationsMockDataSource.new)
    ..registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetNotifications(sl()))
    ..registerFactory(() => NotificationsCubit(sl()));
}

void _initAchievements() {
  sl
    ..registerLazySingleton<AchievementsRemoteDataSource>(AchievementsMockDataSource.new)
    ..registerLazySingleton<AchievementsRepository>(() => AchievementsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetAchievements(sl()))
    ..registerFactory(() => AchievementsCubit(sl()));
}

void _initSubscription() {
  sl
    ..registerLazySingleton<SubscriptionRemoteDataSource>(SubscriptionMockDataSource.new)
    ..registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetPlans(sl()))
    ..registerFactory(() => PlansCubit(sl()));
}

void _initProfile() {
  sl.registerFactory(() => ProfileCubit(getCurrentUser: sl(), logout: sl()));
}
