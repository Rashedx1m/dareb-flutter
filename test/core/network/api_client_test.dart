import 'package:dio/dio.dart';
import 'package:educational_app/core/error/exceptions.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_adapter.dart';

void main() {
  late FakeHttpAdapter adapter;
  late ApiClient client;
  String? token;
  var unauthorizedCalls = 0;

  setUp(() {
    adapter = FakeHttpAdapter();
    token = null;
    unauthorizedCalls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
    client = ApiClient(
      readToken: () => token,
      onUnauthorized: () => unauthorizedCalls++,
      dio: dio,
    );
  });

  int readId(dynamic data) => (data as Map<String, dynamic>)['id'] as int;

  group('parse', () {
    test('يقرأ data من داخل الغلاف', () async {
      adapter.on('/x', body: {'message': 'ok', 'data': {'id': 7}});

      expect(await client.get('/x', parse: readId), 7);
    });

    test('رد بشكل غير متوقع يصبح ServerException بدل خطأ برمجي', () async {
      // قائمة فارغة حيث يُتوقع كائن.
      adapter.on('/x', body: {'message': 'ok', 'data': []});

      await expectLater(
        client.get('/x', parse: readId),
        throwsA(
          isA<ServerException>().having((e) => e.message, 'message', 'رد غير متوقع من الخادم'),
        ),
      );
    });
  });

  group('401', () {
    test('على طلب يحمل توكن: يُبلغ بانتهاء الجلسة ويرمي AuthException', () async {
      token = '30|abc';
      adapter.on('/x', status: 401, body: {'message': 'Unauthenticated.'});

      await expectLater(client.get('/x'), throwsA(isA<AuthException>()));
      expect(unauthorizedCalls, 1);
    });

    test('على طلب بلا توكن: لا جلسة لتنتهي', () async {
      adapter.on('/x', status: 401, body: {'message': 'Unauthenticated.'});

      await expectLater(client.get('/x'), throwsA(isA<AuthException>()));
      expect(unauthorizedCalls, 0);
    });

    test('404 يصل برسالة عربية بدل رسالة Laravel الإنجليزية', () async {
      adapter.on('/x', status: 404, body: {'message': r'No query results for model [App\Models\Package] 1'});

      await expectLater(
        client.get('/x'),
        throwsA(isA<ServerException>().having((e) => e.message, 'message', 'المحتوى المطلوب غير موجود')),
      );
    });

    test('أخطاء الخادم الأخرى لا تُنهي الجلسة', () async {
      token = '30|abc';
      adapter.on('/x', status: 400, body: {'message': 'المستخدم ليس لديه فرع', 'data': []});

      await expectLater(client.get('/x'), throwsA(isA<ServerException>()));
      expect(unauthorizedCalls, 0);
    });
  });
}
