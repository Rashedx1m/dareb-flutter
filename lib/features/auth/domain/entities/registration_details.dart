import 'package:equatable/equatable.dart';

/// بيانات نموذج إنشاء الحساب كما تُجمع عبر خطوات صفحة التسجيل.
class RegistrationDetails extends Equatable {
  const RegistrationDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.school,
    required this.source,
    required this.schoolKind,
    required this.gender,
    required this.age,
    required this.track,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  /// اسم المدرسة أو المؤسسة التعليمية.
  final String school;

  /// كيف تعرّف المستخدم على التطبيق.
  final String source;

  /// نوع المؤسسة: مدرسة أو معهد.
  final String schoolKind;
  final String gender;
  final int age;

  /// الفرع الدراسي (علمي/أدبي/تجاري).
  final String track;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        phone,
        school,
        source,
        schoolKind,
        gender,
        age,
        track,
      ];
}
