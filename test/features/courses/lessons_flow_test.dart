import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:educational_app/features/courses/domain/entities/comment.dart';
import 'package:educational_app/features/courses/domain/entities/lesson.dart';
import 'package:educational_app/features/courses/domain/entities/lesson_details.dart';
import 'package:educational_app/features/courses/domain/entities/semester.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/add_comment.dart';
import 'package:educational_app/features/courses/domain/usecases/attend_lesson.dart';
import 'package:educational_app/features/courses/domain/usecases/get_lesson.dart';
import 'package:educational_app/features/courses/presentation/cubit/lesson_cubit.dart';
import 'package:educational_app/features/courses/presentation/pages/video_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _videoUrl = 'https://www.youtube.com/watch?v=q0zaEGbs-cE';
const _fileUrl = 'https://training.tamkeen-dev.com/dareb/public/assets/pdf.pdf';
const _me = User(id: '30', name: 'Rashed eybo', phone: '');

Lesson _lesson(
  String id,
  LessonType type, {
  bool isFree = true,
  bool isAttended = false,
  String videoUrl = _videoUrl,
}) =>
    Lesson(
      id: id,
      title: 'درس $id',
      type: type,
      duration: type == LessonType.exam ? null : '00:11:50',
      videoUrl: type == LessonType.video ? videoUrl : null,
      fileUrl: type == LessonType.file ? _fileUrl : null,
      order: 0,
      isFree: isFree,
      isSubscribed: false,
      isAttended: isAttended,
    );

Comment _comment(String id, String author, {String authorId = '7'}) => Comment(
      id: id,
      text: 'تعليق $id',
      authorId: authorId,
      authorName: author,
      createdAt: DateTime(2025, 6, 15),
    );

/// الدرس [lesson] في فصل دروسه: فيديو 3 ثم ملف 4 ثم اختبار 5.
LessonDetails _details(Lesson lesson, {bool attended3 = false, List<Comment> comments = const []}) => LessonDetails(
      lesson: lesson,
      semester: Semester(
        id: '2',
        name: 'السيدة بتول الترابين',
        isFree: true,
        price: 71,
        lessonsCount: 3,
        isSubscribed: false,
        lessons: [
          _lesson('3', LessonType.video, isAttended: attended3),
          _lesson('4', LessonType.file),
          _lesson('5', LessonType.exam),
        ],
      ),
      comments: comments,
    );

class _FakeRepository extends Fake implements CoursesRepository {
  final lessons = <Either<Failure, LessonDetails>>[];
  final attended = <String>[];
  final comments = <NewComment>[];
  Either<Failure, void> commentResult = const Right(null);

  @override
  Future<Either<Failure, LessonDetails>> getLesson(String lessonId) async => lessons.removeAt(0);

