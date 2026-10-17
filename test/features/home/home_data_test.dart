import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:educational_app/features/home/data/models/home_feed_model.dart';
import 'package:educational_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:educational_app/features/home/domain/entities/home_feed.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_adapter.dart';

/// رد `home-page/index` كما أعاده خادم التدريب في 2026-10-16.
const _json = {
  'sliders': [
    {
      'id': 1,
      'link': 'https://www.google.com/',
      'image': 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
    },
  ],
  'subjects': [
    {
      'id': 2,
      'name': 'سارين الطراونة',
      'is_free': true,
      'image': 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
      'is_subscription': false,
    },
  ],
  'news': [
    {
      'id': 9,
      'link': 'https://www.google.com/',
      'image': 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
    },
  ],
  'courses': [
    {
      'id': 1,
      'name': 'ناردين الشطناوي',
      'is_free': false,
      'course_name': 'الدكتور هناء القطيشات',
      'text': 'Similique aut reiciendis sint inventore voluptas qui quod.',
      'professor': 'أكرم أبو الرب',
      'price': 36,
      'image': 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
      'semesters_count': 3,
      'semester_rate': 0,
      'lessions_count': 6,
      'lession_rate': 17,
      'subscriptions_count': 3,
      'is_subscription': false,
    },
  ],
  'notification_unread': 2,
  'completion_rate': 0,
  'subject_count': 1,
};

void main() {
  test('fromJson على الرد الحقيقي', () {
    final feed = HomeFeedModel.fromJson(_json);

    expect(feed.sliders.single.id, '1');
    expect(feed.sliders.single.imageUrl, 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png');
    expect(feed.sliders.single.link, 'https://www.google.com/');
    expect(feed.subjects.single.name, 'سارين الطراونة');
    expect(feed.news.single.id, '9');
    expect(feed.courses.single.title, 'الدكتور هناء القطيشات');
    expect(feed.completionRate, 0);
    expect(feed.subjectCount, 1);
  });

  test('سلايدر فارغ يبقى قائمة فارغة', () {
    expect(HomeFeedModel.fromJson({..._json, 'sliders': <Object>[]}).sliders, isEmpty);
  });

  test('completion_rate المئوية 40 تصبح 0.4', () {
    expect(HomeFeedModel.fromJson({..._json, 'completion_rate': 40}).completionRate, 0.4);
  });

  group('المصدر والمستودع', () {
    late FakeHttpAdapter adapter;
    late HomeRepositoryImpl repository;

    setUp(() {
      adapter = FakeHttpAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
      repository = HomeRepositoryImpl(
        HomeRemoteDataSourceImpl(ApiClient(readToken: () => '30|abc', dio: dio)),
      );
    });

    test('التجميع من home-page/index بتوكن الجلسة', () async {
      adapter.on('/home-page/index', body: {'message': 'تمت العملية بنجاح', 'data': _json});

      final feed = (await repository.getHome()).getOrElse(() => throw StateError('expected feed'));

      expect(feed.news, hasLength(1));
      expect(feed.courses.single.instructor, 'أكرم أبو الرب');
      expect(adapter.requests.single.headers['Authorization'], 'Bearer 30|abc');
    });

    test('مادة بلا name تصير «رد غير متوقع» بدل أن تتجمد الشاشة', () async {
      adapter.on('/home-page/index', body: {
        'message': '',
        'data': {
          ..._json,
          'subjects': [
            {'id': 1, 'is_free': true, 'image': 'x', 'is_subscription': false},
          ],
        },
      });

      expect(
        await repository.getHome(),
        const Left<Failure, HomeFeed>(ServerFailure('رد غير متوقع من الخادم')),
      );
    });
  });
}
