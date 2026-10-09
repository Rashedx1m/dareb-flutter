part of 'profile_cubit.dart';

enum SaveStatus { idle, sending, done, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.user,
    this.loggedOut = false,
    this.saveStatus = SaveStatus.idle,
    this.saveError,
    this.avatarStatus = SaveStatus.idle,
    this.avatarError,
  });

  /// `null` إلى أن تُقرأ الجلسة.
  final User? user;
  final bool loggedOut;

  /// حالة حفظ ورقة التعديل.
  final SaveStatus saveStatus;
  final String? saveError;

  /// حالة رفع صورة الملف الشخصي.
  final SaveStatus avatarStatus;
  final String? avatarError;

  ProfileState copyWith({
    User? user,
    bool? loggedOut,
    SaveStatus? saveStatus,
    String? saveError,
    SaveStatus? avatarStatus,
    String? avatarError,
  }) {
    return ProfileState(
      user: user ?? this.user,
      loggedOut: loggedOut ?? this.loggedOut,
      saveStatus: saveStatus ?? this.saveStatus,
      // الرسائل لا تُعرض إلا مع حالة failure الخاصة بها، فبقاؤها آمن.
      saveError: saveError ?? this.saveError,
      avatarStatus: avatarStatus ?? this.avatarStatus,
      avatarError: avatarError ?? this.avatarError,
    );
  }

  @override
  List<Object?> get props => [user, loggedOut, saveStatus, saveError, avatarStatus, avatarError];
}
