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
import '../../features/auth/domain/usecases/get_branches.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/get_governorates.dart';
import '../../features/auth/domain/usecases/get_schools.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/refresh_profile.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/domain/usecases/request_otp.dart';
import '../../features/auth/domain/usecases/update_profile.dart';
import '../../features/auth/domain/usecases/update_profile_image.dart';
import '../../features/auth/domain/usecases/verify_otp.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/registration_options_cubit.dart';
import '../../features/courses/data/datasources/courses_remote_data_source.dart';
import '../../features/courses/data/repositories/courses_repository_impl.dart';
import '../../features/courses/domain/repositories/courses_repository.dart';
import '../../features/courses/domain/usecases/add_comment.dart';
import '../../features/courses/domain/usecases/attend_lesson.dart';
import '../../features/courses/domain/usecases/get_course_details.dart';
import '../../features/courses/domain/usecases/get_courses.dart';
import '../../features/courses/domain/usecases/get_lesson.dart';
import '../../features/courses/domain/usecases/get_my_courses.dart';
import '../../features/courses/domain/usecases/get_subject_details.dart';
import '../../features/courses/domain/usecases/get_subjects.dart';
import '../../features/courses/domain/usecases/search_content.dart';
import '../../features/courses/presentation/cubit/course_details_cubit.dart';
import '../../features/courses/presentation/cubit/courses_cubit.dart';
import '../../features/courses/presentation/cubit/lesson_cubit.dart';
import '../../features/courses/presentation/cubit/my_courses_cubit.dart';
import '../../features/courses/presentation/cubit/subject_details_cubit.dart';
import '../../features/courses/presentation/cubit/subjects_cubit.dart';
import '../../features/downloads/data/datasources/downloads_local_data_source.dart';
import '../../features/downloads/data/repositories/downloads_repository_impl.dart';
import '../../features/downloads/domain/repositories/downloads_repository.dart';
import '../../features/downloads/domain/usecases/get_downloads.dart';
import '../../features/downloads/presentation/cubit/downloads_cubit.dart';
import '../../features/gallery/data/datasources/gallery_remote_data_source.dart';
import '../../features/gallery/data/repositories/gallery_repository_impl.dart';
import '../../features/gallery/domain/repositories/gallery_repository.dart';
import '../../features/gallery/domain/usecases/get_album.dart';
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
import '../../features/quiz/domain/usecases/get_my_activities.dart';
import '../../features/quiz/domain/usecases/get_my_exams.dart';
import '../../features/quiz/domain/usecases/get_quiz.dart';
import '../../features/quiz/presentation/bloc/quiz_bloc.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../../features/subscription/data/datasources/subscription_remote_data_source.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/subscription/domain/usecases/get_package_subjects.dart';
import '../../features/subscription/domain/usecases/get_packages.dart';
import '../../features/subscription/domain/usecases/get_payment_methods.dart';
import '../../features/subscription/domain/usecases/subscribe_with_code.dart';
import '../../features/subscription/presentation/cubit/checkout_cubit.dart';
import '../../features/subscription/presentation/cubit/package_subjects_cubit.dart';
import '../../features/subscription/presentation/cubit/subscription_cubit.dart';
import '../../features/support/data/datasources/support_remote_data_source.dart';
import '../../features/support/data/repositories/support_repository_impl.dart';
import '../../features/support/domain/repositories/support_repository.dart';
import '../../features/support/domain/usecases/get_contact_links.dart';
import '../../features/support/domain/usecases/send_contact_message.dart';
import '../../features/support/presentation/cubit/about_cubit.dart';
import '../../features/support/presentation/cubit/contact_cubit.dart';
import '../network/api_client.dart';
import '../network/session_expiry.dart';

final sl = GetIt.instance;

/// لكل ميزة: مصدر البيانات ← المستودع ← الـ UseCases ← الـ Cubit/Bloc.
/// ربط الـ API يعني استبدال تسجيل مصدر البيانات التجريبي `*MockDataSource` فقط.
Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    // المسح محلي فقط: إبلاغ الخادم بالخروج سيُرفض بالتوكن نفسه (401) من جديد.
    ..registerLazySingleton(() => SessionExpiry(() => sl<AuthLocalDataSource>().clear()))
    // كل طلب يقرأ توكن الجلسة المحفوظ لحظة إرساله.
    ..registerLazySingleton(
      () => ApiClient(
        readToken: () => sl<AuthLocalDataSource>().token,
        onUnauthorized: () => sl<SessionExpiry>().expire(),
      ),
    );

  _initAuth();
  _initCourses();
  _initQuiz();
  _initHome();
  _initGallery();
  _initNotifications();
  _initAchievements();
  _initSubscription();
  _initProfile();
  _initSupport();
  _initDownloads();
}