  @override
  Future<Either<Failure, void>> attendLesson(String lessonId) async {
    attended.add(lessonId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> addComment(NewComment comment) async {
    comments.add(comment);
    return commentResult;
  }
}

class _FakeAuth extends Fake implements AuthRepository {
  @override
  Future<Either<Failure, User?>> currentUser() async => const Right(_me);
}

/// بديل المشغّل الحقيقي: يعرض المعرّف، وزرّان يحاكيان «بدأ التشغيل» و«خطأ».
Widget _fakePlayer({required String videoId, required VoidCallback onPlaying, required VoidCallback onError}) {
  return Column(
    children: [
      Text('player $videoId'),
      TextButton(onPressed: onPlaying, child: const Text('play')),
      TextButton(onPressed: onError, child: const Text('error')),
    ],
  );
}

void main() {
  late _FakeRepository repository;
  late List<Uri> opened;

  setUp(() {
    repository = _FakeRepository();
    opened = [];
  });

  LessonCubit cubit() => LessonCubit(
        getLesson: GetLesson(repository),
        attendLesson: AttendLesson(repository),
        addComment: AddComment(repository),
        getCurrentUser: GetCurrentUser(_FakeAuth()),
      );

  void tallView(WidgetTester tester) {
    tester.view
      ..physicalSize = const Size(1800, 4200)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpLesson(WidgetTester tester, String lessonId, {bool canOpen = true}) async {
    tallView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => cubit()..load(lessonId),
          child: VideoPage(
            courseId: '1',
            lessonId: lessonId,
            openLink: (uri) async {
              opened.add(uri);
              return canOpen;
            },
            playerBuilder: _fakePlayer,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapPlay(WidgetTester tester) async {
    await tester.tap(find.byTooltip(AppStrings.playLesson));
    await tester.pumpAndSettle();
  }

  testWidgets('تعرض النقاشات ثم دروس الفصل في «مسار التعلم»', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3');

    expect(find.text(AppStrings.discussions), findsOneWidget);
    expect(find.text(AppStrings.noComments), findsOneWidget);
    expect(find.text(AppStrings.learningPath), findsOneWidget);
    expect(find.textContaining('السيدة بتول الترابين'), findsOneWidget);
    expect(find.text('درس 4'), findsOneWidget);
    expect(find.text(AppStrings.examLesson), findsOneWidget);
    // الدرس المفتوح عليه «قيد التشغيل».
    expect(find.text(AppStrings.nowPlaying), findsOneWidget);
  });

  /// تفتح الدرس فوق صفحة أخرى، ليكون للرجوع مكان يعود إليه.
  Future<void> pushLesson(WidgetTester tester) async {
    tallView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider(
                  create: (_) => cubit()..load('3'),
                  child: const VideoPage(courseId: '1', lessonId: '3', playerBuilder: _fakePlayer),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> expectBackCloses(WidgetTester tester) async {
    await tester.tap(find.byTooltip(AppStrings.back));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
    expect(find.byType(VideoPage), findsNothing);
  }

  testWidgets('زر الرجوع يغلق الدرس من الغلاف', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pushLesson(tester);

    await expectBackCloses(tester);
  });

  testWidgets('زر الرجوع يغلق الدرس أثناء التشغيل', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pushLesson(tester);
    await tapPlay(tester);
    expect(find.text('player q0zaEGbs-cE'), findsOneWidget);

    await expectBackCloses(tester);
  });

  testWidgets('زر الرجوع يغلق الدرس عند فشل تحميله', (tester) async {
    repository.lessons.add(const Left(ServerFailure('المحتوى المطلوب غير موجود')));
    await pushLesson(tester);

    await expectBackCloses(tester);
  });

  testWidgets('درس مفتوح في المسار يُفتح مكان الحالي، والدرس الحالي لا يستجيب', (tester) async {
    repository.lessons.addAll([
      Right(_details(_lesson('3', LessonType.video, isAttended: true), attended3: true)),
      Right(_details(_lesson('4', LessonType.file), attended3: true)),
    ]);
    tallView(tester);
    final router = GoRouter(
      initialLocation: '/courses/1/video/3',
      routes: [
        GoRoute(
          path: '/courses/:id/video/:lessonId',
          // كما في app_router: المفتاح ينشئ Cubit للدرس الجديد في الصفحة نفسها.
          builder: (_, state) => BlocProvider(
            key: ValueKey(state.pathParameters['lessonId']),
            create: (_) => cubit()..load(state.pathParameters['lessonId']!),
            child: VideoPage(
              courseId: state.pathParameters['id']!,
              lessonId: state.pathParameters['lessonId']!,
              openLink: (_) async => true,
              playerBuilder: _fakePlayer,
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('درس 3'));
    await tester.pumpAndSettle();
    expect(repository.lessons, hasLength(1));

    await tester.tap(find.text('درس 4'));
    await tester.pumpAndSettle();

    expect(repository.lessons, isEmpty);
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/courses/1/video/4');
    expect(find.byTooltip(AppStrings.openFile), findsOneWidget);
  });

  testWidgets('الدرس الذي ينتظر سابقه يطلب إكماله', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3');

    await tester.tap(find.text('درس 4'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.finishPreviousLesson), findsOneWidget);
  });

  testWidgets('غلاف الفيديو يظهر أولاً، والضغط عليه يشغّل المشغّل بلا تسجيل حضور', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3');

    expect(find.textContaining('player '), findsNothing);
    expect(find.text('11:50 ${AppStrings.minutesUnit}'), findsWidgets);
    expect(find.text('0% ${AppStrings.completedWord}'), findsOneWidget);

    await tapPlay(tester);

    expect(find.text('player q0zaEGbs-cE'), findsOneWidget);
    expect(repository.attended, isEmpty);
  });

  testWidgets('بدء التشغيل يسجّل الحضور مرة واحدة مهما تكرر', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3');
    await tapPlay(tester);

    await tester.tap(find.text('play'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('play'));
    await tester.pumpAndSettle();

    expect(repository.attended, ['3']);
    expect(opened, isEmpty);
  });

  testWidgets('خطأ المشغّل يعرض زر يوتيوب، والضغط يفتح الرابط ويسجّل الحضور', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3');
    await tapPlay(tester);

    await tester.tap(find.text('error'));
    await tester.pumpAndSettle();
    expect(find.textContaining('player '), findsNothing);

    await tester.tap(find.text(AppStrings.watchOnYoutube));
    await tester.pumpAndSettle();

    expect(opened, [Uri.parse(_videoUrl)]);
    expect(repository.attended, ['3']);
  });

  testWidgets('رابط ليس من يوتيوب يعرض زر الفتح الخارجي بلا غلاف', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video, videoUrl: 'https://example.com/v.mp4'))));
    await pumpLesson(tester, '3');

    expect(find.byTooltip(AppStrings.playLesson), findsNothing);
    expect(find.text(AppStrings.watchOnYoutube), findsOneWidget);
  });

