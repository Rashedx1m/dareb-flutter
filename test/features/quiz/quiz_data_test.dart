import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/quiz/data/datasources/quiz_remote_data_source.dart';
import 'package:educational_app/features/quiz/data/models/quiz_model.dart';
import 'package:educational_app/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:educational_app/features/quiz/domain/entities/quiz.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_adapter.dart';

/// رد `exams/result?id=6` كما أعاده خادم التدريب في 2026-10-13 قبل الحضور.
const _exam6Json = {
  'id': 6,
  'title': 'هذا اختبار رباضيات',
  'type': {'id': 2, 'name': 'Exam'},
  'questions': [
    {
      'id': 51,
      'title': '<p>ان ناتج العملية التالية هو :</p><p><br></p><p>77+33</p>',
      'answers': [
        {'id': 201, 'title': '100', 'correct': false},
        {'id': 202, 'title': '110', 'correct': true},
        {'id': 203, 'title': '111', 'correct': false},
        {'id': 204, 'title': 'لا شيء مما سبق', 'correct': false},
      ],
    },
    {
      'id': 52,
      'title': '<p>ان ناتج العملية التالية هو :</p><p><br></p><p>666÷222</p>',
      'answers': [
        {'id': 205, 'title': '3', 'correct': true},
        {'id': 206, 'title': '333', 'correct': false},
        {'id': 207, 'title': 'شو بيعرفني؟', 'correct': false},
        {'id': 208, 'title': 'لا شيء مما سبق', 'correct': false},
      ],
    },
  ],
  'questions_count': 2,
  'correct_answers': 0,
  'failed_answers': 0,
};

const _exam6 = QuizDetailsModel(
  id: '6',
  title: 'هذا اختبار رباضيات',
  questionsCount: 2,
  correctAnswers: 0,
  failedAnswers: 0,
  questions: [
    QuizQuestionModel(
      id: '51',
      text: 'ان ناتج العملية التالية هو :\n\n77+33',
      answers: [
        QuizAnswerModel(id: '201', text: '100', isCorrect: false),
        QuizAnswerModel(id: '202', text: '110', isCorrect: true),
        QuizAnswerModel(id: '203', text: '111', isCorrect: false),
        QuizAnswerModel(id: '204', text: 'لا شيء مما سبق', isCorrect: false),
      ],
    ),
    QuizQuestionModel(
      id: '52',
      text: 'ان ناتج العملية التالية هو :\n\n666÷222',
      answers: [
        QuizAnswerModel(id: '205', text: '3', isCorrect: true),
        QuizAnswerModel(id: '206', text: '333', isCorrect: false),
        QuizAnswerModel(id: '207', text: 'شو بيعرفني؟', isCorrect: false),
        QuizAnswerModel(id: '208', text: 'لا شيء مما سبق', isCorrect: false),
      ],
    ),
  ],
);

void main() {
  test('QuizDetailsModel.fromJson على الرد الحقيقي الكامل', () {
    expect(QuizDetailsModel.fromJson(_exam6Json), _exam6);
  });

  test('current_answer بعد الحضور يُقرأ كاختيار المستخدم', () {
    final json = {
      'id': 6,
      'title': 'هذا اختبار رباضيات',
      'questions_count': 2,
      'correct_answers': 1,
      'failed_answers': 1,
      'questions': [
        {
          'id': 51,
          'title': 'س',
          'answers': [
            {'id': 201, 'title': '100', 'correct': false, 'current_answer': 0},
            {'id': 202, 'title': '110', 'correct': true, 'current_answer': 1},
          ],
        },
      ],
    };
    final details = QuizDetailsModel.fromJson(json);
    expect(details.correctAnswers, 1);
    expect(details.questions.single.answers.last.isSelected, isTrue);
    expect(details.questions.single.answers.first.isSelected, isFalse);
  });

  test('بطاقة القائمة تُقرأ بغلاف exam أو بدونه', () {
    const wrapped = {
      'id': 11,
      'exam': {'id': 6, 'title': 'هذا اختبار رباضيات', 'professor': 'Bayan', 'questions_count': 2},
    };
    expect(
      QuizModel.fromJson(wrapped, kind: QuizKind.test),
      const QuizModel(
        id: '6',
        title: 'هذا اختبار رباضيات',
        instructor: 'Bayan',
        questionsCount: 2,
      ),
    );
    expect(
      QuizModel.fromJson({'id': 6, 'title': 'س'}, kind: QuizKind.activity),
      const QuizModel(id: '6', title: 'س', questionsCount: 0, kind: QuizKind.activity),
    );
  });

  group('المصدر والمستودع', () {
    late FakeHttpAdapter adapter;
    late QuizRepositoryImpl repository;

    setUp(() {
      adapter = FakeHttpAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
      repository = QuizRepositoryImpl(
        QuizRemoteDataSourceImpl(ApiClient(readToken: () => '30|abc', dio: dio)),
      );
    });

    test('اختباراتي من exams/my بتوكن وبلا معاملات', () async {
      adapter.on('/exams/my', body: {'message': 'ok', 'data': <Object>[]});

      expect((await repository.getMyExams()).getOrElse(() => [const Quiz(id: 'x', title: 'x', questionsCount: 0)]), isEmpty);
      expect(adapter.requests.single.path, '/exams/my');
      expect(adapter.requests.single.queryParameters, isEmpty);
      expect(adapter.requests.single.headers['Authorization'], 'Bearer 30|abc');
    });

    test('النشاطات من daily-activities/my', () async {
      adapter.on('/daily-activities/my', body: {'message': 'ok', 'data': <Object>[]});

      expect((await repository.getMyActivities()).getOrElse(() => [const Quiz(id: 'x', title: 'x', questionsCount: 0)]), isEmpty);
      expect(adapter.requests.single.path, '/daily-activities/my');
    });

    test('التفاصيل من exams/result بمعرّف الاختبار', () async {
      adapter.on('/exams/result', body: {'message': 'ok', 'data': _exam6Json});

      final result = await repository.getQuiz('6');

      expect(result, const Right<Failure, QuizDetails>(_exam6));
      expect(adapter.requests.single.queryParameters, {'id': '6'});
    });

    test('الحضور يرسل answers_id[] كـ form-data', () async {
      adapter.on('/exams/attend-exam', status: 201, body: {
        'message': 'تمت العملية بنجاح',
        'data': {'questions_count': 2, 'correct_answers': 1, 'failed_answers': 1},
      });

      final result = await repository.attendExam(['202', '206']);
      final form = adapter.requests.single.data as FormData;
      expect(
        form.fields.where((e) => e.key == 'answers_id[]').map((e) => e.value).toList(),
        ['202', '206'],
      );
      expect(
        result,
        const Right<Failure, QuizScore>(
          QuizScoreModel(questionsCount: 2, correctAnswers: 1, failedAnswers: 1),
        ),
      );
    });

    test('بلا إجابات لا يُرسل الطلب', () async {
      expect(
        await repository.attendExam(const []),
        const Left<Failure, QuizScore>(ValidationFailure('أجب عن كل الأسئلة أولاً')),
      );
      expect(adapter.requests, isEmpty);
    });

    test('اختبار بلا id يرفضه الخادم بـ 422', () async {
      adapter.on('/exams/result', status: 422, body: {
        'message': 'الحقل id مطلوب.',
        'errors': {
          'id': ['الحقل id مطلوب.'],
        },
      });

      expect(
        await repository.getQuiz('6'),
        const Left<Failure, QuizDetails>(ValidationFailure('الحقل id مطلوب.')),
      );
    });
  });
}
