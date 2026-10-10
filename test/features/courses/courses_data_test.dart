import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/courses/data/datasources/courses_remote_data_source.dart';
import 'package:educational_app/features/courses/data/models/course_details_model.dart';
import 'package:educational_app/features/courses/data/models/course_model.dart';
import 'package:educational_app/features/courses/data/models/subject_model.dart';
import 'package:educational_app/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:educational_app/features/courses/domain/entities/course_details.dart';
import 'package:educational_app/features/courses/domain/entities/lesson.dart';
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

/// بطاقة المادة 1 من `courses/paginate`، ومفاتيحها نفسها في رأس `courses/details`.
const _courseJson = {
  'id': 1,
  'name': 'ناردين الشطناوي',
  'is_free': false,
  'course_name': 'الدكتور هناء القطيشات',
  'text': 'Similique aut reiciendis sint inventore voluptas qui quod.',
  'professor': 'أكرم أبو الرب',
  'price': 36,
  'image': 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
  'semesters_count': 3,
  'lessions_count': 6,
  'subscriptions_count': 3,
  'is_subscription': false,
};

/// مقتطف من `courses/details?subject_id=1`: فصل بفيديو مقفل واختبار `exam: null`،
/// وفصل بفيديو مجاني محضور وملف.
const _detailsJson = {
  ..._courseJson,
  'semester_rate': 0,
  'subject_rate': 17,
  'semesters': [
    {
      'id': 1,
      'name': 'سعيد ابو سعده',
      'is_free': false,
      'price': 88,
      'lessions': [
        {
          'id': 2,
          'name': 'فريد السلطية',
          'is_free': false,
          'order': 0,
          'type': {'id': 2, 'name': 'Video'},
          'time': '21:15:25',
          'url': 'https://www.youtube.com/watch?v=q0zaEGbs-cE',
          'drive_link_360': null,
          'drive_link_720': null,
          'is_subscription': false,
          'is_attended': false,
        },
        {
          'id': 1,
          'name': 'مفدي العلامي',
          'is_free': true,
          'order': 6,
          'type': {'id': 3, 'name': 'Exam'},
          'exam': null,
          'is_subscription': false,
          'is_attended': false,
        },
      ],
      'lessions_count': 2,
      'lession_rate': 0,
      'is_subscription': false,
      'subscriptions_count': 0,
    },
    {
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
          'is_subscription': false,
          'is_attended': true,
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
      'lession_rate': 50,
      'is_subscription': false,
      'subscriptions_count': 0,
    },
  ],
};

const _course = CourseModel(
  id: '1',
  title: 'الدكتور هناء القطيشات',
  subjectName: 'ناردين الشطناوي',
  instructor: 'أكرم أبو الرب',
  description: 'Similique aut reiciendis sint inventore voluptas qui quod.',
  imageUrl: 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
  price: 36,
  semestersCount: 3,
  lessonsCount: 6,
  subscriptionsCount: 3,
  isFree: false,
  isSubscribed: false,
);

void main() {
  test('CourseModel.fromJson على بطاقة courses/paginate', () {
    expect(CourseModel.fromJson(_courseJson), _course);
  });

  test('CourseDetailsModel.fromJson يحفظ الفصول والدروس بترتيب الخادم', () {
    final details = CourseDetailsModel.fromJson(_detailsJson);

    expect(details.course, _course);
    expect(details.semesters.map((s) => s.id), ['1', '2']);
    expect(details.semesters.first.price, 88);
    expect(details.semesters.first.lessonsCount, 2);

    final [lockedVideo, exam] = details.semesters.first.lessons;
    expect(lockedVideo.type, LessonType.video);
    expect(lockedVideo.videoUrl, 'https://www.youtube.com/watch?v=q0zaEGbs-cE');
    expect(lockedVideo.duration, '21:15:25');
    expect(lockedVideo.isLocked, isTrue);
    expect(exam.type, LessonType.exam);
    expect(exam.duration, isNull);
    expect(exam.isLocked, isFalse);

    final [freeVideo, file] = details.semesters.last.lessons;
    expect(freeVideo.isAttended, isTrue);
    expect(freeVideo.isLocked, isFalse);
    expect(file.type, LessonType.file);
    expect(file.fileUrl, 'https://training.tamkeen-dev.com/dareb/public/assets/pdf.pdf');
    expect(file.videoUrl, isNull);
  });

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

    test('الدورات من courses/paginate بلا معاملات تقسيم', () async {
      adapter.on('/courses/paginate', body: {'message': 'ok', 'data': [_courseJson]});

      final courses = (await repository.getCourses()).getOrElse(() => []);

      expect(courses, [_course]);
      expect(adapter.requests.single.queryParameters, isEmpty);
    });

    test('التفاصيل من courses/details بمعرّف المادة', () async {
      adapter.on('/courses/details', body: {'message': 'ok', 'data': _detailsJson});

      final result = await repository.getCourseDetails('1');

      expect(result.map((d) => d.semesters.length), const Right<Failure, int>(2));
      expect(adapter.requests.single.path, '/courses/details');
      expect(adapter.requests.single.queryParameters, {'subject_id': '1'});
    });

    test('دوراتي من subscriptions/my: بطاقة subject لكل اشتراك، والمادة المكررة مرة واحدة', () async {
      final subscribed = {..._courseJson, 'is_subscription': true};
      adapter.on('/subscriptions/my', body: {
        'message': 'تمت العملية بنجاح',
        'data': {
          'subjects': [
            {'id': 39, 'price': 5000, 'subject': subscribed},
            {'id': 40, 'price': 0, 'subject': subscribed},
          ],
        },
      });

      final courses = (await repository.getMyCourses()).getOrElse(() => []);

      expect(courses.map((c) => (c.id, c.isSubscribed)), [('1', true)]);
      expect(adapter.requests.single.queryParameters, isEmpty);
    });

    test('بلا اشتراكات تعود قائمة فارغة', () async {
      adapter.on('/subscriptions/my', body: {
        'message': 'ok',
        'data': {'subjects': []},
      });

      expect((await repository.getMyCourses()).getOrElse(() => [_course]), isEmpty);
    });

    test('مادة غير موجودة يرفضها الخادم بـ 422 لا 404', () async {
      adapter.on('/courses/details', status: 422, body: {
        'message': 'الحقل المواد لاغٍ',
        'errors': {
          'subject_id': ['الحقل المواد لاغٍ'],
        },
      });

      expect(
        await repository.getCourseDetails('999'),
        const Left<Failure, CourseDetails>(ValidationFailure('الحقل المواد لاغٍ')),
      );
    });

    test('درس بنوع غير معروف يصير «رد غير متوقع»', () async {
      adapter.on('/courses/details', body: {
        'message': 'ok',
        'data': {
          ..._courseJson,
          'semesters': [
            {
              'id': 1,
              'name': 'س',
              'is_free': true,
              'price': 0,
              'lessions_count': 1,
              'is_subscription': false,
              'lessions': [
                {
                  'id': 9,
                  'name': 'د',
                  'is_free': true,
                  'order': 0,
                  'type': {'id': 7, 'name': 'Audio'},
                  'is_subscription': false,
                  'is_attended': false,
                },
              ],
            },
          ],
        },
      });

      expect(
        await repository.getCourseDetails('1'),
        const Left<Failure, CourseDetails>(ServerFailure('رد غير متوقع من الخادم')),
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
