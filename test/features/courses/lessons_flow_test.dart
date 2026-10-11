import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/theme/app_icons.dart';
import 'package:educational_app/features/courses/domain/entities/lesson.dart';
import 'package:educational_app/features/courses/domain/entities/lesson_details.dart';
import 'package:educational_app/features/courses/domain/entities/semester.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/attend_lesson.dart';
import 'package:educational_app/features/courses/domain/usecases/get_lesson.dart';
import 'package:educational_app/features/courses/presentation/cubit/lesson_cubit.dart';
import 'package:educational_app/features/courses/presentation/pages/video_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const _videoUrl = 'https://www.youtube.com/watch?v=q0zaEGbs-cE';
const _fileUrl = 'https://training.tamkeen-dev.com/dareb/public/assets/pdf.pdf';

Lesson _lesson(String id, LessonType type, {bool isFree = true, String videoUrl = _videoUrl}) => Lesson(
      id: id,
      title: 'درس $id',
      type: type,
      duration: type == LessonType.exam ? null : '11:50:51',
      videoUrl: type == LessonType.video ? videoUrl : null,
      fileUrl: type == LessonType.file ? _fileUrl : null,
      order: 0,
      isFree: isFree,
      isSubscribed: false,
      isAttended: false,
    );

LessonDetails _details(Lesson lesson) => LessonDetails(
      lesson: lesson,
      semester: Semester(
        id: '2',
        name: 'السيدة بتول الترابين',
        isFree: true,
        price: 71,
        lessonsCount: 3,
        isSubscribed: false,
        lessons: [_lesson('3', LessonType.video), _lesson('4', LessonType.file), _lesson('5', LessonType.exam)],
      ),
    );

class _FakeRepository extends Fake implements CoursesRepository {
  final lessons = <Either<Failure, LessonDetails>>[];
  final attended = <String>[];

  @override
  Future<Either<Failure, LessonDetails>> getLesson(String lessonId) async => lessons.removeAt(0);

  @override
  Future<Either<Failure, void>> attendLesson(String lessonId) async {
    attended.add(lessonId);
    return const Right(null);
  }
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

  Future<void> pumpLesson(WidgetTester tester, String lessonId, {bool canOpen = true}) async {
    tester.view
      ..physicalSize = const Size(1800, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => LessonCubit(getLesson: GetLesson(repository), attendLesson: AttendLesson(repository))
            ..load(lessonId),
          child: VideoPage(
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

  testWidgets('تعرض الدرس واسم فصله ودروس الفصل', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3');

    expect(find.text('السيدة بتول الترابين'), findsOneWidget);
    expect(find.text('درس 4'), findsOneWidget);
    expect(find.text(AppStrings.examLesson), findsOneWidget);
  });

  testWidgets('درس الفيديو يعرض المشغّل بمعرّف الفيديو، ولا يسجّل الحضور عند الفتح', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3');

    expect(find.text('player q0zaEGbs-cE'), findsOneWidget);
    expect(find.text(AppStrings.watchOnYoutube), findsNothing);
    expect(repository.attended, isEmpty);
  });

  testWidgets('بدء التشغيل يسجّل الحضور مرة واحدة مهما تكرر', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3');

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

    await tester.tap(find.text('error'));
    await tester.pumpAndSettle();
    expect(find.textContaining('player '), findsNothing);

    await tester.tap(find.text(AppStrings.watchOnYoutube));
    await tester.pumpAndSettle();

    expect(opened, [Uri.parse(_videoUrl)]);
    expect(repository.attended, ['3']);
  });

  testWidgets('رابط ليس من يوتيوب يعرض زر الفتح الخارجي بلا مشغّل', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video, videoUrl: 'https://example.com/v.mp4'))));
    await pumpLesson(tester, '3');

    expect(find.textContaining('player '), findsNothing);
    expect(find.text(AppStrings.watchOnYoutube), findsOneWidget);
  });

  testWidgets('على Windows يظهر زر يوتيوب بدل المشغّل', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3');

    expect(find.textContaining('player '), findsNothing);
    expect(find.text(AppStrings.watchOnYoutube), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('فتح الملف يفتح رابط الملف', (tester) async {
    repository.lessons.add(Right(_details(_lesson('4', LessonType.file))));
    await pumpLesson(tester, '4');

    await tester.tap(find.byIcon(PhosphorIconsFill.filePdf).first);
    await tester.pumpAndSettle();

    expect(opened, [Uri.parse(_fileUrl)]);
  });

  testWidgets('تعذّر فتح الرابط يعرض رسالة ولا يسجّل الحضور', (tester) async {
    repository.lessons.add(Right(_details(_lesson('3', LessonType.video))));
    await pumpLesson(tester, '3', canOpen: false);

    await tester.tap(find.text('error'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.watchOnYoutube));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.linkOpenError), findsOneWidget);
    expect(repository.attended, isEmpty);
  });

  testWidgets('الدرس المقفل يعرض رسالة المشتركين بلا مشغّل ولا يُفتح', (tester) async {
    repository.lessons.add(Right(_details(_lesson('2', LessonType.video, isFree: false))));
    await pumpLesson(tester, '2');

    expect(find.text(AppStrings.subscribersOnlyLesson), findsOneWidget);
    expect(find.textContaining('player '), findsNothing);
    expect(find.text(AppStrings.watchOnYoutube), findsNothing);

    await tester.tap(find.text(AppStrings.subscribersOnlyLesson));
    await tester.pumpAndSettle();

    expect(opened, isEmpty);
    expect(repository.attended, isEmpty);
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

    expect(find.text('السيدة بتول الترابين'), findsOneWidget);
  });
}
