import 'package:dio/dio.dart';
import 'package:educational_app/core/error/exceptions.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_adapter.dart';

const _newUserJson = {
  'id': 30,
  'f_name': null,
  'l_name': null,
  'email': null,
  'phone': '0930000000',
  'points': 0,
  'image': 'https://example.com/avatar.png',
  'subject_count': 0,
};

void main() {
  late FakeHttpAdapter adapter;
  late AuthRemoteDataSourceImpl remote;
  String? token;

  setUp(() {
    adapter = FakeHttpAdapter();
    token = null;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
    remote = AuthRemoteDataSourceImpl(ApiClient(readToken: () => token, dio: dio));
  });

  test('login يرسل الرقم إلى auth/login ويطلب JSON', () async {
    adapter.on('/auth/login', body: {'message': 'تم إرسال الرمز', 'data': []});

    await remote.login('0930000000');

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.uri.toString(), 'https://api.test/api/auth/login');
    expect(request.headers['Accept'], 'application/json');
    expect(formFields(request), {'phone': '0930000000'});
  });

  test('activate يرسل الرمز ومعرّف الجهاز ويعيد الجلسة', () async {
    adapter.on('/auth/active', body: {
      'message': 'تم تسجيل الدخول بنجاح',
      'data': {'token': '30|abc', 'user': _newUserJson},
    });

    final session = await remote.activate(phone: '0930000000', code: '1111', deviceId: 'dev-1');

    expect(session.token, '30|abc');
    expect(session.user.isProfileComplete, isFalse);
    expect(formFields(adapter.requests.single), {
      'phone': '0930000000',
      'verification_code': '1111',
      'device_id': 'dev-1',
    });
  });

  test('رمز خاطئ (400) يصل ServerException برسالة الخادم', () async {
    adapter.on('/auth/active', status: 400, body: {'message': 'الكود المدخل غير صحيح', 'data': []});

    await expectLater(
      remote.activate(phone: '0930000000', code: '0000', deviceId: 'dev-1'),
      throwsA(isA<ServerException>().having((e) => e.message, 'message', 'الكود المدخل غير صحيح')),
    );
  });

  test('422 يصل ValidationException بأول خطأ دون "(and N more errors)"', () async {
    adapter.on('/auth/login', status: 422, body: {
      'message': 'الحقل رقم الهاتف مطلوب. (and 1 more error)',
      'errors': {
        'phone': ['الحقل رقم الهاتف مطلوب.'],
        'device_id': ['الحقل device id مطلوب.'],
      },
    });

    await expectLater(
      remote.login(''),
      throwsA(isA<ValidationException>().having((e) => e.message, 'message', 'الحقل رقم الهاتف مطلوب.')),
    );
  });

  test('getProfile يرسل التوكن ويقرأ المستخدم', () async {
    token = '30|abc';
    adapter.on('/profile/get', body: {
      'message': 'معلومات المستخدم',
      'data': {..._newUserJson, 'f_name': 'Rashed', 'l_name': 'Eybo'},
    });

    final user = await remote.getProfile();

    expect(user.name, 'Rashed Eybo');
    expect(adapter.requests.single.headers['Authorization'], 'Bearer 30|abc');
  });

  test('401 يصل AuthException برسالة عربية', () async {
    adapter.on('/profile/get', status: 401, body: {'message': 'Unauthenticated.'});

    await expectLater(remote.getProfile(), throwsA(isA<AuthException>()));
  });

  test('انقطاع الاتصال يصل ServerException', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))
      ..httpClientAdapter = _OfflineAdapter();
    final offline = AuthRemoteDataSourceImpl(ApiClient(readToken: () => null, dio: dio));

    await expectLater(
      offline.login('0930000000'),
      throwsA(isA<ServerException>().having((e) => e.message, 'message', contains('اتصالك'))),
    );
  });
}

class _OfflineAdapter extends FakeHttpAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options, _, _) {
    throw DioException.connectionError(requestOptions: options, reason: 'offline');
  }
}