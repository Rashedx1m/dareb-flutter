import 'package:educational_app/core/di/injection.dart';
import 'package:educational_app/core/network/session_expiry.dart';
import 'package:educational_app/core/router/app_router.dart';
import 'package:educational_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:educational_app/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
  });

  Future<GoRouter> pumpRouter(WidgetTester tester) async {
    final router = createRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    return router;
  }

  String location(GoRouter router) => router.routerDelegate.currentConfiguration.uri.path;

  testWidgets('بلا جلسة: أي صفحة داخلية تُحوَّل إلى الدخول', (tester) async {
    final router = await pumpRouter(tester);

    for (final path in ['/home', '/profile', '/my-courses', '/checkout']) {
      router.go(path);
      await tester.pump();
      expect(location(router), '/login', reason: path);
    }
  });

  testWidgets('بلا جلسة: صفحات الدخول متاحة', (tester) async {
    final router = await pumpRouter(tester);

    router.go('/login');
    await tester.pump();
    expect(location(router), '/login');
  });

  testWidgets('انتهاء الجلسة من الخادم يعيد المستخدم إلى الدخول', (tester) async {
    final local = sl<AuthLocalDataSource>();
    addTearDown(local.clear);
    await local.saveToken('30|abc');
    await local.saveUser(UserModel(id: '30', phone: '0930000000', firstName: 'أحمد'));
    final router = await pumpRouter(tester);
    router.go('/about');
    await tester.pump();
    expect(location(router), '/about');

    await sl<SessionExpiry>().expire();
    await tester.pump();

    expect(location(router), '/login');
    expect(local.token, isNull);
  });
}
