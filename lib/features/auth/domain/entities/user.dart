import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.progress = 0,
    this.points = 0,
    this.enrolledCoursesCount = 0,
    this.isProfileComplete = true,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  /// `false` لحساب فعّل رقمه ولم يُكمل بياناته بعد (الاسم والمدرسة والفرع).
  final bool isProfileComplete;

  /// نسبة إنجاز المسار التعليمي بين 0 و1.
  final double progress;

  /// نقاط المستخدم المكتسبة (تظهر في ترويسة الصفحة الرئيسية).
  final int points;

  /// عدد الدورات المسجّل بها المستخدم.
  final int enrolledCoursesCount;

  @override
  List<Object?> get props =>
      [id, name, phone, email, avatarUrl, progress, points, enrolledCoursesCount,isProfileComplete];
}
