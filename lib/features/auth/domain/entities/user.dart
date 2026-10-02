import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
    this.school,
    this.progress = 0,
    this.points = 0,
    this.enrolledCoursesCount = 0,
    this.isProfileComplete = true,
  });

  final String id;

  /// الاسم الكامل للعرض.
  final String name;
  final String phone;

  /// الاسم الأول والأخير منفصلين كما يحفظهما الخادم، لنموذج تعديل الملف.
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;

  /// المدرسة أو المعهد. `null` إن لم تصل مع الرد، فرد `auth/active` لا يتضمنها.
  final School? school;
  /// `false` لحساب فعّل رقمه ولم يُكمل بياناته بعد (الاسم والمدرسة والفرع).
  final bool isProfileComplete;

  /// نسبة إنجاز المسار التعليمي بين 0 و1.
  final double progress;

  /// نقاط المستخدم المكتسبة (تظهر في ترويسة الصفحة الرئيسية).
  final int points;

  /// عدد الدورات المسجّل بها المستخدم.
  final int enrolledCoursesCount;

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        firstName,
        lastName,
        email,
        avatarUrl,
        school,
        progress,
        points,
        enrolledCoursesCount,
        isProfileComplete,
      ];
}

/// الجهة الدراسية للمستخدم كما يعيدها الخادم.
class School extends Equatable {
  const School({required this.id, required this.name, this.governorateId});

  final String id;
  final String name;

  /// مفتاح المحافظة في `governorates/all`، مثل "damascus".
  final String? governorateId;

  @override
  List<Object?> get props => [id, name, governorateId];
}
