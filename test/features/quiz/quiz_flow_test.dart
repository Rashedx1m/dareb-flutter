import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/widgets/error_view.dart';
import 'package:educational_app/features/quiz/domain/entities/quiz.dart';
import 'package:educational_app/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:educational_app/features/quiz/domain/usecases/attend_exam.dart';
import 'package:educational_app/features/quiz/domain/usecases/get_my_activities.dart';
import 'package:educational_app/features/quiz/domain/usecases/get_my_exams.dart';
import 'package:educational_app/features/quiz/domain/usecases/get_quiz.dart';
import 'package:educational_app/features/quiz/presentation/cubit/quiz_cubit.dart';
import 'package:educational_app/features/quiz/presentation/cubit/quiz_result_cubit.dart';
import 'package:educational_app/features/quiz/presentation/cubit/tests_cubit.dart';
import 'package:educational_app/features/quiz/presentation/pages/quiz_page.dart';
import 'package:educational_app/features/quiz/presentation/pages/quiz_result_page.dart';
import 'package:educational_app/features/quiz/presentation/pages/quiz_review_page.dart';
import 'package:educational_app/features/quiz/presentation/pages/tests_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _exam = Quiz(id: '6', title: 'هذا اختبار رباضيات', instructor: 'Bayan', questionsCount: 2);
const _activity = Quiz(id: '7', title: 'نشاط يومي', questionsCount: 1, kind: QuizKind.activity);

const _taking = QuizDetails(
  id: '6',
  title: 'هذا اختبار رباضيات',
  questionsCount: 2,
  correctAnswers: 0,
  failedAnswers: 0,
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

const _scored = QuizDetails(
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
        QuizAnswer(id: '202', text: '110', isCorrect: true, isSelected: true),
      ],
    ),
    QuizQuestion(
      id: '52',
      text: 'س2',
      answers: [
        QuizAnswer(id: '205', text: '3', isCorrect: true),
        QuizAnswer(id: '206', text: '333', isCorrect: false, isSelected: true),
      ],
    ),
  ],
);

class _FakeRepository extends Fake implements QuizRepository {
  Either<Failure, List<Quiz>> exams = const Right([]);
  Either<Failure, List<Quiz>> activities = const Right([]);
  final quizLoads = <Either<Failure, QuizDetails>>[];
  Either<Failure, QuizScore> attend = const Right(
    QuizScore(questionsCount: 2, correctAnswers: 1, failedAnswers: 1),
  );
  List<String>? attended;

  @override
  Future<Either<Failure, List<Quiz>>> getMyExams() async => exams;

  @override
  Future<Either<Failure, List<Quiz>>> getMyActivities() async => activities;

  @override
  Future<Either<Failure, QuizDetails>> getQuiz(String id) async => quizLoads.removeAt(0);

  @override
  Future<Either<Failure, QuizScore>> attendExam(List<String> answerIds) async {
    attended = answerIds;
    return attend;
  }
}

