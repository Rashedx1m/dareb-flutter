part of 'achievements_cubit.dart';

enum AchievementsStatus { initial, loading, success, failure }

class AchievementsState extends Equatable {
  const AchievementsState({
    this.status = AchievementsStatus.initial,
    this.user,
    this.courses = const [],
    this.error,
  });

  final AchievementsStatus status;
  final User? user;
  final List<Course> courses;
  final String? error;

  /// مجموع دروس المواد المشترك بها؛ الملف لا يعيد عدد الدروس.
  int get lessonsCount => courses.fold(0, (sum, course) => sum + course.lessonsCount);

  AchievementsState copyWith({
    AchievementsStatus? status,
    User? user,
    List<Course>? courses,
    String? error,
  }) {
    return AchievementsState(
      status: status ?? this.status,
      user: user ?? this.user,
      courses: courses ?? this.courses,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, user, courses, error];
}
