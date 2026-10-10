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

/// عنصر من رد `subjects/all` كما أعاده خادم التدريب في 2026-10-10.
const _subjectJson = {
  'id': 2,
  'name': 'سارين الطراونة',
  'is_free': true,
  'image': 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
  'is_subscription': false,
};

void main() {
  test('SubjectModel.fromJson على الرد الحقيقي', () {
    // Equatable يقارن النوع أيضاً، فالمتوقَّع Model لا Entity.
    expect(
      SubjectModel.fromJson(_subjectJson),
      const SubjectModel(
        id: '2',
        name: 'سارين الطراونة',
        imageUrl: 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
        isFree: true,
        isSubscribed: false,
      ),
    );
  });

  group('المصدر والمستودع', () {
    late FakeHttpAdapter adapter;
    late CoursesRepositoryImpl repository;

    setUp(() {
      adapter = FakeHttpAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
      repository = CoursesRepositoryImpl(
        CoursesRemoteDataSourceImpl(ApiClient(readToken: () => '30|abc', dio: dio)),
      );
    });

    test('المواد من subjects/all بتوكن الجلسة وبلا معاملات', () async {
      adapter.on('/subjects/all', body: {'message': 'المواد الموجودة', 'data': [_subjectJson]});

      final subjects = (await repository.getSubjects()).getOrElse(() => []);

      expect(subjects.single.name, 'سارين الطراونة');
      expect(adapter.requests.single.queryParameters, isEmpty);
      expect(adapter.requests.single.headers['Authorization'], 'Bearer 30|abc');
    });

    test('مادة بلا is_subscription تصير «رد غير متوقع»', () async {
      adapter.on('/subjects/all', body: {
        'message': '',
        'data': [
          {'id': 1, 'name': 'x', 'is_free': false, 'image': 'y'},
        ],
      });

      expect(
        await repository.getSubjects(),
        const Left<Failure, List<Subject>>(ServerFailure('رد غير متوقع من الخادم')),
      );
    });

    test('خطأ الخادم يصل برسالته', () async {
      adapter.on('/subjects/all', status: 500, body: {'message': 'Server Error'});

      expect(
        await repository.getSubjects(),
        const Left<Failure, List<Subject>>(ServerFailure('Server Error')),
      );
    });
  });
}
