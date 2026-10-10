import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/widgets/error_view.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/get_subjects.dart';
import 'package:educational_app/features/courses/presentation/cubit/subjects_cubit.dart';
import 'package:educational_app/features/courses/presentation/pages/categories_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _subject = Subject(id: '2', name: 'سارين الطراونة', imageUrl: 'x', isFree: true, isSubscribed: false);

/// مستودع مزيّف يُرجع النتائج بالترتيب، نتيجة لكل طلب.
class _FakeRepository extends Fake implements CoursesRepository {
  final subjects = <Either<Failure, List<Subject>>>[];

  @override
  Future<Either<Failure, List<Subject>>> getSubjects() async => subjects.removeAt(0);
}

/// يفتح [location] داخل موجّه فيه الصفحة المختبرة، ومسار الدورة يعرض معرّفها فقط.
Future<void> _pump(WidgetTester tester, String location, Map<String, Widget Function(GoRouterState)> pages) async {
  tester.view
    // خط الاختبار يعطي كل حرف عرضاً يساوي حجمه، فالنص العربي أعرض منه على الجهاز.
    ..physicalSize = const Size(1800, 3600)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: location,
    routes: [
      for (final entry in pages.entries) GoRoute(path: entry.key, builder: (_, state) => entry.value(state)),
      GoRoute(
        path: '/courses/:id',
        builder: (_, state) => Text('course ${state.pathParameters['id']}'),
      ),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

void main() {
  late _FakeRepository repository;

  setUp(() => repository = _FakeRepository());

  group('صفحة المواد', () {
    Future<void> pumpSubjects(WidgetTester tester) {
      return _pump(tester, '/categories', {
        '/categories': (_) => BlocProvider(
              create: (_) => SubjectsCubit(GetSubjects(repository))..load(),
              child: const CategoriesPage(),
            ),
      });
    }

    testWidgets('تعرض المواد، والضغط على مادة يفتح دورتها بمعرّف المادة', (tester) async {
      repository.subjects.add(const Right([_subject]));
      await pumpSubjects(tester);

      await tester.tap(find.text('سارين الطراونة'));
      await tester.pumpAndSettle();

      expect(find.text('course 2'), findsOneWidget);
    });

    testWidgets('القائمة الفارغة تعرض رسالة', (tester) async {
      repository.subjects.add(const Right([]));
      await pumpSubjects(tester);

      expect(find.text(AppStrings.noSubjects), findsOneWidget);
    });

    testWidgets('الفشل يعرض رسالته، وإعادة المحاولة تجلب المواد', (tester) async {
      repository.subjects.addAll([const Left(ServerFailure('تعذّر الاتصال')), const Right([_subject])]);
      await pumpSubjects(tester);
      expect(find.text('تعذّر الاتصال'), findsOneWidget);

      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('سارين الطراونة'), findsOneWidget);
    });
  });
}