void _initAuth() {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()))
    ..registerLazySingleton<AuthLocalDataSource>(() => SharedPrefsAuthLocalDataSource(sl()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remote: sl(), local: sl()))
    ..registerLazySingleton(() => RequestOtp(sl()))
    ..registerLazySingleton(() => Register(sl()))
    ..registerLazySingleton(() => VerifyOtp(sl()))
    ..registerLazySingleton(() => GetCurrentUser(sl()))
    ..registerLazySingleton(() => RefreshProfile(sl()))
    ..registerLazySingleton(() => UpdateProfile(sl()))
    ..registerLazySingleton(() => UpdateProfileImage(sl()))
    ..registerLazySingleton(() => Logout(sl()))
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
        requestOtp: sl(),
        register: sl(),
        verifyOtp: sl(),
      ),
    )
    ..registerFactory(
      () => RegistrationOptionsCubit(getGovernorates: sl(), getSchools: sl(), getBranches: sl()),
    );
}

void _initCourses() {
  sl
    ..registerLazySingleton<CoursesRemoteDataSource>(() => CoursesRemoteDataSourceImpl(sl()))
    ..registerLazySingleton<CoursesRepository>(() => CoursesRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetCourses(sl()))
    ..registerLazySingleton(() => GetMyCourses(sl()))
    ..registerLazySingleton(() => GetCourseDetails(sl()))
    ..registerLazySingleton(() => GetLesson(sl()))
    ..registerLazySingleton(() => AttendLesson(sl()))
    ..registerLazySingleton(() => AddComment(sl()))
    ..registerLazySingleton(() => GetSubjects(sl()))
    ..registerLazySingleton(() => GetSubjectDetails(sl()))
    ..registerLazySingleton(() => SearchContent(sl()))
    ..registerFactory(() => CoursesCubit(sl()))
    ..registerFactory(() => CourseDetailsCubit(sl()))
    ..registerFactory(() => LessonCubit(getLesson: sl(), attendLesson: sl(), addComment: sl(), getCurrentUser: sl()))
    ..registerFactory(() => SubjectsCubit(sl()))
    ..registerFactory(() => SubjectDetailsCubit(sl()))
    ..registerFactory(() => MyCoursesCubit(sl()))
    ..registerFactory(() => SearchCubit(sl()));
}

void _initQuiz() {
  sl
    ..registerLazySingleton<QuizRemoteDataSource>(QuizMockDataSource.new)
    ..registerLazySingleton<QuizRepository>(() => QuizRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetMyExams(sl()))
    ..registerLazySingleton(() => GetMyActivities(sl()))
    ..registerLazySingleton(() => GetQuiz(sl()))
    ..registerFactory(() => QuizBloc(getMyExams: sl(), getMyActivities: sl(), getQuiz: sl()));
}

void _initHome() {
  sl
    ..registerLazySingleton<NewsRemoteDataSource>(NewsMockDataSource.new)
    ..registerLazySingleton<NewsRepository>(() => NewsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetNews(sl()))
    ..registerFactory(
      () => HomeCubit(
        getCourses: sl(),
        getSubjects: sl(),
        getNews: sl(),
        getCurrentUser: sl(),
        refreshProfile: sl(),
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
    ..registerLazySingleton<NotificationsRemoteDataSource>(() => NotificationsRemoteDataSourceImpl(sl()))
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
    ..registerLazySingleton<SubscriptionRemoteDataSource>(() => SubscriptionRemoteDataSourceImpl(sl()))
    ..registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetPackages(sl()))
    ..registerLazySingleton(() => GetPackageSubjects(sl()))
    ..registerLazySingleton(() => GetPaymentMethods(sl()))
    ..registerLazySingleton(() => SubscribeWithCode(sl()))
    ..registerFactory(() => SubscriptionCubit(getPackages: sl(), subscribeWithCode: sl()))
    ..registerFactory(() => CheckoutCubit(getPackages: sl(), getPaymentMethods: sl()))
    ..registerFactory(() => PackageSubjectsCubit(sl()));
}

void _initProfile() {
  sl.registerFactory(
    () => ProfileCubit(
      getCurrentUser: sl(),
      refreshProfile: sl(),
      updateProfile: sl(),
      updateProfileImage: sl(),
      logout: sl(),
    ),
  );
}

void _initSupport() {
  sl
    ..registerLazySingleton<SupportRemoteDataSource>(() => SupportRemoteDataSourceImpl(sl()))
    ..registerLazySingleton<SupportRepository>(() => SupportRepositoryImpl(sl()))
    ..registerLazySingleton(() => SendContactMessage(sl()))
    ..registerLazySingleton(() => GetContactLinks(sl()))
    ..registerFactory(() => ContactCubit(sl()))
    ..registerFactory(() => AboutCubit(sl()));
}

void _initDownloads() {
  sl
    ..registerLazySingleton<DownloadsLocalDataSource>(DownloadsMockDataSource.new)
    ..registerLazySingleton<DownloadsRepository>(() => DownloadsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetDownloads(sl()))
    ..registerFactory(() => DownloadsCubit(sl()));
}
