import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/request_otp_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/courses/data/repositories/courses_repository_impl.dart';
import '../../features/courses/domain/repositories/courses_repository.dart';
import '../../features/courses/domain/usecases/get_courses.dart';
import '../../features/courses/presentation/bloc/courses_bloc.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/quiz/data/repositories/quiz_repository_impl.dart';
import '../../features/quiz/domain/repositories/quiz_repository.dart';
import '../../features/quiz/domain/usecases/get_quizzes.dart';
import '../../features/quiz/presentation/bloc/quiz_bloc.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../storage/session_storage.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<SessionStorage>(
      () => SharedPreferencesSessionStorage(sl()),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    ..registerLazySingleton<CoursesRepository>(CoursesRepositoryImpl.new)
    ..registerLazySingleton<QuizRepository>(QuizRepositoryImpl.new)
    ..registerLazySingleton(() => RequestOtpUseCase(sl()))
    ..registerLazySingleton(() => RegisterUseCase(sl()))
    ..registerLazySingleton(() => VerifyOtpUseCase(sl()))
    ..registerLazySingleton(() => GetCourses(sl()))
    ..registerLazySingleton(() => GetMyCourses(sl()))
    ..registerLazySingleton(() => GetCourse(sl()))
    ..registerLazySingleton(() => GetCategories(sl()))
    ..registerLazySingleton(() => SearchCourses(sl()))
    ..registerLazySingleton(() => GetQuizzes(sl()))
    ..registerLazySingleton(() => GetQuiz(sl()))
    ..registerFactory(
      () => AuthCubit(
        requestOtpUseCase: sl(),
        registerUseCase: sl(),
        verifyOtpUseCase: sl(),
      ),
    )
    ..registerFactory(() => HomeCubit(getCourses: sl(), getCategories: sl()))
    ..registerFactory(
      () => CoursesBloc(
        getCourses: sl(),
        getCourse: sl(),
        searchCourses: sl(),
        getCategories: sl(),
      ),
    )
    ..registerFactory(() => QuizBloc(getQuizzes: sl(), getQuiz: sl()))
    ..registerFactory(() => SearchCubit(sl()))
    ..registerFactory(() => ProfileCubit(sl()));
}
