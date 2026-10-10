import '../../domain/entities/app_notification.dart';

/// إشعار كما يعيده `notifications/get`: النص في `text`، وحالة القراءة لكل
/// مستخدم في `pivot.is_read` (0 أو 1).
class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.createdAt,
    required super.isRead,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'] as Map<String, dynamic>;
    return AppNotificationModel(
      id: '${json['id']}',
      title: json['title'] as String,
      body: json['text'] as String,
      createdAt: _date(json['created_at'] as String),
      isRead: pivot['is_read'] == 1,
    );
  }

  /// `created_at` بتوقيت UTC بالشكل "2026-10-04 15:52:33" بلا علامة المنطقة،
  /// فنضيفها ثم نحوّله إلى توقيت الجهاز.
  static DateTime _date(String value) => DateTime.parse('${value}Z').toLocal();
}