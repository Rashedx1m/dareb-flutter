import '../../../../core/data/mock_catalog.dart';
import '../../domain/entities/app_notification.dart';

/// مصدر الإشعارات. يرمي `ServerException` عند الفشل، والمستودع يحوّله إلى Failure.
abstract class NotificationsRemoteDataSource {
  Future<List<AppNotification>> getNotifications();
}

/// تنفيذ تجريبي من [MockCatalog]، يُستبدل بتنفيذ الـ API في حقن الاعتماديات فقط.
class NotificationsMockDataSource implements NotificationsRemoteDataSource {
  const NotificationsMockDataSource();

  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future<void>.delayed(MockCatalog.latency);
    return MockCatalog.notifications;
  }
}
