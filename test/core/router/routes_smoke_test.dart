import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:educational_app/core/di/injection.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/core/router/app_router.dart';
import 'package:educational_app/core/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_http_adapter.dart';

/// يتأكد أن كل مسار يوفّر لصفحته الـ Cubit/Bloc الذي تقرأ منه، وأنها تحمّل
/// بياناتها دون خطأ. أضف هنا كل مسار جديد يعتمد على Cubit.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userJson = {
    'id': 30,
    'f_name': 'أحمد',
    'l_name': 'علي',
    'phone': '0930000000',
    'school': {'id': 7, 'name': 'مدرسة يامن', 'governorate': 'damascus'},
  };

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'auth.user': jsonEncode(userJson)});
    await initDependencies();

    // لا اتصال حقيقي: طلب حقيقي يبقى معلّقاً بعد انتهاء الاختبار، أما المحوّل
    // المزيّف فيردّ ضمن وقت الاختبار.
    final adapter = FakeHttpAdapter()
      ..on('/profile/get', body: {'message': 'ok', 'data': userJson})
      ..on('/governorates/all', body: {'message': 'ok', 'data': {'damascus': 'دمشق'}})
      ..on('/branches/all', body: {'message': 'ok', 'data': []});
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
    sl
      ..unregister<ApiClient>()
      ..registerLazySingleton(() => ApiClient(readToken: () => null, dio: dio));
  });

  const paths = [
    '/notifications',
    '/achievements',
    '/subscription',
    '/checkout?plan=monthly',
    '/gallery',
    '/gallery/gal_math',
    '/gallery/gal_math/photo/1',
    '/tests',
    '/profile',
    '/edit-profile',
    '/my-courses',
    '/home',
  ];

  for (final path in paths) {
    testWidgets('يفتح $path ويحمّل بياناته', (tester) async {
      final router = createRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go(path);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(router.routerDelegate.currentConfiguration.uri.toString(), path);
      expect(find.byType(LoadingView), findsNothing);
      expect(find.byType(ErrorView), findsNothing);
    });
  }
}
