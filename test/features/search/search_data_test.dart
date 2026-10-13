import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/courses/data/datasources/courses_remote_data_source.dart';
import 'package:educational_app/features/courses/data/models/subject_model.dart';
import 'package:educational_app/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:educational_app/features/courses/domain/entities/search_results.dart';
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

    final result = await repository.search('  ناردين ');

    expect(
      result.getOrElse(() => SearchResults.empty).subjects,
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
    expect(await repository.search('   '), const Right<Failure, SearchResults>(SearchResults.empty));
    expect(adapter.requests, isEmpty);
  });

  test('الاختبارات والنشاطات تُقرأ بغلاف exam أو بدونه', () async {
    const exam = {
      'id': 6,
      'title': 'هذا اختبار رباضيات',
      'professor': '',
      'questions_count': 2,
      'is_subscription': false,
      'is_free': false,
    };
    adapter.on('/home-page/search', body: {
      'message': 'ok',
      'data': {
        'subjects': [],
        'exams': [
          {'id': 11, 'is_free': true, 'exam': exam},
        ],
        'dailyActivities': [exam],
      },
    });

    final results = (await repository.search('هذا')).getOrElse(() => SearchResults.empty);

    expect(results.exams.single.title, 'هذا اختبار رباضيات');
    expect(results.exams.single.id, '6');
    expect(results.activities.single.questionsCount, 2);
  });

  test('اسم مادة غير نصي يصير «رد غير متوقع»', () async {
    adapter.on('/home-page/search', body: {
      'message': 'ok',
      'data': {
        'subjects': [
          {'id': 1, 'name': null, 'image': 'x', 'is_free': true, 'is_subscription': false},
        ],
      },
    });

    expect(
      await repository.search('x'),
      const Left<Failure, SearchResults>(ServerFailure('رد غير متوقع من الخادم')),
    );
  });
}
