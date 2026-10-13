part of 'lesson_cubit.dart';

enum LessonStatus { initial, loading, success, failure }

/// حالة تسجيل الحضور، منفصلة عن تحميل الصفحة لأن فشلها لا يمنع عرض الدرس.
enum AttendStatus { idle, sending, done, failure }

/// حالة إرسال التعليق.
enum CommentStatus { idle, sending, done, failure }

class LessonState extends Equatable {
  const LessonState({
    this.status = LessonStatus.initial,
    this.details,
    this.user,
    this.attendStatus = AttendStatus.idle,
    this.commentStatus = CommentStatus.idle,
    this.error,
    this.commentError,
  });

  final LessonStatus status;

  /// موجودة دائماً مع `success`.
  final LessonDetails? details;

  /// الطالب صاحب الجلسة، وقد يكون `null` إن تعذّرت قراءته.
  final User? user;
  final AttendStatus attendStatus;
  final CommentStatus commentStatus;

  /// يُعرض فقط مع `failure`.
  final String? error;

  /// يُعرض فقط مع `CommentStatus.failure`.
  final String? commentError;

  LessonState copyWith({
    LessonStatus? status,
    LessonDetails? details,
    User? user,
    AttendStatus? attendStatus,
    CommentStatus? commentStatus,
    String? error,
    String? commentError,
  }) {
    return LessonState(
      status: status ?? this.status,
      details: details ?? this.details,
      user: user ?? this.user,
      attendStatus: attendStatus ?? this.attendStatus,
      commentStatus: commentStatus ?? this.commentStatus,
      error: error,
      commentError: commentError,
    );
  }

  @override
  List<Object?> get props => [status, details, user, attendStatus, commentStatus, error, commentError];
}
