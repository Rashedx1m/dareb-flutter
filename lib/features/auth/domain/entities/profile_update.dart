import 'package:equatable/equatable.dart';

/// ما يقبل الخادم تعديله في `users/update`: الاسم والمدرسة فقط، وكلها مطلوبة.
/// البريد والفرع والعمر يتجاهلها الخادم هناك، والهاتف هوية الحساب.
class ProfileUpdate extends Equatable {
  const ProfileUpdate({
    required this.firstName,
    required this.lastName,
    required this.schoolId,
  });

  final String firstName;
  final String lastName;
  final String schoolId;

  @override
  List<Object?> get props => [firstName, lastName, schoolId];
}
