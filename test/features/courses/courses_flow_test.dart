import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/theme/app_icons.dart';
import 'package:educational_app/core/widgets/error_view.dart';
import 'package:educational_app/features/courses/domain/entities/course.dart';
import 'package:educational_app/features/courses/domain/entities/course_details.dart';
import 'package:educational_app/features/courses/domain/entities/lesson.dart';
import 'package:educational_app/features/courses/domain/entities/semester.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/get_course_details.dart';
import 'package:educational_app/features/courses/domain/usecases/get_courses.dart';
import 'package:educational_app/features/courses/domain/usecases/get_subjects.dart';
import 'package:educational_app/features/courses/presentation/cubit/course_details_cubit.dart';
import 'package:educational_app/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:educational_app/features/courses/presentation/cubit/subjects_cubit.dart';
import 'package:educational_app/features/courses/presentation/pages/categories_page.dart';
import 'package:educational_app/features/courses/presentation/pages/course_detail_page.dart';
import 'package:educational_app/features/courses/presentation/pages/courses_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _subject = Subject(id: '2', name: 'سارين الطراونة', imageUrl: 'x', isFree: true, isSubscribed: false);

Course _course({bool isSubscribed = false}) => Course(
      id: '1',
      title: 'الدكتور هناء القطيشات',
      subjectName: 'ناردين الشطناوي',
      instructor: 'أكرم أبو الرب',
      description: 'وصف الدورة',
      imageUrl: 'x',
      price: 36,
      semestersCount: 2,
      lessonsCount: 4,
      subscriptionsCount: 3,
      isFree: false,
      isSubscribed: isSubscribed,
    );

Lesson _lesson(String id, LessonType type, {bool isFree = true, String? duration = '11:50:51'}) => Lesson(
      id: id,
      title: 'درس $id',
      type: type,
      duration: type == LessonType.exam ? null : duration,
      order: 0,
      isFree: isFree,
      isSubscribed: false,
      isAttended: false,
    );

CourseDetails _details({bool isSubscribed = false}) => CourseDetails(
      course: _course(isSubscribed: isSubscribed),
      semesters: [
        Semester(
          id: '1',
          name: 'الفصل الأول',
          isFree: false,
          price: 88,
          lessonsCount: 2,
          isSubscribed: false,
          lessons: [_lesson('2', LessonType.video, isFree: false), _lesson('5', LessonType.exam)],
        ),
        const Semester(id: '9', name: 'فصل فارغ', isFree: true, price: 0, lessonsCount: 0, isSubscribed: false, lessons: []),
        Semester(
          id: '2',
          name: 'الفصل الثاني',
          isFree: true,
          price: 71,
          lessonsCount: 2,
          isSubscribed: false,
          lessons: [_lesson('3', LessonType.video), _lesson('4', LessonType.file, duration: '20:24:16')],
        ),
      ],
    );

/// مستودع مزيّف يُرجع النتائج بالترتيب، نتيجة لكل طلب.
class _FakeRepository extends Fake implements CoursesRepository {
  final subjects = <Either<Failure, List<Subject>>>[];
  final courses = <Either<Failure, List<Course>>>[];
  final details = <Either<Failure, CourseDetails>>[];

  @override
  Future<Either<Failure, List<Subject>>> getSubjects() async => subjects.removeAt(0);

  @override
  Future<Either<Failure, List<Course>>> getCourses() async => courses.removeAt(0);

  @override
  Future<Either<Failure, CourseDetails>> getCourseDetails(String subjectId) async => details.removeAt(0);
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
      if (!pages.containsKey('/courses/:id'))
        GoRoute(
          path: '/courses/:id',
          builder: (_, state) => Text('course ${state.pathParameters['id']}'),
        ),
      GoRoute(
        path: '/courses/:id/video/:lessonId',
        builder: (_, state) => Text('lesson ${state.pathParameters['lessonId']}'),
      ),
      GoRoute(path: '/subscription', builder: (_, _) => const Text('subscription')),
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

