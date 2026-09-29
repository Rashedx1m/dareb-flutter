import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/usecases/get_courses.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/usecases/get_news.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this._getCourses,
    required this._getCategories,
    required this._getNews,
    required this._getCurrentUser,
  }) : super(const HomeState());

  final GetCourses _getCourses;
  final GetCategories _getCategories;
  final GetNews _getNews;
  final GetCurrentUserUseCase _getCurrentUser;

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    final (courses, categories, news, user) = await (
      _getCourses(const NoParams()),
      _getCategories(const NoParams()),
      _getNews(const NoParams()),
      _getCurrentUser(const NoParams()),
    ).wait;
    if (isClosed) return;

    // الدورات والمواد والأخبار شرط لعرض الصفحة؛ أول فشل بينها يُعرض للمستخدم.
    final content = courses.flatMap(
      (c) => categories.flatMap(
        (cats) => news.map((n) => (courses: c, categories: cats, news: n)),
      ),
    );
    emit(
      content.fold(
        (f) => state.copyWith(status: HomeStatus.failure, error: f.message),
        (data) => state.copyWith(
          status: HomeStatus.success,
          courses: data.courses,
          categories: data.categories,
          news: data.news,
          // بيانات المستخدم ليست شرطاً للعرض: فشل قراءتها يُبقي الترويسة بقيم صفرية.
          user: user.getOrElse(() => null),
          curriculumCoursesCount:
              data.categories.fold<int>(0, (sum, c) => sum + c.coursesCount),
        ),
      ),
    );
  }
}
