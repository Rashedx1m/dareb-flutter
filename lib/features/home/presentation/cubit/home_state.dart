part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.sliders = const [],
    this.courses = const [],
    this.subjects = const [],
    this.news = const [],
    this.user,
    this.progress = 0,
    this.curriculumCoursesCount = 0,
    this.error,
  });

  final HomeStatus status;
  final List<HomeBanner> sliders;
  final List<Course> courses;
  final List<Subject> subjects;
  final List<NewsItem> news;

  /// مستخدم الجلسة، ومنه الاسم والنقاط في الترويسة.
  final User? user;

  /// نسبة إنجاز المنهاج بين 0 و1 من `home-page/index`.
  final double progress;

  /// عدد مواد المستخدم في بطاقة التقدم، من `subject_count`.
  final int curriculumCoursesCount;
  final String? error;

  /// نقاط المستخدم المعروضة في الترويسة.
  int get points => user?.points ?? 0;

  HomeState copyWith({
    HomeStatus? status,
    List<HomeBanner>? sliders,
    List<Course>? courses,
    List<Subject>? subjects,
    List<NewsItem>? news,
    User? user,
    double? progress,
    int? curriculumCoursesCount,
    String? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      sliders: sliders ?? this.sliders,
      courses: courses ?? this.courses,
      subjects: subjects ?? this.subjects,
      news: news ?? this.news,
      user: user ?? this.user,
      progress: progress ?? this.progress,
      curriculumCoursesCount: curriculumCoursesCount ?? this.curriculumCoursesCount,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, sliders, courses, subjects, news, user, progress, curriculumCoursesCount, error];
}
