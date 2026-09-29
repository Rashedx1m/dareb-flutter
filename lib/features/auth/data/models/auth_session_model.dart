import 'user_model.dart';

/// رد `auth/active`: توكن الجلسة ومستخدمها.
class AuthSessionModel {
  const AuthSessionModel({required this.token, required this.user});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String token;
  final UserModel user;
}