  group('صفحة الدورات', () {
    Future<void> pumpCourses(WidgetTester tester) {
      return _pump(tester, '/courses', {
        '/courses': (_) => BlocProvider(
              create: (_) => CoursesCubit(GetCourses(repository))..load(),
              child: const CoursesPage(),
            ),
      });
    }

    testWidgets('تعرض البطاقات، والضغط على بطاقة يفتح الدورة بمعرّف المادة', (tester) async {
      repository.courses.add(Right([_course()]));
      await pumpCourses(tester);

      expect(find.text('ناردين الشطناوي'), findsOneWidget);
      await tester.tap(find.text('الدكتور هناء القطيشات'));
      await tester.pumpAndSettle();

      expect(find.text('course 1'), findsOneWidget);
    });

    testWidgets('القائمة الفارغة تعرض رسالة', (tester) async {
      repository.courses.add(const Right([]));
      await pumpCourses(tester);

      expect(find.text(AppStrings.noCourses), findsOneWidget);
    });

    testWidgets('الفشل يعرض رسالته، وإعادة المحاولة تجلب الدورات', (tester) async {
      repository.courses.addAll([const Left(ServerFailure('تعذّر الاتصال')), Right([_course()])]);
      await pumpCourses(tester);
      expect(find.text('تعذّر الاتصال'), findsOneWidget);

      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('الدكتور هناء القطيشات'), findsOneWidget);
    });
  });

  group('صفحة الدورة', () {
    Future<void> pumpDetails(WidgetTester tester) {
      return _pump(tester, '/courses/1', {
        '/courses/:id': (state) => BlocProvider(
              create: (_) => CourseDetailsCubit(GetCourseDetails(repository))..load(state.pathParameters['id']!),
              child: CourseDetailPage(courseId: state.pathParameters['id']!),
            ),
      });
    }

    testWidgets('تعرض الدروس تحت فصولها وتخفي الفصل الفارغ', (tester) async {
      repository.details.add(Right(_details()));
      await pumpDetails(tester);

      expect(find.text('الفصل الأول'), findsOneWidget);
      expect(find.text('الفصل الثاني'), findsOneWidget);
      expect(find.text('فصل فارغ'), findsNothing);
      expect(
        tester.getTopLeft(find.text('الفصل الأول')).dy,
        lessThan(tester.getTopLeft(find.text('درس 2')).dy),
      );
      expect(
        tester.getTopLeft(find.text('الفصل الثاني')).dy,
        lessThan(tester.getTopLeft(find.text('درس 3')).dy),
      );
      expect(find.text(AppStrings.examLesson), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(PhosphorIconsFill.filePdf), findsOneWidget);
    });

    testWidgets('الدرس المجاني يفتح، والمقفل والاختبار لا يفتحان', (tester) async {
      repository.details.add(Right(_details()));
      await pumpDetails(tester);

      await tester.tap(find.text('درس 2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('درس 5'));
      await tester.pumpAndSettle();
      expect(find.textContaining('lesson '), findsNothing);

      await tester.tap(find.text('درس 3'));
      await tester.pumpAndSettle();
      expect(find.text('lesson 3'), findsOneWidget);
    });

    testWidgets('غير المشترك يرى زر الاشتراك بالسعر', (tester) async {
      repository.details.add(Right(_details()));
      await pumpDetails(tester);

      await tester.tap(find.text('${AppStrings.subscribe} · 36 ${AppStrings.currency}'));
      await tester.pumpAndSettle();

      expect(find.text('subscription'), findsOneWidget);
    });

    testWidgets('المشترك يبدأ بأول درس يمكن فتحه', (tester) async {
      repository.details.add(Right(_details(isSubscribed: true)));
      await pumpDetails(tester);

      await tester.tap(find.text(AppStrings.startLesson));
      await tester.pumpAndSettle();

      expect(find.text('lesson 3'), findsOneWidget);
    });

    testWidgets('الفشل يعرض رسالة الخادم، وإعادة المحاولة تجلب الدورة', (tester) async {
      repository.details.addAll([const Left(ValidationFailure('الحقل المواد لاغٍ')), Right(_details())]);
      await pumpDetails(tester);
      expect(find.text('الحقل المواد لاغٍ'), findsOneWidget);

      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text('الفصل الأول'), findsOneWidget);
    });
  });
}
