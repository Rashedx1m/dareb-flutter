import 'package:dio/dio.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/auth/data/datasources/registration_options_remote_data_source.dart';
import 'package:educational_app/features/auth/data/models/lookup_option_model.dart';
import 'package:educational_app/features/auth/domain/entities/lookup_option.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_adapter.dart';

void main() {
  late FakeHttpAdapter adapter;
  late RegistrationOptionsRemoteDataSourceImpl remote;

  setUp(() {
    adapter = FakeHttpAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
    remote = RegistrationOptionsRemoteDataSourceImpl(ApiClient(readToken: () => '30|abc', dio: dio));
  });

  // Equatable يقارن النوع أيضاً، فالمتوقَّع Model لا Entity.
  test('المحافظات تُقرأ من الخريطة بمفتاحها واسمها', () async {
    adapter.on('/governorates/all', body: {
      'message': 'الجهات الدراسية الموجودة',
      'data': {'damascus': 'دمشق', 'aleppo': 'حلب'},
    });

    expect(await remote.getGovernorates(), const [
      LookupOptionModel(id: 'damascus', name: 'دمشق'),
      LookupOptionModel(id: 'aleppo', name: 'حلب'),
    ]);
  });

  test('المدارس ترسل المرشّحات وتقرأ المعرّف والاسم', () async {
    adapter.on('/schools/all', body: {
      'message': 'الجهات الدراسية الموجودة',
      'data': [
        {'id': 7, 'name': 'مدرسة يامن', 'governorate': 'damascus'},
      ],
    });

    final schools = await remote.getSchools(kind: SchoolKind.school, governorateId: 'damascus');

    expect(schools, const [LookupOptionModel(id: '7', name: 'مدرسة يامن')]);
    expect(adapter.requests.single.queryParameters, {'type': 1, 'governorate': 'damascus'});
  });

  test('المدارس بلا مرشّحات لا ترسل معاملات', () async {
    adapter.on('/schools/all', body: {'message': '', 'data': []});

    expect(await remote.getSchools(), isEmpty);
    expect(adapter.requests.single.queryParameters, isEmpty);
  });

  test('نوع المعهد يُرسل كـ type=2', () async {
    adapter.on('/schools/all', body: {'message': '', 'data': []});

    await remote.getSchools(kind: SchoolKind.institute);

    expect(adapter.requests.single.queryParameters, {'type': 2});
  });

  test('الفروع تُقرأ مع توكن الجلسة', () async {
    adapter.on('/branches/all', body: {
      'message': 'الفروع الموجودة',
      'data': [
        {'id': 1, 'name': 'علمي'},
        {'id': 2, 'name': 'أدبي'},
      ],
    });

    expect(await remote.getBranches(), const [
      LookupOptionModel(id: '1', name: 'علمي'),
      LookupOptionModel(id: '2', name: 'أدبي'),
    ]);
    expect(adapter.requests.single.headers['Authorization'], 'Bearer 30|abc');
  });
}
