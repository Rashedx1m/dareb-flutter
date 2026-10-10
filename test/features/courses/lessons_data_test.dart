import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/courses/data/datasources/courses_remote_data_source.dart';
import 'package:educational_app/features/courses/data/models/lesson_details_model.dart';
import 'package:educational_app/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:educational_app/features/courses/domain/entities/lesson.dart';
import 'package:educational_app/features/courses/domain/entities/lesson_details.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_adapter.dart';

/// رد `lessions/details?id=4` كما أعاده خادم التدريب في 2026-10-10.
const _fileLessonJson = {
  'id': 4,
  'name': 'نصر السحاقات',
  'is_free': false,
  'order': 7,
  'type': {'id': 1, 'name': 'File'},
  'time': '20:24:16',
  'file': 'https://training.tamkeen-dev.com/dareb/public/assets/pdf.pdf',
  'semester': {
    'id': 2,
    'name': 'السيدة بتول الترابين',
    'is_free': true,
    'price': 71,
    'lessions': [
      {
        'id': 3,
        'name': 'رسلان الدين عباد',
        'is_free': true,
        'order': 6,
        'type': {'id': 2, 'name': 'Video'},
        'time': '11:50:51',
        'url': 'https://www.youtube.com/watch?v=q0zaEGbs-cE',
        'drive_link_360': null,
        'drive_link_720': null,
        'is_subscription': false,
        'is_attended': false,
      },
      {
        'id': 4,
        'name': 'نصر السحاقات',
        'is_free': false,
        'order': 7,
        'type': {'id': 1, 'name': 'File'},
        'time': '20:24:16',
        'file': 'https://training.tamkeen-dev.com/dareb/public/assets/pdf.pdf',
        'is_subscription': false,
        'is_attended': false,
      },
    ],
    'lessions_count': 2,
    'lession_rate': 0,
    'is_subscription': false,
    'subscriptions_count': 0,
  },
  'comments': [],
  'is_subscription': false,
  'is_attended': false,
};

void main() {
  test('LessonDetailsModel.fromJson يقرأ الدرس من المستوى الأعلى وفصله من semester', () {
    final details = LessonDetailsModel.fromJson(_fileLessonJson);

    expect(details.lesson.id, '4');
    expect(details.lesson.type, LessonType.file);
    expect(details.lesson.fileUrl, 'https://training.tamkeen-dev.com/dareb/public/assets/pdf.pdf');
    expect(details.lesson.isLocked, isTrue);
    expect(details.semester.name, 'السيدة بتول الترابين');
    expect(details.semester.lessons.map((l) => l.id), ['3', '4']);
  });

  test('الاختبار الشقيق بلا مفتاح exam يُقرأ', () {
    final json = {
      ..._fileLessonJson,
      'semester': {
        ...(_fileLessonJson['semester']! as Map<String, dynamic>),
        'lessions': [
          {
            'id': 1,
            'name': 'مفدي العلامي',
            'is_free': true,
            'order': 6,
            'type': {'id': 3, 'name': 'Exam'},
            'is_subscription': false,
            'is_attended': false,
          },
        ],
      },
    };

    expect(LessonDetailsModel.fromJson(json).semester.lessons.single.type, LessonType.exam);
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

    test('الدرس من lessions/details بمعرّفه', () async {
      adapter.on('/lessions/details', body: {'message': 'ok', 'data': _fileLessonJson});

      final result = await repository.getLesson('4');

      expect(result.map((d) => d.lesson.title), const Right<Failure, String>('نصر السحاقات'));
      expect(adapter.requests.single.queryParameters, {'id': '4'});
    });

    test('درس غير موجود (404 برسالة إنجليزية) يصل برسالة عربية', () async {
      adapter.on(
        '/lessions/details',
        status: 404,
        body: {'message': r'No query results for model [App\Models\Lession] 999999'},
      );

      expect(
        await repository.getLesson('999999'),
        const Left<Failure, LessonDetails>(ServerFailure('المحتوى المطلوب غير موجود')),
      );
    });

    test('تسجيل الحضور يرسل lession_id كـ form-data ويتجاهل سجل الحضور', () async {
      adapter.on('/lessions/attend-lession', status: 201, body: {
        'message': 'تمت العملية بنجاح',
        'data': {'lession_id': '3', 'user_id': 30, 'updated_at': '2026-10-10 14:14:59', 'created_at': '2026-10-10 14:14:59', 'id': 5},
      });

      expect((await repository.attendLesson('3')).isRight(), isTrue);
      expect(adapter.requests.single.method, 'POST');
      expect(formFields(adapter.requests.single), {'lession_id': '3'});
    });

    test('فشل تسجيل الحضور يصل برسالته', () async {
      adapter.on('/lessions/attend-lession', status: 500, body: {'message': 'Server Error'});

      expect(
        await repository.attendLesson('3'),
        const Left<Failure, void>(ServerFailure('Server Error')),
      );
    });
  });
}
