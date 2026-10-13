part of 'subject_details_cubit.dart';

enum SubjectDetailsStatus { initial, loading, success, failure }

class SubjectDetailsState extends Equatable {
  const SubjectDetailsState({this.status = SubjectDetailsStatus.initial, this.details, this.error});

  final SubjectDetailsStatus status;

  /// موجودة دائماً مع `success`.
  final SubjectDetails? details;

  /// يُعرض فقط مع `failure`.
  final String? error;

  SubjectDetailsState copyWith({SubjectDetailsStatus? status, SubjectDetails? details, String? error}) {
    return SubjectDetailsState(
      status: status ?? this.status,
      details: details ?? this.details,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, details, error];
}
