import 'package:equatable/equatable.dart';

/// كيف تعرّف المستخدم على التطبيق.
enum AppSource { school, friend, facebook, instagram, youtube, other }

enum Gender { female, male }

/// بيانات إكمال الحساب كما تُجمع عبر خطوات صفحة التسجيل. رقم الهاتف لا يُرسل
/// هنا لأن الخادم عرفه عند التحقق من الرمز.
class RegistrationDetails extends Equatable {
  const RegistrationDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.source,
    required this.schoolId,
    required this.gender,
    required this.age,
    required this.branchId,
  });

  final String firstName;
  final String lastName;
  final String email;
  final AppSource source;

  /// معرّف المدرسة أو المعهد من قائمة الخادم.
  final String schoolId;
  final Gender gender;
  final int age;

  /// معرّف الفرع الدراسي من قائمة الخادم.
  final String branchId;

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        source,
        schoolId,
        gender,
        age,
        branchId,
      ];
}
