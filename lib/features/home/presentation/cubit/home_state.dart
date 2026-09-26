part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.courses = const [],
    this.categories = const [],
    this.news = const [],
    this.progress = 0,
    this.points = 0,
    this.curriculumCoursesCount = 0,
    this.error,
  });

  final HomeStatus status;
  final List<Course> courses;
  final List<Category> categories;
  final List<NewsItem> news;
  final double progress;

  /// نقاط المستخدم المعروضة في الترويسة.
  final int points;

  /// إجمالي دورات المنهاج (مجموع دورات كل المواد) المعروض في بطاقة التقدم.
  final int curriculumCoursesCount;
  final String? error;

  HomeState copyWith({
    HomeStatus? status,
    List<Course>? courses,
    List<Category>? categories,
    List<NewsItem>? news,
    double? progress,
    int? points,
    int? curriculumCoursesCount,
    String? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      categories: categories ?? this.categories,
      news: news ?? this.news,
      progress: progress ?? this.progress,
      points: points ?? this.points,
      curriculumCoursesCount: curriculumCoursesCount ?? this.curriculumCoursesCount,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, courses, categories, news, progress, points, curriculumCoursesCount, error];
}
