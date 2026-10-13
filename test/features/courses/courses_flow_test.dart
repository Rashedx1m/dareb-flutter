import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/widgets/error_view.dart';
import 'package:educational_app/features/courses/domain/entities/course.dart';
import 'package:educational_app/features/courses/domain/entities/course_details.dart';
import 'package:educational_app/features/courses/domain/entities/lesson.dart';
import 'package:educational_app/features/courses/domain/entities/semester.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:educational_app/features/courses/domain/entities/subject_details.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/get_course_details.dart';
import 'package:educational_app/features/courses/domain/usecases/get_courses.dart';
import 'package:educational_app/features/courses/domain/usecases/get_my_courses.dart';
import 'package:educational_app/features/courses/domain/usecases/get_subject_details.dart';
import 'package:educational_app/features/courses/domain/usecases/get_subjects.dart';
import 'package:educational_app/features/courses/presentation/cubit/course_details_cubit.dart';
import 'package:educational_app/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:educational_app/features/courses/presentation/cubit/my_courses_cubit.dart';
import 'package:educational_app/features/courses/presentation/cubit/subject_details_cubit.dart';
import 'package:educational_app/features/courses/presentation/cubit/subjects_cubit.dart';
import 'package:educational_app/features/courses/presentation/pages/categories_page.dart';
import 'package:educational_app/features/courses/presentation/pages/course_detail_page.dart';
import 'package:educational_app/features/courses/presentation/pages/courses_page.dart';
import 'package:educational_app/features/courses/presentation/pages/my_courses_page.dart';
import 'package:educational_app/features/courses/presentation/pages/subject_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _subject = Subject(id: '2', name: 'سارين الطراونة', imageUrl: 'x', isFree: true, isSubscribed: false);

Course _course({bool isSubscribed = false, bool isFree = false}) => Course(
      id: '1',
      title: 'الدكتور هناء القطيشات',
      subjectName: 'ناردين الشطناوي',
      instructor: 'أكرم أبو الرب',
      description: 'وصف الدورة',
      imageUrl: 'x',
      price: 36,
      semestersCount: 2,
      semesterRate: 50,
      lessonsCount: 4,
      lessonRate: 25,
      subscriptionsCount: 3,
      isFree: isFree,
      isSubscribed: isSubscribed,
    );

Lesson _lesson(
  String id,
  LessonType type, {
  bool isFree = true,
  String? duration = '00:11:50',
  bool isAttended = false,
}) =>
    Lesson(
      id: id,
      title: 'درس $id',
      type: type,
      duration: type == LessonType.exam ? null : duration,
      fileUrl: type == LessonType.file ? 'https://api.test/lesson-$id.pdf' : null,
      order: 0,
      isFree: isFree,
      isSubscribed: false,
      isAttended: isAttended,
    );

/// الفصل الأول: فيديو مقفل ثم اختبار. الثاني: فيديو مجاني ثم ملف ينتظره.
CourseDetails _details({
  bool isSubscribed = false,
  bool isFree = false,
  bool attended3 = false,
  bool story = false,
}) =>
    CourseDetails(
      course: _course(isSubscribed: isSubscribed, isFree: isFree),
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
          lessons: [
            _lesson('3', LessonType.video, isAttended: attended3),
            _lesson('4', LessonType.file, duration: '00:20:24'),
          ],
        ),
      ],
      pointsCount: 600,
      storyImageUrl: story ? 'x' : null,
      storyText: story ? 'قصة الدورة' : null,
      isFirstStory: story,
    );

/// مستودع مزيّف يُرجع النتائج بالترتيب، نتيجة لكل طلب.
class _FakeRepository extends Fake implements CoursesRepository {
  final subjects = <Either<Failure, List<Subject>>>[];
  final courses = <Either<Failure, List<Course>>>[];
  final details = <Either<Failure, CourseDetails>>[];
  final myCourses = <Either<Failure, List<Course>>>[];
  final subjectDetails = <Either<Failure, SubjectDetails>>[];

  @override
  Future<Either<Failure, SubjectDetails>> getSubjectDetails(String subjectId) async => subjectDetails.removeAt(0);

  @override
  Future<Either<Failure, List<Course>>> getMyCourses() async => myCourses.removeAt(0);

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
      if (!pages.containsKey('/categories/:id'))
        GoRoute(
          path: '/categories/:id',
          builder: (_, state) => Text('subject ${state.pathParameters['id']}'),
        ),
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
      GoRoute(path: '/quiz/:id', builder: (_, state) => Text('quiz ${state.pathParameters['id']}')),
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

