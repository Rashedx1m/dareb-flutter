part of 'course_details_cubit.dart';

enum CourseDetailsStatus { initial, loading, success, failure }

class CourseDetailsState extends Equatable {
  const CourseDetailsState({
    this.status = CourseDetailsStatus.initial,
    this.details,
    this.error,
  });

  final CourseDetailsStatus status;

  /// موجودة دائماً مع `success`.
  final CourseDetails? details;

  /// يُعرض فقط مع `failure`.
  final String? error;

  CourseDetailsState copyWith({CourseDetailsStatus? status, CourseDetails? details, String? error}) {
    return CourseDetailsState(
      status: status ?? this.status,
      details: details ?? this.details,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, details, error];
}
