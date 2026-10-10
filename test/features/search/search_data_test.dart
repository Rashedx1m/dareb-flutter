import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/courses/data/datasources/courses_remote_data_source.dart';
import 'package:educational_app/features/courses/data/models/subject_model.dart';
import 'package:educational_app/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_adapter.dart';

/// رد `home-page/search?text=ناردين` كما أعاده خادم التدريب في 2026-10-10.
const _searchJson = {
  'subjects': [
    {
      'id': 1,
      'name': 'ناردين الشطناوي',
      'is_free': false,
      'image': 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
      'is_subscription': false,
    },
  ],
  'exams': [],
  'dailyActivities': [],
};

void main() {
  late FakeHttpAdapter adapter;
  late CoursesRepositoryImpl repository;

  setUp(() {
    adapter = FakeHttpAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
    repository = CoursesRepositoryImpl(
      CoursesRemoteDataSourceImpl(ApiClient(readToken: () => '30|abc', dio: dio)),
    );
  });

  test('يقرأ subjects من home-page/search بالنص بعد قصّ المسافات', () async {
    adapter.on('/home-page/search', body: {'message': 'ok', 'data': _searchJson});

    final result = await repository.searchSubjects('  ناردين ');

    expect(
      result.getOrElse(() => []),
      const [
        SubjectModel(
          id: '1',
          name: 'ناردين الشطناوي',
          imageUrl: 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
          isFree: false,
          isSubscribed: false,
        ),
      ],
    );
    expect(adapter.requests.single.queryParameters, {'text': 'ناردين'});
  });

  test('النص الفارغ لا يُرسل، لأن الخادم يعيد له كل المواد', () async {
    expect((await repository.searchSubjects('   ')).getOrElse(() => [_dummy]), isEmpty);
    expect(adapter.requests, isEmpty);
  });

  test('رد بلا subjects يصير «رد غير متوقع»', () async {
    adapter.on('/home-page/search', body: {'message': 'ok', 'data': {'exams': []}});

    expect(
      await repository.searchSubjects('x'),
      const Left<Failure, List<Subject>>(ServerFailure('رد غير متوقع من الخادم')),
    );
  });
}

const _dummy = Subject(id: '0', name: '', imageUrl: '', isFree: false, isSubscribed: false);