void main() {
  late _FakeRepository repository;

  setUp(() => repository = _FakeRepository());

  Future<void> pump(WidgetTester tester, String location) async {
    tester.view
      ..physicalSize = const Size(1800, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final getQuiz = GetQuiz(repository);
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/tests',
          builder: (_, _) => BlocProvider(
            create: (_) => TestsCubit(getMyExams: GetMyExams(repository), getMyActivities: GetMyActivities(repository))
              ..load(),
            child: const TestsPage(),
          ),
        ),
        GoRoute(
          path: '/quiz/:id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) => QuizCubit(getQuiz: getQuiz, attendExam: AttendExam(repository))..load(id),
              child: QuizPage(quizId: id),
            );
          },
        ),
        GoRoute(
          path: '/quiz/:id/result',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) => QuizResultCubit(getQuiz)..load(id),
              child: QuizResultPage(quizId: id),
            );
          },
        ),
        GoRoute(
          path: '/quiz/:id/review',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) => QuizResultCubit(getQuiz)..load(id),
              child: QuizReviewPage(quizId: id),
            );
          },
        ),
        GoRoute(path: '/home', builder: (_, _) => const Text('home')),
        GoRoute(path: '/notifications', builder: (_, _) => const Text('notifications')),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  group('اختباراتي', () {
    testWidgets('القائمة الفارغة تعرض رسالتها، ونشاطات يومية كذلك', (tester) async {
      await pump(tester, '/tests');

      expect(find.text(AppStrings.noMyExams), findsOneWidget);

      await tester.tap(find.text(AppStrings.tabActivities));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noMyActivities), findsOneWidget);
    });

    testWidgets('البطاقات تفتح الاختبار، والفشل يعيد المحاولة', (tester) async {
      repository
        ..exams = const Right([_exam])
        ..activities = const Right([_activity])
        ..quizLoads.add(const Right(_taking));
      await pump(tester, '/tests');

      expect(find.text('هذا اختبار رباضيات'), findsOneWidget);
      expect(find.text('2 ${AppStrings.questionsUnit}'), findsOneWidget);
      expect(find.text('22'), findsNothing);

      await tester.tap(find.text(AppStrings.tabActivities));
      await tester.pumpAndSettle();
      expect(find.text('نشاط يومي'), findsOneWidget);

      await tester.tap(find.text(AppStrings.tabExams));
      await tester.pumpAndSettle();
      await tester.tap(find.text('هذا اختبار رباضيات'));
      await tester.pumpAndSettle();

      expect(find.text('س1'), findsOneWidget);
      expect(find.text(AppStrings.quizResult), findsOneWidget);
    });

    testWidgets('الفشل يعرض رسالته وإعادة المحاولة تجلب القائمة', (tester) async {
      repository.exams = const Left(ServerFailure('تعذّر الاتصال'));
      await pump(tester, '/tests');
      expect(find.text('تعذّر الاتصال'), findsOneWidget);

      repository.exams = const Right([_exam]);
      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('هذا اختبار رباضيات'), findsOneWidget);
    });
  });

  group('حل الاختبار والنتيجة', () {
    testWidgets('النتيجة معطّلة حتى تُجاب كل الأسئلة، ثم الحضور يفتح النتيجة من الخادم', (tester) async {
      repository.quizLoads.addAll(const [Right(_taking), Right(_scored)]);
      await pump(tester, '/quiz/6');

      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);

      await tester.tap(find.text('110'));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);

      await tester.tap(find.text('333'));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNotNull);

      await tester.tap(find.text(AppStrings.quizResult));
      await tester.pumpAndSettle();

      expect(repository.attended, ['202', '206']);
      expect(find.text(AppStrings.quizFinishedTitle), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(2));
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('فشل الحضور يُبقي الأسئلة ويعرض الرسالة', (tester) async {
      repository
        ..quizLoads.add(const Right(_taking))
        ..attend = const Left(ServerFailure('Server Error'));
      await pump(tester, '/quiz/6');

      await tester.tap(find.text('110'));
      await tester.tap(find.text('333'));
      await tester.pump();
      await tester.tap(find.text(AppStrings.quizResult));
      await tester.pumpAndSettle();

      expect(find.text('س1'), findsOneWidget);
      expect(find.text('Server Error'), findsOneWidget);
    });

    testWidgets('المراجعة تعرض الإجابة الصحيحة والخاطئة من الخادم', (tester) async {
      repository.quizLoads.add(const Right(_scored));
      await pump(tester, '/quiz/6/review');

      expect(find.text(AppStrings.detailedReview), findsOneWidget);
      expect(find.text(AppStrings.yourAnswerCorrect), findsOneWidget);
      expect(find.text(AppStrings.yourAnswerWrong), findsOneWidget);
      expect(find.text(AppStrings.correctAnswerLabel), findsOneWidget);
      expect(find.text('110'), findsOneWidget);
      expect(find.text('333'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('السؤال بأكثر من إجابة صحيحة: اختيار الثانية صحيح، والخطأ يعرض الصحيحتين', (tester) async {
      // الاختبار 1 على خادم التدريب علّم خيارين صحيحين للسؤال نفسه.
      QuizQuestion question(String selectedId) => QuizQuestion(
            id: selectedId,
            text: 'س$selectedId',
            answers: [
              QuizAnswer(id: '1', text: 'أ', isCorrect: true, isSelected: selectedId == '1'),
              QuizAnswer(id: '2', text: 'ب', isCorrect: true, isSelected: selectedId == '2'),
              QuizAnswer(id: '3', text: 'ج', isCorrect: false, isSelected: selectedId == '3'),
            ],
          );
      repository.quizLoads.add(
        Right(
          QuizDetails(
            id: '1',
            title: 'اختبار',
            questionsCount: 2,
            correctAnswers: 1,
            failedAnswers: 1,
            questions: [question('2'), question('3')],
          ),
        ),
      );
      await pump(tester, '/quiz/1/review');

      expect(find.text(AppStrings.yourAnswerCorrect), findsOneWidget);
      expect(find.text(AppStrings.yourAnswerWrong), findsOneWidget);
      expect(find.text(AppStrings.correctAnswerLabel), findsOneWidget);
      expect(find.text('أ، ب'), findsOneWidget);
    });

    testWidgets('تأكد من الأجوبة يفتح المراجعة', (tester) async {
      repository.quizLoads.addAll(const [Right(_scored), Right(_scored)]);
      await pump(tester, '/quiz/6/result');

      await tester.tap(find.text(AppStrings.reviewAnswers));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.detailedReview), findsOneWidget);
    });
  });
}
