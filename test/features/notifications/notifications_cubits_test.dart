import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/notifications/domain/entities/app_notification.dart';
import 'package:educational_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:educational_app/features/notifications/domain/usecases/get_notifications.dart';
import 'package:educational_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

final _item = AppNotification(
  id: '2',
  title: 'Test2',
  body: 'test2',
  createdAt: DateTime.utc(2026, 10, 4, 15, 52, 33),
  isRead: true,
);

/// مستودع مزيّف: كل طلب يُرجع ما تعيده [respond].
class _FakeRepository implements NotificationsRepository {
  _FakeRepository(this.respond);
  final Future<Either<Failure, List<AppNotification>>> Function() respond;

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() => respond();
}

NotificationsCubit _cubit(Future<Either<Failure, List<AppNotification>>> Function() respond) =>
    NotificationsCubit(GetNotifications(_FakeRepository(respond)));

void main() {
  test('يبدأ initial، ثم loading، ثم success بالقائمة', () async {
    final cubit = _cubit(() async => Right([_item]));
    expect(cubit.state.status, NotificationsStatus.initial);

    final states = expectLater(
      cubit.stream,
      emitsInOrder([
        const NotificationsState(status: NotificationsStatus.loading),
        NotificationsState(status: NotificationsStatus.success, items: [_item]),
      ]),
    );
    await cubit.load();
    await states;
  });

  test('الفشل يصل برسالته', () async {
    final cubit = _cubit(() async => const Left(ServerFailure('تعذّر الاتصال')));
    await cubit.load();

    expect(cubit.state, const NotificationsState(status: NotificationsStatus.failure, error: 'تعذّر الاتصال'));
  });

  test('إعادة المحاولة بعد الفشل تمسح رسالة الخطأ', () async {
    final results = <Either<Failure, List<AppNotification>>>[const Left(ServerFailure('x')), Right([_item])];
    final cubit = _cubit(() async => results.removeAt(0));

    await cubit.load();
    await cubit.load();

    expect(cubit.state, NotificationsState(status: NotificationsStatus.success, items: [_item]));
  });

  test('إغلاق الصفحة قبل وصول الرد لا يرمي خطأ', () async {
    final response = Completer<Either<Failure, List<AppNotification>>>();
    final cubit = _cubit(() => response.future);

    final loading = cubit.load();
    await cubit.close();
    response.complete(Right([_item]));

    await expectLater(loading, completes);
  });
}