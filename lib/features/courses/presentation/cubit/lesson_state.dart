part of 'lesson_cubit.dart';

enum LessonStatus { initial, loading, success, failure }

/// حالة تسجيل الحضور، منفصلة عن تحميل الصفحة لأن فشلها لا يمنع عرض الدرس.
enum AttendStatus { idle, sending, done, failure }

class LessonState extends Equatable {
  const LessonState({
    this.status = LessonStatus.initial,
    this.details,
    this.attendStatus = AttendStatus.idle,
    this.error,
  });

  final LessonStatus status;

  /// موجودة دائماً مع `success`.
  final LessonDetails? details;
  final AttendStatus attendStatus;

  /// يُعرض فقط مع `failure`.
  final String? error;

  LessonState copyWith({
    LessonStatus? status,
    LessonDetails? details,
    AttendStatus? attendStatus,
    String? error,
  }) {
    return LessonState(
      status: status ?? this.status,
      details: details ?? this.details,
      attendStatus: attendStatus ?? this.attendStatus,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, details, attendStatus, error];
}
