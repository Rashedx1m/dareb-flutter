import '../../domain/entities/user.dart';

/// المستخدم كما يعيده الخادم في `auth/active` و`profile/get` و`users/edit`
/// و`users/update`.
class UserModel extends User {
  UserModel({
    required super.id,
    required super.phone,
    super.firstName,
    super.lastName,
    super.email,
    super.avatarUrl,
    super.school,
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
      school: _school(json['school']),
      points: (json['points'] as num?)?.toInt() ?? 0,
      enrolledCoursesCount: (json['subject_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// `school` غائب عن رد `auth/active`، فغيابه ليس خطأً في الرد.
  static School? _school(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    return School(
      id: '${json['id']}',
      name: json['name'] as String,
      governorateId: json['governorate'] as String?,
    );
  }

  /// بمفاتيح الخادم نفسها، لحفظ الجلسة محلياً وقراءتها لاحقاً بـ [UserModel.fromJson].
  Map<String, dynamic> toJson() {
    final school = this.school;
    return {
      'id': id,
      'phone': phone,
      'f_name': firstName,
      'l_name': lastName,
      'email': email,
      'image': avatarUrl,
      if (school != null)
        'school': {'id': school.id, 'name': school.name, 'governorate': school.governorateId},
      'points': points,
      'subject_count': enrolledCoursesCount,
    };
  }
}
