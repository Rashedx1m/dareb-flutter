import 'package:educational_app/core/di/injection.dart';
import 'package:educational_app/core/router/app_router.dart';
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
}