  testWidgets('على Windows يفتح زر التشغيل الفيديو خارج التطبيق', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3');

    await tapPlay(tester);

    expect(find.textContaining('player '), findsNothing);
    expect(opened, [Uri.parse(_videoUrl)]);
    expect(repository.attended, ['3']);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('فتح الملف يفتح رابط الملف ويسجّل الحضور', (tester) async {
    repository.lessons.add(Right(_details(_lesson('4', LessonType.file))));
    await pumpLesson(tester, '4');

    await tester.tap(find.byTooltip(AppStrings.openFile));
    await tester.pumpAndSettle();

    expect(opened, [Uri.parse(_fileUrl)]);
    expect(repository.attended, ['4']);
  });

  testWidgets('تعذّر فتح الرابط يعرض رسالة ولا يسجّل الحضور', (tester) async {
    repository.lessons.add(Right(_details(_lesson('4', LessonType.file))));
    await pumpLesson(tester, '4', canOpen: false);

    await tester.tap(find.byTooltip(AppStrings.openFile));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.linkOpenError), findsOneWidget);
    expect(repository.attended, isEmpty);
  });

  testWidgets('المشاركة تنسخ رابط الدرس', (tester) async {
    final copied = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied.add((call.arguments as Map)['text']);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3');

    await tester.tap(find.byTooltip(AppStrings.shareLesson));
    await tester.pumpAndSettle();

    expect(copied, [_videoUrl]);
    expect(find.text(AppStrings.lessonLinkCopied), findsOneWidget);
  });

  testWidgets('الدرس المقفل يعرض رسالة المشتركين بلا مشغّل', (tester) async {
    repository.lessons.add(Right(_details(_lesson('2', LessonType.video, isFree: false))));
    await pumpLesson(tester, '2');

    expect(find.text(AppStrings.subscribersOnlyLesson), findsOneWidget);
    expect(find.byTooltip(AppStrings.playLesson), findsNothing);
    expect(find.text(AppStrings.watchOnYoutube), findsNothing);
  });

  testWidgets('أول تعليقين يظهران، و«أظهر الكل» يعرض البقية', (tester) async {
    repository.lessons.add(
      Right(
        _details(
          _lesson('3', LessonType.video),
          comments: [_comment('1', 'أحمد المصري'), _comment('2', 'محمد الحمصي', authorId: '30'), _comment('3', 'سارة')],
        ),
      ),
    );
    await pumpLesson(tester, '3');

    expect(find.text('أحمد المصري'), findsOneWidget);
    expect(find.text('محمد الحمصي'), findsOneWidget);
    expect(find.text('2025/6/15'), findsNWidgets(2));
    expect(find.text('سارة'), findsNothing);

    await tester.tap(find.text(AppStrings.showAll));
    await tester.pumpAndSettle();

    expect(find.text('سارة'), findsOneWidget);
    expect(find.text(AppStrings.showLess), findsOneWidget);
  });

  testWidgets('إرسال التعليق يرسله، ثم يُفرغ الحقل وتظهر التعليقات المحدّثة', (tester) async {
    repository.lessons.addAll([
      Right(_details(_lesson('3', LessonType.video))),
      Right(_details(_lesson('3', LessonType.video), comments: [_comment('9', 'Rashed eybo', authorId: '30')])),
    ]);
    await pumpLesson(tester, '3');

    await tester.enterText(find.byType(TextField), 'شرح ممتاز');
    await tester.tap(find.byTooltip(AppStrings.sendComment));
    await tester.pumpAndSettle();

    expect(repository.comments, [const NewComment(lessonId: '3', text: 'شرح ممتاز')]);
    expect(find.text('Rashed eybo'), findsOneWidget);
    expect(find.text('شرح ممتاز'), findsNothing);
  });

  testWidgets('فشل إرسال التعليق يعرض رسالته ويُبقي النص', (tester) async {
    repository
      ..lessons.add(Right(_details(_lesson('3', LessonType.video))))
      ..commentResult = const Left(ValidationFailure(AppStrings.errorCommentRequired));
    await pumpLesson(tester, '3');

    await tester.enterText(find.byType(TextField), '  ');
    await tester.tap(find.byTooltip(AppStrings.sendComment));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.errorCommentRequired), findsOneWidget);
  });

  testWidgets('الفشل يعرض رسالته، وإعادة المحاولة تجلب الدرس', (tester) async {
    repository.lessons.addAll([
      const Left(ServerFailure('المحتوى المطلوب غير موجود')),
      Right(_details(_lesson('3', LessonType.video))),
    ]);
    await pumpLesson(tester, '3');
    expect(find.text('المحتوى المطلوب غير موجود'), findsOneWidget);

    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.discussions), findsOneWidget);
  });
}
