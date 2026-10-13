import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/entities/search_results.dart';
import 'package:educational_app/features/courses/domain/entities/subject_details.dart';
import 'package:educational_app/features/courses/domain/usecases/search_content.dart';
import 'package:educational_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:educational_app/features/search/presentation/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _subject = Subject(id: '1', name: 'ناردين الشطناوي', imageUrl: 'x', isFree: false, isSubscribed: false);

/// مستودع مزيّف يُرجع النتائج بالترتيب، نتيجة لكل طلب.
class _FakeRepository extends Fake implements CoursesRepository {
  final results = <Either<Failure, SearchResults>>[];

  @override
  Future<Either<Failure, SearchResults>> search(String query) async => results.removeAt(0);
}

void main() {
  late _FakeRepository repository;

  setUp(() => repository = _FakeRepository());

  Future<void> pumpSearch(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1800, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
          path: '/search',
          builder: (_, _) => BlocProvider(
            create: (_) => SearchCubit(SearchContent(repository)),
            child: const SearchPage(),
          ),
        ),
        GoRoute(path: '/courses/:id', builder: (_, state) => Text('course ${state.pathParameters['id']}')),
        GoRoute(path: '/quiz/:id', builder: (_, state) => Text('quiz ${state.pathParameters['id']}')),
        GoRoute(path: '/subscription', builder: (_, _) => const Text('subscription')),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('قبل الكتابة تظهر دعوة للبحث', (tester) async {
    await pumpSearch(tester);

    expect(find.text(AppStrings.searchPrompt), findsOneWidget);
  });

  testWidgets('الكتابة تعرض المواد، والضغط على مادة يفتح دورتها', (tester) async {
    repository.results.add(const Right(SearchResults(subjects: [_subject])));
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'ناردين');
    // البحث ينتظر توقف الكتابة 400ms قبل الطلب.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ناردين الشطناوي'));
    await tester.pumpAndSettle();

    expect(find.text('course 1'), findsOneWidget);
  });

  testWidgets('لا نتائج تعرض رسالة', (tester) async {
    repository.results.add(const Right(SearchResults.empty));
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'زز');
    // البحث ينتظر توقف الكتابة 400ms قبل الطلب.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noMatches), findsOneWidget);
  });

  testWidgets('الفشل يعرض رسالته، وإعادة المحاولة تبحث بالنص نفسه', (tester) async {
    repository.results.addAll([const Left(ServerFailure('تعذّر الاتصال')), const Right(SearchResults(subjects: [_subject]))]);
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'ناردين');
    // البحث ينتظر توقف الكتابة 400ms قبل الطلب.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('تعذّر الاتصال'), findsOneWidget);

    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();

    expect(find.text('ناردين الشطناوي'), findsOneWidget);
  });

  testWidgets('النتائج مجمّعة: النشاطات ثم الدورات ثم الاختبارات', (tester) async {
    const exam = SubjectExam(
      id: '6',
      title: 'إختبار رياضيات',
      instructor: 'أ.عمر النابلسي',
      questionsCount: 20,
      isFree: true,
      isSubscribed: false,
    );
    const activity = SubjectExam(
      id: '7',
      title: 'نشاطات رياضيات',
      instructor: 'أ.باسم السليمان',
      questionsCount: 20,
      isFree: true,
      isSubscribed: false,
    );
    repository.results.add(const Right(SearchResults(subjects: [_subject], exams: [exam], activities: [activity])));
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'رياضيات');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    final activities = tester.getTopLeft(find.text(AppStrings.sectionActivities)).dy;
    final courses = tester.getTopLeft(find.text(AppStrings.sectionCourses)).dy;
    final exams = tester.getTopLeft(find.text(AppStrings.sectionExams)).dy;
    expect(activities, lessThan(courses));
    expect(courses, lessThan(exams));
    expect(find.text('نشاطات رياضيات'), findsOneWidget);
    expect(find.text('إختبار رياضيات'), findsOneWidget);
    expect(find.text('20 ${AppStrings.questionsUnit}'), findsNWidgets(2));
  });

  testWidgets('القسم الفارغ لا يظهر', (tester) async {
    repository.results.add(const Right(SearchResults(subjects: [_subject])));
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'ناردين');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.sectionCourses), findsOneWidget);
    expect(find.text(AppStrings.sectionActivities), findsNothing);
    expect(find.text(AppStrings.sectionExams), findsNothing);
  });

  testWidgets('الضغط على اختبار مجاني يفتح صفحة الحل', (tester) async {
    const exam = SubjectExam(
      id: '6',
      title: 'إختبار رياضيات',
      instructor: 'أ.عمر النابلسي',
      questionsCount: 20,
      isFree: true,
      isSubscribed: false,
    );
    repository.results.add(const Right(SearchResults(exams: [exam])));
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'رياضيات');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إختبار رياضيات'));
    await tester.pumpAndSettle();

    expect(find.text('quiz 6'), findsOneWidget);
  });
}
