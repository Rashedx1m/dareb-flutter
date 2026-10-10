import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/search_subjects.dart';
import 'package:educational_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:educational_app/features/search/presentation/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _subject = Subject(id: '1', name: 'ناردين الشطناوي', imageUrl: 'x', isFree: false, isSubscribed: false);

/// مستودع مزيّف يُرجع النتائج بالترتيب، نتيجة لكل طلب.
class _FakeRepository extends Fake implements CoursesRepository {
  final results = <Either<Failure, List<Subject>>>[];

  @override
  Future<Either<Failure, List<Subject>>> searchSubjects(String query) async => results.removeAt(0);
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
            create: (_) => SearchCubit(SearchSubjects(repository)),
            child: const SearchPage(),
          ),
        ),
        GoRoute(path: '/courses/:id', builder: (_, state) => Text('course ${state.pathParameters['id']}')),
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
    repository.results.add(const Right([_subject]));
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'ناردين');
    await tester.pumpAndSettle();
    await tester.tap(find.text('ناردين الشطناوي'));
    await tester.pumpAndSettle();

    expect(find.text('course 1'), findsOneWidget);
  });

  testWidgets('لا نتائج تعرض رسالة', (tester) async {
    repository.results.add(const Right([]));
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'زز');
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noSearchResults), findsOneWidget);
  });

  testWidgets('الفشل يعرض رسالته، وإعادة المحاولة تبحث بالنص نفسه', (tester) async {
    repository.results.addAll([const Left(ServerFailure('تعذّر الاتصال')), const Right([_subject])]);
    await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'ناردين');
    await tester.pumpAndSettle();
    expect(find.text('تعذّر الاتصال'), findsOneWidget);

    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();

    expect(find.text('ناردين الشطناوي'), findsOneWidget);
  });
}
