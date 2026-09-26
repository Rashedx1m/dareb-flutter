import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/mock_catalog.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/usecases/get_courses.dart';
import '../../domain/entities/news_item.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetCourses getCourses,
    required GetCategories getCategories,
  })  : _getCourses = getCourses,
        _getCategories = getCategories,
        super(const HomeState());

  final GetCourses _getCourses;
  final GetCategories _getCategories;

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    final courses = await _getCourses(const NoParams());
    final categories = await _getCategories(const NoParams());

    courses.fold(
      (f) => emit(state.copyWith(status: HomeStatus.failure, error: f.message)),
      (list) {
        categories.fold(
          (f) => emit(state.copyWith(status: HomeStatus.failure, error: f.message)),
          (cats) => emit(
            state.copyWith(
              status: HomeStatus.success,
              courses: list,
              categories: cats,
              news: MockCatalog.news,
              progress: MockCatalog.user.progress,
              points: MockCatalog.user.points,
              curriculumCoursesCount:
                  cats.fold<int>(0, (sum, c) => sum + c.coursesCount),
            ),
          ),
        );
      },
    );
  }
}
