import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../auth/domain/usecases/refresh_profile.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/entities/subject.dart';
import '../../domain/entities/home_banner.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/usecases/get_home.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this._getHome,
    required this._getCurrentUser,
    required this._refreshProfile,
  }) : super(const HomeState());

  final GetHome _getHome;
  final GetCurrentUser _getCurrentUser;
  final RefreshProfile _refreshProfile;

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    final (feed, cachedUser, freshUser) = await (
      _getHome(const NoParams()),
      _getCurrentUser(const NoParams()),
      // النقاط والاسم يتغيّران على الخادم، فتُحدَّث مع كل ظهور للصفحة.
      _refreshProfile(const NoParams()),
    ).wait;
    if (isClosed) return;

    emit(
      feed.fold(
        (failure) => state.copyWith(status: HomeStatus.failure, error: failure.message),
        (data) => state.copyWith(
          status: HomeStatus.success,
          sliders: data.sliders,
          courses: data.courses,
          subjects: data.subjects,
          news: data.news,
          progress: data.completionRate,
          curriculumCoursesCount: data.subjectCount,
          // بيانات المستخدم ليست شرطاً للعرض: إن تعذّر تحديثها تُعرض النسخة
          // المحفوظة، وبلا جلسة تبقى الترويسة بقيم صفرية.
          user: freshUser.fold((_) => cachedUser.getOrElse(() => null), (user) => user),
        ),
      ),
    );
  }
}
