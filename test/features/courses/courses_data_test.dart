import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/courses/data/datasources/courses_remote_data_source.dart';
import 'package:educational_app/features/courses/data/models/course_details_model.dart';
import 'package:educational_app/features/courses/data/models/course_model.dart';
import 'package:educational_app/features/courses/data/models/subject_details_model.dart';
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
/// النسبتان من `courses/details` بعد حضور درس من دروسها الستة.
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
  'semester_rate': 0,
  'lessions_count': 6,
  'lession_rate': 17,
  'subscriptions_count': 3,
  'is_subscription': false,
};

/// مقتطف من `courses/details?subject_id=1`: فصل بفيديو مقفل واختبار `exam: null`،
/// وفصل بفيديو مجاني محضور وملف. حقول النقاط ونافذة التعريف من رد المادة 15 في 2026-10-11.
const _detailsJson = {
  ..._courseJson,
  'subject_rate': 17,
  'points_count': 600,
  'point_rate': 0,
  'story_image': 'https://training.tamkeen-dev.com/dareb/public/storage/10/story.png',
  'story_text': 'History is Amazing',
  'is_first_story': false,
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

/// مقتطف من `subjects/details?id=13` في 2026-10-11: بطاقة المادة واختبار واحد
/// (أسئلته محذوفة هنا)، والنشاطات فارغة.
const _subjectDetailsJson = {
  'content': {..._courseJson, 'points_count': 300, 'point_rate': 0, 'is_first_story': false},
  'exams': [
    {
      'id': 11,
      'expiry_date': '2026-10-26',
      'type': 'الأختبارات',
      'is_free': true,
      'exam': {
        'id': 6,
        'title': 'هذا اختبار رباضيات',
        'professor': '',
        'type': {'id': 2, 'name': 'Exam'},
        'questions': [],
        'questions_count': 2,
        'subscriptions_count': 0,
        'is_subscription': false,
        'is_free': false,
      },
    },
  ],
  'dailyActivities': [],
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
  semesterRate: 0,
  lessonsCount: 6,
  lessonRate: 17,
  subscriptionsCount: 3,
  isFree: false,
  isSubscribed: false,
);

const _detailsCourse = CourseModel(
  id: '1',
  title: 'الدكتور هناء القطيشات',
  subjectName: 'ناردين الشطناوي',
  instructor: 'أكرم أبو الرب',
  description: 'Similique aut reiciendis sint inventore voluptas qui quod.',
  imageUrl: 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
  price: 36,
  semestersCount: 3,
  semesterRate: 0,
  lessonsCount: 6,
  lessonRate: 17,
  subscriptionsCount: 3,
  isFree: false,
  isSubscribed: false,
  subjectRate: 17,
  pointsCount: 600,
);

const _subjectCourse = CourseModel(
  id: '1',
  title: 'الدكتور هناء القطيشات',
  subjectName: 'ناردين الشطناوي',
  instructor: 'أكرم أبو الرب',
  description: 'Similique aut reiciendis sint inventore voluptas qui quod.',
  imageUrl: 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
  price: 36,
  semestersCount: 3,
  semesterRate: 0,
  lessonsCount: 6,
  lessonRate: 17,
  subscriptionsCount: 3,
  isFree: false,
  isSubscribed: false,
  pointsCount: 300,
);

void main() {
  test('CourseModel.fromJson على بطاقة courses/paginate', () {
    expect(CourseModel.fromJson(_courseJson), _course);
  });

  test('subject_rate وpoints_count وpoint_rate تُقرأ إن وُجدت وإلا 0', () {
    expect(CourseModel.fromJson(_courseJson).pointsCount, 0);
    final withRates = CourseModel.fromJson({
      ..._courseJson,
      'subject_rate': 17,
      'points_count': 600,
      'point_rate': 40,
    });
    expect(withRates.subjectRate, 17);
    expect(withRates.pointsCount, 600);
    expect(withRates.pointRate, 40);
  });

  test('نافذة التعريف تظهر إن طلبها الخادم وفيها نص أو صورة', () {
    final first = CourseDetailsModel.fromJson({..._detailsJson, 'is_first_story': true});
    expect(first.hasStory, isTrue);

    final empty = CourseDetailsModel.fromJson({
      ..._detailsJson,
      'is_first_story': true,
      'story_image': null,
      'story_text': '  ',
    });
    expect(empty.hasStory, isFalse);
  });

  test('SubjectDetailsModel.fromJson: الدورة من content، والاختبار من exam', () {
    final details = SubjectDetailsModel.fromJson(_subjectDetailsJson);

    expect(details.course, _subjectCourse);
    expect(details.pointsCount, 300);
    expect(details.exams, const [
      SubjectExamModel(
        id: '6',
        title: 'هذا اختبار رباضيات',
        instructor: '',
        questionsCount: 2,
        isFree: true,
        isSubscribed: false,
      ),
    ]);
    expect(details.activities, isEmpty);
  });

  test('«مجاني» من الربط لا من الاختبار، فنشاط مجاني في مادة مدفوعة يُفتح', () {
    // رد subjects/details?id=1 في 2026-10-18: المادة مدفوعة، وربط النشاط 12 مجاني
    // في اللوحة، و exam.is_free الداخلي false كما في كل الاختبارات.
    final details = SubjectDetailsModel.fromJson({
      'content': {..._courseJson, 'points_count': 0, 'point_rate': 0, 'is_first_story': false},
      'exams': [],
      'dailyActivities': [
        {
          'id': 12,
          'expiry_date': '2027-10-16',
          'type': 'الأختبارات العامة',
          'is_free': true,
          'exam': {
            'id': 7,
            'title': 'اختبار رياضيات',
            'professor': '',
            'type': {'id': 2, 'name': 'Exam'},
            'questions': [],
            'questions_count': 2,
            'subscriptions_count': 0,
            'is_subscription': false,
            'is_free': false,
          },
        },
      ],
    });

    expect(details.course.isFree, isFalse);
    expect(details.activities.single.isFree, isTrue);
    expect(details.activities.single.isSubscribed, isFalse);
  });

  test('الاشتراك بالمادة يفتح اختباراتها المدفوعة، لأن الاختبار لا يُشترك به وحده', () {
    final paid = {
      ..._subjectDetailsJson,
      'content': {..._subjectDetailsJson['content']! as Map<String, dynamic>, 'is_subscription': true},
      'exams': [
        {...(_subjectDetailsJson['exams']! as List).single as Map<String, dynamic>, 'is_free': false},
      ],
    };

    final exam = SubjectDetailsModel.fromJson(paid).exams.single;

    expect(exam.isFree, isFalse);
    expect(exam.isSubscribed, isTrue);
  });

  test('بطاقة بلا lession_rate تُرفض', () {
    expect(() => CourseModel.fromJson({..._courseJson}..remove('lession_rate')), throwsA(isA<TypeError>()));
  });

  test('CourseDetailsModel.fromJson يحفظ الفصول والدروس بترتيب الخادم', () {
    final details = CourseDetailsModel.fromJson(_detailsJson);

    expect(details.course, _detailsCourse);
    expect(details.pointsCount, 600);
    expect(details.storyImageUrl, 'https://training.tamkeen-dev.com/dareb/public/storage/10/story.png');
    expect(details.storyText, 'History is Amazing');
    expect(details.isFirstStory, isFalse);
    expect(details.hasStory, isFalse);
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

    test('صفحة المادة من subjects/details بمعرّفها', () async {
      adapter.on('/subjects/details', body: {'message': 'تمت العملية بنجاح', 'data': _subjectDetailsJson});

      final result = await repository.getSubjectDetails('13');

      expect(result.map((d) => d.exams.length), const Right<Failure, int>(1));
      expect(adapter.requests.single.queryParameters, {'id': '13'});
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

    test('درس بنوع غير معروف يُتخطى وحده، وتبقى بقية دروس الفصل', () async {
      adapter.on('/courses/details', body: {
        'message': 'ok',
        'data': {
          ..._courseJson,
          'points_count': 0,
          'is_first_story': false,
          'semesters': [
            {
              'id': 1,
              'name': 'س',
              'is_free': true,
              'price': 0,
              'lessions_count': 2,
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
                {
                  'id': 10,
                  'name': 'فيديو',
                  'is_free': true,
                  'order': 1,
                  'type': {'id': 2, 'name': 'Video'},
                  'time': '00:10:00',
                  'url': 'https://www.youtube.com/watch?v=q0zaEGbs-cE',
                  'is_subscription': false,
                  'is_attended': false,
                },
              ],
            },
          ],
        },
      });

      final details = (await repository.getCourseDetails('1')).getOrElse(() => throw StateError('failed'));

      expect(details.semesters.single.lessons.map((l) => l.id), ['10']);
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
