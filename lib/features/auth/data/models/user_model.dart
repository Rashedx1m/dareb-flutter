import '../../domain/entities/user.dart';

/// المستخدم كما يعيده الخادم في `auth/active` و`profile/get` و`users/edit`.
class UserModel extends User {
  UserModel({
    required super.id,
    required super.phone,
    this.firstName,
    this.lastName,
    super.email,
    super.avatarUrl,
    super.points,
    super.enrolledCoursesCount,
  }) : super(
    name: [firstName, lastName].whereType<String>().join(' '),
    // الحساب الجديد يصل بـ f_name فارغ إلى أن يُكمل عبر users/edit.
    isProfileComplete: firstName != null && firstName.isNotEmpty,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: '${json['id']}',
      phone: json['phone'] as String,
      firstName: json['f_name'] as String?,
      lastName: json['l_name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['image'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 0,
      enrolledCoursesCount: (json['subject_count'] as num?)?.toInt() ?? 0,
    );
  }

  final String? firstName;
  final String? lastName;

  /// بمفاتيح الخادم نفسها، لحفظ الجلسة محلياً وقراءتها لاحقاً بـ [UserModel.fromJson].
  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'f_name': firstName,
    'l_name': lastName,
    'email': email,
    'image': avatarUrl,
    'points': points,
    'subject_count': enrolledCoursesCount,
  };
}