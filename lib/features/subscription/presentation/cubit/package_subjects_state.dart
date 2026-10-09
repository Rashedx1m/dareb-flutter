part of 'package_subjects_cubit.dart';

enum SubjectsStatus { initial, loading, success, failure }

class PackageSubjectsState extends Equatable {
  const PackageSubjectsState({this.status = SubjectsStatus.initial, this.subjects = const [], this.error});

  final SubjectsStatus status;
  final List<PackageSubject> subjects;
  final String? error;

  @override
  List<Object?> get props => [status, subjects, error];
}
