part of 'registration_options_cubit.dart';

enum OptionsStatus { initial, loading, success, failure }

class RegistrationOptionsState extends Equatable {
  const RegistrationOptionsState({
    this.status = OptionsStatus.initial,
    this.governorates = const [],
    this.branches = const [],
    this.error,
    this.schoolsStatus = OptionsStatus.initial,
    this.schoolsQuery,
    this.schools = const [],
    this.schoolsError,
  });

  /// حالة تحميل المحافظات والفروع معاً.
  final OptionsStatus status;
  final List<LookupOption> governorates;
  final List<LookupOption> branches;
  final String? error;

  /// المدارس تُحمَّل منفصلة لأنها تتبع اختيار المستخدم.
  final OptionsStatus schoolsStatus;
  final SchoolsQuery? schoolsQuery;
  final List<LookupOption> schools;
  final String? schoolsError;

  RegistrationOptionsState copyWith({
    OptionsStatus? status,
    List<LookupOption>? governorates,
    List<LookupOption>? branches,
    String? error,
    OptionsStatus? schoolsStatus,
    SchoolsQuery? schoolsQuery,
    List<LookupOption>? schools,
    String? schoolsError,
  }) {
    return RegistrationOptionsState(
      status: status ?? this.status,
      governorates: governorates ?? this.governorates,
      branches: branches ?? this.branches,
      // كل رسالة خطأ لا تُعرض إلا مع حالة failure الخاصة بها، فبقاؤها آمن.
      error: error ?? this.error,
      schoolsStatus: schoolsStatus ?? this.schoolsStatus,
      schoolsQuery: schoolsQuery ?? this.schoolsQuery,
      schools: schools ?? this.schools,
      schoolsError: schoolsError ?? this.schoolsError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        governorates,
        branches,
        error,
        schoolsStatus,
        schoolsQuery,
        schools,
        schoolsError,
      ];
}
