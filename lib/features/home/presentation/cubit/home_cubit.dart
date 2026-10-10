import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/usecases/refresh_profile.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/entities/subject.dart';
import '../../../courses/domain/usecases/get_courses.dart';
import '../../../courses/domain/usecases/get_subjects.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/usecases/get_news.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this._getCourses,
    required this._getSubjects,
    required this._getNews,
    required this._getCurrentUser,
    required this._refreshProfile,
  }) : super(const HomeState());

  final GetCourses _getCourses;
  final GetSubjects _getSubjects;
  final GetNews _getNews;
  final GetCurrentUser _getCurrentUser;
  final RefreshProfile _refreshProfile;

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    final (courses, subjects, news, cachedUser, freshUser) = await (
      _getCourses(const NoParams()),
      _getSubjects(const NoParams()),
      _getNews(const NoParams()),
      _getCurrentUser(const NoParams()),
      // النقاط وعدد المواد تتغير على الخادم، فتُحدَّث مع كل فتح للصفحة.
      _refreshProfile(const NoParams()),
    ).wait;
    if (isClosed) return;

    // الدورات والمواد والأخبار شرط لعرض الصفحة؛ أول فشل بينها يُعرض للمستخدم.
    final content = courses.flatMap(
      (c) => subjects.flatMap(
        (s) => news.map((n) => (courses: c, subjects: s, news: n)),
      ),
    );
    emit(
      content.fold(
        (f) => state.copyWith(status: HomeStatus.failure, error: f.message),
        (data) => state.copyWith(
          status: HomeStatus.success,
          courses: data.courses,
          subjects: data.subjects,
          news: data.news,
          // بيانات المستخدم ليست شرطاً للعرض: إن تعذّر تحديثها تُعرض النسخة
          // المحفوظة، وبلا جلسة تبقى الترويسة بقيم صفرية.
          user: freshUser.fold((_) => cachedUser.getOrElse(() => null), (user) => user),
          curriculumCoursesCount: data.courses.length,
        ),
      ),
    );
  }
}
