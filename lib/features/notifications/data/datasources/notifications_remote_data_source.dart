import '../../../../core/network/api_client.dart';
import '../models/app_notification_model.dart';

/// إشعارات المستخدم من الخادم. ترمي استثناءات [ApiClient] عند الفشل.
abstract class NotificationsRemoteDataSource {
  Future<List<AppNotificationModel>> getNotifications();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  /// الخادم يرتّبها من الأحدث إلى الأقدم، ويعلّمها مقروءة بعد هذا الطلب: غير
  /// المقروء يصل بـ `is_read: 0` في أول جلب فقط.
  @override
  Future<List<AppNotificationModel>> getNotifications() {
    return _client.get(
      '/notifications/get',
      parse: (data) => [
        for (final json in (data as List).cast<Map<String, dynamic>>()) AppNotificationModel.fromJson(json),
      ],
    );
  }
}
