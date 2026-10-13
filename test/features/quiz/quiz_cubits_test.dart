import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/quiz/domain/entities/quiz.dart';
import 'package:educational_app/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:educational_app/features/quiz/domain/usecases/attend_exam.dart';
import 'package:educational_app/features/quiz/domain/usecases/get_my_activities.dart';
import 'package:educational_app/features/quiz/domain/usecases/get_my_exams.dart';
import 'package:educational_app/features/quiz/domain/usecases/get_quiz.dart';
import 'package:educational_app/features/quiz/presentation/cubit/quiz_cubit.dart';
import 'package:educational_app/features/quiz/presentation/cubit/quiz_result_cubit.dart';
import 'package:educational_app/features/quiz/presentation/cubit/tests_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _exam = Quiz(id: '6', title: 'هذا اختبار رباضيات', questionsCount: 2);
const _activity = Quiz(id: '7', title: 'نشاط', questionsCount: 1, kind: QuizKind.activity);

const _details = QuizDetails(
  id: '6',
  title: 'هذا اختبار رباضيات',
  questionsCount: 2,
  correctAnswers: 1,
  failedAnswers: 1,
  questions: [
    QuizQuestion(
      id: '51',
      text: 'س1',
      answers: [
        QuizAnswer(id: '201', text: '100', isCorrect: false),
        QuizAnswer(id: '202', text: '110', isCorrect: true),
      ],
    ),
    QuizQuestion(
      id: '52',
      text: 'س2',
      answers: [
        QuizAnswer(id: '205', text: '3', isCorrect: true),
        QuizAnswer(id: '206', text: '333', isCorrect: false),
      ],
    ),
  ],
);

class _FakeRepository extends Fake implements QuizRepository {
  Either<Failure, List<Quiz>> exams = const Right([]);
  Either<Failure, List<Quiz>> activities = const Right([]);
  Either<Failure, QuizDetails> details = const Left(ServerFailure('x'));
  Either<Failure, QuizScore> attend = const Right(QuizScore(questionsCount: 2, correctAnswers: 1, failedAnswers: 1));
  List<String>? attended;

  @override
  Future<Either<Failure, List<Quiz>>> getMyExams() async => exams;

  @override
  Future<Either<Failure, List<Quiz>>> getMyActivities() async => activities;

  @override
  Future<Either<Failure, QuizDetails>> getQuiz(String id) async => details;

  @override
  Future<Either<Failure, QuizScore>> attendExam(List<String> answerIds) async {
    attended = answerIds;
    return attend;
  }
}

void main() {
  late _FakeRepository repository;

  setUp(() => repository = _FakeRepository());

  group('TestsCubit', () {
    test('يحمّل الاختبارات والنشاطات', () async {
      repository
        ..exams = const Right([_exam])
        ..activities = const Right([_activity]);
      final cubit = TestsCubit(getMyExams: GetMyExams(repository), getMyActivities: GetMyActivities(repository));
      await cubit.load();
      expect(
        cubit.state,
        const TestsState(status: TestsStatus.success, exams: [_exam], activities: [_activity]),
      );
    });

    test('فشل النشاطات يصل برسالته', () async {
      repository
        ..exams = const Right([_exam])
        ..activities = const Left(ServerFailure('تعذّر الاتصال'));
      final cubit = TestsCubit(getMyExams: GetMyExams(repository), getMyActivities: GetMyActivities(repository));
      await cubit.load();
      expect(cubit.state, const TestsState(status: TestsStatus.failure, error: 'تعذّر الاتصال'));
    });
  });

  group('QuizCubit', () {
    QuizCubit cubit() => QuizCubit(getQuiz: GetQuiz(repository), attendExam: AttendExam(repository));

    test('الفشل يصل برسالته', () async {
      repository.details = const Left(ServerFailure('الحقل id لاغٍ'));
      final c = cubit();
      await c.load('999');
      expect(c.state, const QuizState(status: QuizStatus.failure, error: 'الحقل id لاغٍ'));
    });

    test('لا يُرسل الحضور حتى تُجاب كل الأسئلة، ثم مرة واحدة', () async {
      repository.details = const Right(_details);
      final c = cubit();
      await c.load('6');
      expect(c.allAnswered, isFalse);
      await c.submit();
      expect(repository.attended, isNull);

      c.select('51', '202');
      expect(c.allAnswered, isFalse);
      c.select('52', '206');
      expect(c.allAnswered, isTrue);

      await c.submit();
      expect(repository.attended, ['202', '206']);
      expect(c.state.attend, AttendStatus.done);
    });

    test('فشل الحضور لا يمسح الأسئلة', () async {
      repository
        ..details = const Right(_details)
        ..attend = const Left(ServerFailure('Server Error'));
      final c = cubit();
      await c.load('6');
      c
        ..select('51', '202')
        ..select('52', '206');
      await c.submit();
      expect(c.state.quiz, _details);
      expect(c.state.attend, AttendStatus.failure);
      expect(c.state.attendError, 'Server Error');
    });
  });

  group('QuizResultCubit', () {
    test('يجلب النتيجة بمعرّف الاختبار', () async {
      repository.details = const Right(_details);
      final cubit = QuizResultCubit(GetQuiz(repository));
      await cubit.load('6');
      expect(cubit.state, const QuizResultState(status: QuizResultStatus.success, quiz: _details));
    });
  });
}
