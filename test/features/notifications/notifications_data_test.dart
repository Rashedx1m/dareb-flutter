import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:educational_app/features/notifications/data/models/app_notification_model.dart';
import 'package:educational_app/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:educational_app/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_adapter.dart';

/// عنصر من رد `notifications/get` كما أعاده خادم التدريب في 2026-10-09.
const _json = {
  'id': 2,
  'title': 'Test2',
  'text': 'test2',
  'created_at': '2026-10-04 15:52:33',
  'updated_at': '2026-10-04 15:52:33',
  'pivot': {
    'notifiable_type': r'App\Models\User',
    'notifiable_id': 30,
    'notification_id': 2,
    'is_read': 1,
  },
};

void main() {
  test('fromJson: النص من text، وحالة القراءة من pivot', () {
    // Equatable يقارن النوع أيضاً، فالمتوقَّع Model لا Entity.
    expect(
      AppNotificationModel.fromJson(_json),
      AppNotificationModel(
        id: '2',
        title: 'Test2',
        body: 'test2',
        createdAt: DateTime.utc(2026, 10, 4, 15, 52, 33).toLocal(),
        isRead: true,
      ),
    );
  });

  test('is_read = 0 يعني غير مقروء', () {
    final json = {..._json, 'pivot': {'is_read': 0}};
    expect(AppNotificationModel.fromJson(json).isRead, isFalse);
  });

  group('المصدر والمستودع', () {
    late FakeHttpAdapter adapter;
    late NotificationsRepositoryImpl repository;

    setUp(() {
      adapter = FakeHttpAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
      repository = NotificationsRepositoryImpl(
        NotificationsRemoteDataSourceImpl(ApiClient(readToken: () => '30|abc', dio: dio)),
      );
    });

    test('القائمة من notifications/get بتوكن الجلسة', () async {
      adapter.on('/notifications/get', body: {'message': 'الإشعارات الموجودة', 'data': [_json]});

      final items = (await repository.getNotifications()).getOrElse(() => []);

      expect(items.single.title, 'Test2');
      expect(adapter.requests.single.headers['Authorization'], 'Bearer 30|abc');
    });

    test('إشعار بلا pivot يصير «رد غير متوقع» بدل أن تتجمد الشاشة', () async {
      adapter.on('/notifications/get', body: {
        'message': '',
        'data': [
          {'id': 1, 'title': 'x', 'text': 'y', 'created_at': '2026-10-04 15:52:33'},
        ],
      });

      expect(
        await repository.getNotifications(),
        const Left<Failure, List<AppNotification>>(ServerFailure('رد غير متوقع من الخادم')),
      );
    });
  });
}