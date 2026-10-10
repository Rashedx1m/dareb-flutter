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

  const courseJson = {
    'id': 1,
    'name': 'ناردين الشطناوي',
    'is_free': false,
    'course_name': 'الدكتور هناء القطيشات',
    'text': 'وصف',
    'professor': 'أكرم أبو الرب',
    'price': 36,
    'image': 'https://x/1.png',
    'semesters_count': 1,
    'lessions_count': 1,
    'subscriptions_count': 3,
    'is_subscription': false,
  };
  const lessonJson = {
    'id': 3,
    'name': 'رسلان الدين عباد',
    'is_free': true,
    'order': 6,
    'type': {'id': 2, 'name': 'Video'},
    'time': '11:50:51',
    'url': 'https://www.youtube.com/watch?v=q0zaEGbs-cE',
    'is_subscription': false,
    'is_attended': false,
  };

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'auth.user': jsonEncode(userJson)});
    await initDependencies();

    // لا اتصال حقيقي: طلب حقيقي يبقى معلّقاً بعد انتهاء الاختبار، أما المحوّل
    // المزيّف فيردّ ضمن وقت الاختبار.
    final adapter = FakeHttpAdapter()
      ..on('/profile/get', body: {'message': 'ok', 'data': userJson})
      ..on('/governorates/all', body: {'message': 'ok', 'data': {'damascus': 'دمشق'}})
      ..on('/branches/all', body: {'message': 'ok', 'data': []})
      ..on('/notifications/get', body: {'message': 'ok', 'data': []})
      ..on('/courses/paginate', body: {'message': 'ok', 'data': [courseJson]})
      ..on('/courses/details', body: {
        'message': 'ok',
        'data': {
          ...courseJson,
          'semesters': [
            {
              'id': 2,
              'name': 'الفصل الأول',
              'is_free': true,
              'price': 71,
              'lessions_count': 1,
              'is_subscription': false,
              'lessions': [lessonJson],
            },
          ],
        },
      })
      ..on('/subjects/all', body: {
        'message': 'ok',
        'data': [
          {'id': 1, 'name': 'ناردين الشطناوي', 'is_free': false, 'image': 'https://x/1.png', 'is_subscription': false},
        ],
      })
      ..on('/packages/all', body: {
        'message': 'ok',
        'data': [
          {'id': 1, 'name': 'سنة واحدة', 'price': 55000, 'duration': 365},
        ],
      })
      ..on('/payment-methods/all', body: {
        'message': 'ok',
        'data': [
          {'id': 1, 'name': 'باسل', 'phone': '0993571184', 'governorate': 'دمشق', 'method': 'الهرم', 'image': null},
        ],
      });
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
    sl
      ..unregister<ApiClient>()
      ..registerLazySingleton(() => ApiClient(readToken: () => null, dio: dio));
  });

  const paths = [
    '/notifications',
    '/achievements',
    '/subscription',
    '/checkout?package=1',
    '/gallery',
    '/gallery/gal_math',
    '/gallery/gal_math/photo/1',
    '/tests',
    '/profile',
    '/downloads',
    '/faq',
    '/privacy',
    '/usage-policy',
    '/my-courses',
    '/home',
    '/categories',
    '/categories/1',
    '/courses',
    '/courses/1',
    '/courses/1/video/3',
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
