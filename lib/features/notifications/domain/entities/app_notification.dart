import 'package:equatable/equatable.dart';

/// إشعار من `notifications/get`.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  @override
  List<Object?> get props => [id, title, body, createdAt, isRead];
}
