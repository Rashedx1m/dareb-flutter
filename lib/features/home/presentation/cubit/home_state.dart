part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.courses = const [],
    this.subjects = const [],
    this.news = const [],
    this.user,
    this.curriculumCoursesCount = 0,
    this.error,
  });

  final HomeStatus status;
  final List<Course> courses;
  final List<Subject> subjects;
  final List<NewsItem> news;

  /// مستخدم الجلسة، ومنه الاسم والنقاط ونسبة الإنجاز المعروضة في الصفحة.
  final User? user;

  /// عدد دورات المنهاج المعروض في بطاقة التقدم، أي عدد الدورات المتاحة.
  final int curriculumCoursesCount;
  final String? error;

  double get progress => user?.progress ?? 0;

  /// نقاط المستخدم المعروضة في الترويسة.
  int get points => user?.points ?? 0;

  HomeState copyWith({
    HomeStatus? status,
    List<Course>? courses,
    List<Subject>? subjects,
    List<NewsItem>? news,
    User? user,
    int? curriculumCoursesCount,
    String? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      subjects: subjects ?? this.subjects,
      news: news ?? this.news,
      user: user ?? this.user,
      curriculumCoursesCount: curriculumCoursesCount ?? this.curriculumCoursesCount,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, courses, subjects, news, user, curriculumCoursesCount, error];
}
