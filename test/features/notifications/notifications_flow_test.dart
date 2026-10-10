import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/theme/app_colors.dart';
import 'package:educational_app/core/theme/app_icons.dart';
import 'package:educational_app/core/widgets/error_view.dart';
import 'package:educational_app/features/notifications/domain/entities/app_notification.dart';
import 'package:educational_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:educational_app/features/notifications/domain/usecases/get_notifications.dart';
import 'package:educational_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:educational_app/features/notifications/presentation/notification_date.dart';
import 'package:educational_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final _read = AppNotification(
  id: '1',
  title: 'Test',
  body: 'test',
  createdAt: DateTime(2026, 10, 4, 15, 51),
  isRead: true,
);
final _unread = AppNotification(
  id: '2',
  title: 'Test2',
  body: 'test2',
  createdAt: DateTime(2026, 10, 4, 18, 52),
  isRead: false,
);

/// مستودع مزيّف يُرجع النتائج بالترتيب، نتيجة لكل طلب.
class _FakeRepository implements NotificationsRepository {
  _FakeRepository(this.results);
  final List<Either<Failure, List<AppNotification>>> results;

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async => results.removeAt(0);
}

Future<void> _pumpPage(WidgetTester tester, List<Either<Failure, List<AppNotification>>> results) async {
  tester.view
    // خط الاختبار يعطي كل حرف عرضاً يساوي حجمه، فالنص العربي أعرض منه على الجهاز.
    ..physicalSize = const Size(1800, 3600)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => NotificationsCubit(GetNotifications(_FakeRepository(results)))..load(),
        child: const NotificationsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('notificationDateLabel', () {
    test('منتصف الليل 12:00 صباحًا كما في التصميم', () {
      expect(notificationDateLabel(DateTime(2025, 4, 25)), '25 أبريل 2025 / 12:00 صباحًا');
    });

    test('بعد الظهر بنظام 12 ساعة', () {
      expect(notificationDateLabel(DateTime(2026, 10, 4, 18, 52)), '4 أكتوبر 2026 / 6:52 مساءً');
    });

    test('الظهر 12 مساءً، والدقائق برقمين', () {
      expect(notificationDateLabel(DateTime(2026, 1, 1, 12, 5)), '1 يناير 2026 / 12:05 مساءً');
    });
  });

  group('صفحة الإشعارات', () {
    testWidgets('تعرض الإشعارات بتاريخها، ونص غير المقروء فيروزي، وعدده في الترويسة', (tester) async {
      await _pumpPage(tester, [Right([_unread, _read])]);

      expect(find.text('Test2'), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('4 أكتوبر 2026 / 6:52 مساءً'), findsOneWidget);
      expect(tester.widget<Text>(find.text('test2')).style?.color, AppColors.primary);
      expect(tester.widget<Text>(find.text('test')).style?.color, AppColors.listText);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('لا رقم إن قُرئت كلها، ولا زر جرس في صفحة الإشعارات نفسها', (tester) async {
      await _pumpPage(tester, [Right([_read])]);

      expect(find.text('0'), findsNothing);
      expect(find.byIcon(PhosphorIconsFill.bell), findsNothing);
    });

    testWidgets('القائمة الفارغة تعرض رسالة', (tester) async {
      await _pumpPage(tester, [const Right([])]);

      expect(find.text(AppStrings.noNotifications), findsOneWidget);
    });

    testWidgets('الفشل يعرض رسالته، وإعادة المحاولة تجلب القائمة', (tester) async {
      await _pumpPage(tester, [const Left(ServerFailure('تعذّر الاتصال')), Right([_read])]);
      expect(find.text('تعذّر الاتصال'), findsOneWidget);

      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('Test'), findsOneWidget);
    });
  });
}