    testWidgets('«كل الفئات» تعرض المواد، والضغط على مادة يفتح صفحتها', (tester) async {
      repository.subjects.add(const Right([_subject]));
      await pumpSubjects(tester);

      expect(find.text(AppStrings.allCategories), findsOneWidget);
      await tester.tap(find.text('سارين الطراونة'));
      await tester.pumpAndSettle();

      expect(find.text('subject 2'), findsOneWidget);
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

  group('صفحة المادة', () {
    const exam = SubjectExam(
      id: '6',
      title: 'هذا اختبار رياضيات',
      instructor: 'أ.عمر النابلسي',
      questionsCount: 20,
      isFree: false,
      isSubscribed: false,
    );
    SubjectDetails details({List<SubjectExam> exams = const [exam]}) =>
        SubjectDetails(course: _course(), pointsCount: 600, exams: exams, activities: const []);

    Future<void> pumpSubject(WidgetTester tester) {
      return _pump(tester, '/categories/1', {
        '/categories/:id': (state) => BlocProvider(
              create: (_) => SubjectDetailsCubit(GetSubjectDetails(repository))..load(state.pathParameters['id']!),
              child: SubjectPage(subjectId: state.pathParameters['id']!),
            ),
      });
    }

    testWidgets('الترويسة باسم المادة، و«المحتوى» بطاقة دورتها تفتحها', (tester) async {
      repository.subjectDetails.add(Right(details()));
      await pumpSubject(tester);

      expect(find.text('ناردين الشطناوي'), findsOneWidget);
      expect(find.text('أكرم أبو الرب'), findsOneWidget);
      expect(find.text('600'), findsOneWidget);
      expect(find.text('2 ${AppStrings.chaptersLabel} , 4 ${AppStrings.lessonsLabel}'), findsOneWidget);

      await tester.tap(find.text('الدكتور هناء القطيشات'));
      await tester.pumpAndSettle();
      expect(find.text('course 1'), findsOneWidget);
    });

    testWidgets('«اختبارات» تعرض الاختبارات بعدد أسئلتها، و«نشاطات يومية» فارغة برسالتها', (tester) async {
      repository.subjectDetails.add(Right(details()));
      await pumpSubject(tester);

      await tester.tap(find.text(AppStrings.tabExams));
      await tester.pumpAndSettle();
      expect(find.text('هذا اختبار رياضيات'), findsOneWidget);
      expect(find.text('20 ${AppStrings.questionsUnit}'), findsOneWidget);
      expect(find.text('الدكتور هناء القطيشات'), findsNothing);

      await tester.tap(find.text(AppStrings.tabActivities));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.noSubjectActivities), findsOneWidget);
    });

    testWidgets('البحث يصفّي التبويب المفتوح', (tester) async {
      repository.subjectDetails.add(Right(details()));
      await pumpSubject(tester);
      await tester.tap(find.text(AppStrings.tabExams));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'كيمياء');
      await tester.pumpAndSettle();
      expect(find.text('هذا اختبار رياضيات'), findsNothing);
      expect(find.text(AppStrings.noMatches), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'رياضيات');
      await tester.pumpAndSettle();
      expect(find.text('هذا اختبار رياضيات'), findsOneWidget);
    });

    testWidgets('الاختبار المجاني أو المشترك يفتح صفحة الحل، وغيره نافذة الاشتراك', (tester) async {
      const free = SubjectExam(
        id: '6',
        title: 'هذا اختبار رياضيات',
        instructor: 'أ.عمر النابلسي',
        questionsCount: 20,
        isFree: true,
        isSubscribed: false,
      );
      repository.subjectDetails.add(Right(details(exams: [free])));
      await pumpSubject(tester);
      await tester.tap(find.text(AppStrings.tabExams));
      await tester.pumpAndSettle();
      await tester.tap(find.text('هذا اختبار رياضيات'));
      await tester.pumpAndSettle();
      expect(find.text('quiz 6'), findsOneWidget);
    });

    testWidgets('الاختبار غير المجاني وغير المشترك يطلب الاشتراك', (tester) async {
      repository.subjectDetails.add(Right(details()));
      await pumpSubject(tester);
      await tester.tap(find.text(AppStrings.tabExams));
      await tester.pumpAndSettle();
      await tester.tap(find.text('هذا اختبار رياضيات'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.subscribeToGetIt), findsOneWidget);
    });

    testWidgets('بلا اختبارات يعرض رسالتها', (tester) async {
      repository.subjectDetails.add(Right(details(exams: [])));
      await pumpSubject(tester);

      await tester.tap(find.text(AppStrings.tabExams));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noSubjectExams), findsOneWidget);
    });

    testWidgets('الفشل يعرض رسالته، وإعادة المحاولة تجلب المادة', (tester) async {
      repository.subjectDetails.addAll([const Left(ServerFailure('تعذّر الاتصال')), Right(details())]);
      await pumpSubject(tester);
      expect(find.text('تعذّر الاتصال'), findsOneWidget);

      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text('الدكتور هناء القطيشات'), findsOneWidget);
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

  group('صفحة موادي', () {
    Future<void> pumpMyCourses(WidgetTester tester) {
      return _pump(tester, '/my-courses', {
        '/my-courses': (_) => BlocProvider(
              create: (_) => MyCoursesCubit(GetMyCourses(repository))..load(),
              child: const MyCoursesPage(),
            ),
      });
    }

    testWidgets('بطاقة المادة تعرض العدّادات ونسبة الدروس المنجزة، و«متابعة التعلم» تفتح الدورة', (tester) async {
      repository.myCourses.add(Right([_course(isSubscribed: true)]));
      await pumpMyCourses(tester);

      expect(find.text(AppStrings.mySubjects), findsOneWidget);
      expect(find.text('2 ${AppStrings.chaptersLabel} , 4 ${AppStrings.lessonsLabel}'), findsOneWidget);
      expect(find.text(AppStrings.completedLessons), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      // semesterRate (50) لا يُعرض لأن معناه غير مؤكد.
      expect(find.text('50%'), findsNothing);

      await tester.tap(find.text(AppStrings.keepLearning));
      await tester.pumpAndSettle();

      expect(find.text('course 1'), findsOneWidget);
    });

    testWidgets('البحث يصفّي المواد بالعنوان واسم المادة', (tester) async {
      repository.myCourses.add(Right([_course(isSubscribed: true)]));
      await pumpMyCourses(tester);

      await tester.enterText(find.byType(TextField), 'ناردين');
      await tester.pump();
      expect(find.text('الدكتور هناء القطيشات'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'فيزياء');
      await tester.pump();
      expect(find.text('الدكتور هناء القطيشات'), findsNothing);
      expect(find.text(AppStrings.noSearchResults), findsOneWidget);
    });

    testWidgets('تبويبا الفصول والباقات فارغان', (tester) async {
      repository.myCourses.add(Right([_course(isSubscribed: true)]));
      await pumpMyCourses(tester);

      await tester.tap(find.text(AppStrings.tabSemesters));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.noMySemesters), findsOneWidget);
      expect(find.text('الدكتور هناء القطيشات'), findsNothing);

      await tester.tap(find.text(AppStrings.tabPackages));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.noMyPackages), findsOneWidget);

      await tester.tap(find.text(AppStrings.subjects));
      await tester.pumpAndSettle();
      expect(find.text('الدكتور هناء القطيشات'), findsOneWidget);
    });

    testWidgets('بلا اشتراكات تعرض رسالة', (tester) async {
      repository.myCourses.add(const Right([]));
      await pumpMyCourses(tester);

      expect(find.text(AppStrings.noMyCourses), findsOneWidget);
    });

    testWidgets('الفشل يعرض رسالته، وإعادة المحاولة تجلب المواد', (tester) async {
      repository.myCourses.addAll([const Left(ServerFailure('تعذّر الاتصال')), Right([_course(isSubscribed: true)])]);
      await pumpMyCourses(tester);
      expect(find.text('تعذّر الاتصال'), findsOneWidget);

      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.keepLearning), findsOneWidget);
    });
  });

  group('صفحة الدورة', () {
    late List<Uri> opened;

    Future<void> pumpDetails(WidgetTester tester) {
      opened = [];
      return _pump(tester, '/courses/1', {
        '/courses/:id': (state) => BlocProvider(
              create: (_) => CourseDetailsCubit(GetCourseDetails(repository))..load(state.pathParameters['id']!),
              child: CourseDetailPage(
                courseId: state.pathParameters['id']!,
                openLink: (uri) async {
                  opened.add(uri);
                  return true;
                },
              ),
            ),
      });
    }

    /// الصفحة أطول من الشاشة، فيُمرَّر إلى العنصر قبل الضغط عليه.
    Future<void> tapText(WidgetTester tester, String text) async {
      await tester.ensureVisible(find.text(text));
      await tester.pumpAndSettle();
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    testWidgets('الرأس يعرض الأستاذ والنقاط واسم الدورة وعدد فصولها ودروسها والوصف', (tester) async {
      repository.details.add(Right(_details()));
      await pumpDetails(tester);

      expect(find.text('أكرم أبو الرب'), findsOneWidget);
      expect(find.text('600'), findsOneWidget);
      expect(find.text('الدكتور هناء القطيشات'), findsOneWidget);
      expect(find.text('2 ${AppStrings.chaptersLabel} , 4 ${AppStrings.lessonsLabel}'), findsOneWidget);
      expect(find.text('وصف الدورة'), findsOneWidget);
      expect(find.text(AppStrings.learningPath), findsOneWidget);
    });

    testWidgets('تعرض الدروس تحت فصولها بعددها، وتخفي الفصل الفارغ', (tester) async {
      repository.details.add(Right(_details()));
      await pumpDetails(tester);

      expect(find.textContaining('الفصل الأول'), findsOneWidget);
      expect(find.textContaining('الفصل الثاني'), findsOneWidget);
      expect(find.textContaining('فصل فارغ'), findsNothing);
      expect(
        tester.getTopLeft(find.textContaining('الفصل الأول')).dy,
        lessThan(tester.getTopLeft(find.text('درس 2')).dy),
      );
      expect(
        tester.getTopLeft(find.textContaining('الفصل الثاني')).dy,
        lessThan(tester.getTopLeft(find.text('درس 3')).dy),
      );
      expect(find.text('11:50 ${AppStrings.minutesUnit}'), findsNWidgets(2));
      expect(find.text(AppStrings.examLesson), findsOneWidget);
      expect(find.text(AppStrings.pdfFile), findsOneWidget);
    });

    testWidgets('الدرس المفتوح يُفتح، والاختبار لا يستجيب', (tester) async {
      repository.details.add(Right(_details()));
      await pumpDetails(tester);

      await tapText(tester, 'درس 5');
      expect(find.textContaining('lesson '), findsNothing);
      expect(find.byType(Dialog), findsNothing);

      await tapText(tester, 'درس 3');
      expect(find.text('lesson 3'), findsOneWidget);
    });

    testWidgets('الدرس المقفل يفتح نافذة الاشتراك، و«اشترك» يفتح صفحة الاشتراك', (tester) async {
      repository.details.add(Right(_details()));
      await pumpDetails(tester);

      await tapText(tester, 'درس 2');
      expect(find.text(AppStrings.subscribeToGetIt), findsOneWidget);

      await tester.tap(find.text(AppStrings.subscribeWord));
      await tester.pumpAndSettle();
      expect(find.text('subscription'), findsOneWidget);
    });

    testWidgets('«الرجوع» يغلق نافذة الاشتراك بلا انتقال', (tester) async {
      repository.details.add(Right(_details()));
      await pumpDetails(tester);

      await tapText(tester, 'درس 2');
      await tester.tap(find.text(AppStrings.back));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.subscribeToGetIt), findsNothing);
      expect(find.text('subscription'), findsNothing);
    });

    testWidgets('الدرس الذي ينتظر سابقه يطلب إكماله، و«ابدأ» يفتح الدرس السابق', (tester) async {
      repository.details.add(Right(_details()));
      await pumpDetails(tester);

      expect(find.text(AppStrings.nowPlaying), findsOneWidget);
      await tapText(tester, 'درس 4');
      expect(find.text(AppStrings.finishPreviousLesson), findsOneWidget);

      await tester.tap(find.text(AppStrings.startWord));
      await tester.pumpAndSettle();
      expect(find.text('lesson 3'), findsOneWidget);
    });

    testWidgets('حضور الدرس يفتح ما بعده، ويظهر عليه «تمت المشاهدة»', (tester) async {
      repository.details.add(Right(_details(attended3: true)));
      await pumpDetails(tester);

      expect(find.text(AppStrings.watched), findsOneWidget);
      await tapText(tester, 'درس 4');
      expect(find.text('lesson 4'), findsOneWidget);
    });

    testWidgets('زر التنزيل في درس الملف المفتوح يفتح رابط الملف', (tester) async {
      repository.details.add(Right(_details(attended3: true)));
      await pumpDetails(tester);

      await tester.ensureVisible(find.byTooltip(AppStrings.downloadFile));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(AppStrings.downloadFile));
      await tester.pumpAndSettle();

      expect(opened, [Uri.parse('https://api.test/lesson-4.pdf')]);
    });

    testWidgets('نافذة التعريف تظهر حين يطلبها الخادم، و«ابدأ الآن» يفتح درس «قيد التشغيل»', (tester) async {
      repository.details.add(Right(_details(story: true)));
      await pumpDetails(tester);

      expect(find.text('قصة الدورة'), findsOneWidget);
      await tester.tap(find.text(AppStrings.startNow));
      await tester.pumpAndSettle();

      expect(find.text('lesson 3'), findsOneWidget);
    });

    testWidgets('بلا طلب من الخادم لا تظهر نافذة التعريف', (tester) async {
      repository.details.add(Right(_details()));
      await pumpDetails(tester);

      expect(find.text(AppStrings.startNow), findsNothing);
    });

    testWidgets('الفشل يعرض رسالة الخادم، وإعادة المحاولة تجلب الدورة', (tester) async {
      repository.details.addAll([const Left(ValidationFailure('الحقل المواد لاغٍ')), Right(_details())]);
      await pumpDetails(tester);
      expect(find.text('الحقل المواد لاغٍ'), findsOneWidget);

      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();

      expect(find.textContaining('الفصل الأول'), findsOneWidget);
    });
  });
}
