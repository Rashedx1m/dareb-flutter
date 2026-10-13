import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:educational_app/features/courses/domain/entities/comment.dart';
import 'package:educational_app/features/courses/domain/entities/course.dart';
import 'package:educational_app/features/courses/domain/entities/course_details.dart';
import 'package:educational_app/features/courses/domain/entities/lesson.dart';
import 'package:educational_app/features/courses/domain/entities/lesson_details.dart';
import 'package:educational_app/features/courses/domain/entities/semester.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:educational_app/features/courses/domain/entities/subject_details.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/add_comment.dart';
import 'package:educational_app/features/courses/domain/usecases/attend_lesson.dart';
import 'package:educational_app/features/courses/domain/usecases/get_course_details.dart';
import 'package:educational_app/features/courses/domain/usecases/get_courses.dart';
import 'package:educational_app/features/courses/domain/usecases/get_lesson.dart';
import 'package:educational_app/features/courses/domain/usecases/get_my_courses.dart';
import 'package:educational_app/features/courses/domain/usecases/get_subject_details.dart';
import 'package:educational_app/features/courses/domain/usecases/get_subjects.dart';
import 'package:educational_app/features/courses/presentation/cubit/course_details_cubit.dart';
import 'package:educational_app/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:educational_app/features/courses/presentation/cubit/lesson_cubit.dart';
import 'package:educational_app/features/courses/presentation/cubit/my_courses_cubit.dart';
import 'package:educational_app/features/courses/presentation/cubit/subject_details_cubit.dart';
import 'package:educational_app/features/courses/presentation/cubit/subjects_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _subject = Subject(id: '2', name: 'سارين الطراونة', imageUrl: 'x', isFree: true, isSubscribed: false);

const _course = Course(
  id: '1',
  title: 'الدكتور هناء القطيشات',
  subjectName: 'ناردين الشطناوي',
  instructor: 'أكرم أبو الرب',
  description: '',
  imageUrl: 'x',
  price: 36,
  semestersCount: 1,
  semesterRate: 0,
  lessonsCount: 1,
  lessonRate: 0,
  subscriptionsCount: 3,
  isFree: false,
  isSubscribed: false,
);

const _details = CourseDetails(
  course: _course,
  semesters: [
    Semester(
      id: '2',
      name: 'السيدة بتول الترابين',
      isFree: true,
      price: 71,
      lessonsCount: 1,
      isSubscribed: false,
      lessons: [
        Lesson(id: '3', title: 'رسلان الدين عباد', type: LessonType.video, order: 6, isFree: true, isSubscribed: false, isAttended: false),
      ],
    ),
  ],
  pointsCount: 600,
  isFirstStory: false,
);

const _lesson = Lesson(
  id: '3',
  title: 'رسلان الدين عباد',
  type: LessonType.video,
  videoUrl: 'https://www.youtube.com/watch?v=q0zaEGbs-cE',
  order: 6,
  isFree: true,
  isSubscribed: false,
  isAttended: false,
);

const _lessonDetails = LessonDetails(
  lesson: _lesson,
  semester: Semester(
    id: '2',
    name: 'السيدة بتول الترابين',
    isFree: true,
    price: 71,
    lessonsCount: 1,
    isSubscribed: false,
    lessons: [_lesson],
  ),
);

const _me = User(id: '30', name: 'Rashed eybo', phone: '');

class _FakeAuth extends Fake implements AuthRepository {
  Either<Failure, User?> user = const Right(_me);

  @override
  Future<Either<Failure, User?>> currentUser() async => user;
}

/// مستودع مزيّف: كل دالة تُرجع ما يعيده الرد المضبوط لها.
class _FakeRepository extends Fake implements CoursesRepository {
  Future<Either<Failure, List<Subject>>> Function() subjects = () async => const Right([_subject]);
  Future<Either<Failure, List<Course>>> Function() courses = () async => const Right([_course]);
  Future<Either<Failure, List<Course>>> Function() myCourses = () async => const Right([_course]);

  @override
  Future<Either<Failure, List<Course>>> getMyCourses() => myCourses();
  Future<Either<Failure, CourseDetails>> Function(String id) details = (_) async => const Right(_details);
  final detailsRequests = <String>[];
  Future<Either<Failure, LessonDetails>> Function(String id) lesson = (_) async => const Right(_lessonDetails);
  Future<Either<Failure, void>> Function(String id) attend = (_) async => const Right(null);
  final attended = <String>[];
  Future<Either<Failure, void>> Function(NewComment comment) comment = (_) async => const Right(null);
  final comments = <NewComment>[];

  @override
  Future<Either<Failure, void>> addComment(NewComment comment) {
    comments.add(comment);
    return this.comment(comment);
  }

  @override
  Future<Either<Failure, LessonDetails>> getLesson(String lessonId) => lesson(lessonId);

  @override
  Future<Either<Failure, void>> attendLesson(String lessonId) {
    attended.add(lessonId);
    return attend(lessonId);
  }

  @override
  Future<Either<Failure, List<Subject>>> getSubjects() => subjects();

  Future<Either<Failure, SubjectDetails>> Function(String id) subjectDetails =
      (_) async => const Right(SubjectDetails(course: _course, pointsCount: 300, exams: [], activities: []));
  final subjectRequests = <String>[];

  @override
  Future<Either<Failure, SubjectDetails>> getSubjectDetails(String subjectId) {
    subjectRequests.add(subjectId);
    return subjectDetails(subjectId);
  }

  @override
  Future<Either<Failure, List<Course>>> getCourses() => courses();

  @override
  Future<Either<Failure, CourseDetails>> getCourseDetails(String subjectId) {
    detailsRequests.add(subjectId);
    return details(subjectId);
  }
}

void main() {
  late _FakeRepository repository;

  setUp(() => repository = _FakeRepository());

  group('SubjectsCubit', () {
    test('يبدأ initial، ثم loading، ثم success بالمواد', () async {
      final cubit = SubjectsCubit(GetSubjects(repository));
      expect(cubit.state.status, SubjectsStatus.initial);

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          const SubjectsState(status: SubjectsStatus.loading),
          const SubjectsState(status: SubjectsStatus.success, subjects: [_subject]),
        ]),
      );
      await cubit.load();
      await states;
    });

    test('الفشل يصل برسالته، وإعادة المحاولة تمسحها', () async {
      final results = <Either<Failure, List<Subject>>>[const Left(ServerFailure('x')), const Right([_subject])];
      repository.subjects = () async => results.removeAt(0);
      final cubit = SubjectsCubit(GetSubjects(repository));

      await cubit.load();
      expect(cubit.state, const SubjectsState(status: SubjectsStatus.failure, error: 'x'));

      await cubit.load();
      expect(cubit.state, const SubjectsState(status: SubjectsStatus.success, subjects: [_subject]));
    });

    test('إغلاق الصفحة قبل وصول الرد لا يرمي خطأ', () async {
      final response = Completer<Either<Failure, List<Subject>>>();
      repository.subjects = () => response.future;
      final cubit = SubjectsCubit(GetSubjects(repository));

      final loading = cubit.load();
      await cubit.close();
      response.complete(const Right([_subject]));

      await expectLater(loading, completes);
    });
  });

  group('CoursesCubit', () {
    test('يبدأ initial، ثم loading، ثم success بالدورات', () async {
      final cubit = CoursesCubit(GetCourses(repository));
      expect(cubit.state.status, CoursesStatus.initial);

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          const CoursesState(status: CoursesStatus.loading),
          const CoursesState(status: CoursesStatus.success, courses: [_course]),
        ]),
      );
      await cubit.load();
      await states;
    });

    test('الفشل يصل برسالته، وإعادة المحاولة تمسحها', () async {
      final results = <Either<Failure, List<Course>>>[const Left(ServerFailure('x')), const Right([_course])];
      repository.courses = () async => results.removeAt(0);
      final cubit = CoursesCubit(GetCourses(repository));

      await cubit.load();
      expect(cubit.state, const CoursesState(status: CoursesStatus.failure, error: 'x'));

      await cubit.load();
      expect(cubit.state, const CoursesState(status: CoursesStatus.success, courses: [_course]));
    });

    test('إغلاق الصفحة قبل وصول الرد لا يرمي خطأ', () async {
      final response = Completer<Either<Failure, List<Course>>>();
      repository.courses = () => response.future;
      final cubit = CoursesCubit(GetCourses(repository));

      final loading = cubit.load();
      await cubit.close();
      response.complete(const Right([_course]));

      await expectLater(loading, completes);
    });
  });

  group('CourseDetailsCubit', () {
    test('يحمّل تفاصيل المادة المطلوبة', () async {
      final cubit = CourseDetailsCubit(GetCourseDetails(repository));

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          const CourseDetailsState(status: CourseDetailsStatus.loading),
          const CourseDetailsState(status: CourseDetailsStatus.success, details: _details),
        ]),
      );
      await cubit.load('1');
      await states;
      expect(repository.detailsRequests, ['1']);
    });

    test('الفشل يصل برسالته، وإعادة المحاولة تمسحها', () async {
      final results = <Either<Failure, CourseDetails>>[
        const Left(ValidationFailure('الحقل المواد لاغٍ')),
        const Right(_details),
      ];
      repository.details = (_) async => results.removeAt(0);
      final cubit = CourseDetailsCubit(GetCourseDetails(repository));

      await cubit.load('1');
      expect(
        cubit.state,
        const CourseDetailsState(status: CourseDetailsStatus.failure, error: 'الحقل المواد لاغٍ'),
      );

      await cubit.load('1');
      expect(cubit.state, const CourseDetailsState(status: CourseDetailsStatus.success, details: _details));
    });

    test('إغلاق الصفحة قبل وصول الرد لا يرمي خطأ', () async {
      final response = Completer<Either<Failure, CourseDetails>>();
      repository.details = (_) => response.future;
      final cubit = CourseDetailsCubit(GetCourseDetails(repository));

      final loading = cubit.load('1');
      await cubit.close();
      response.complete(const Right(_details));

      await expectLater(loading, completes);
    });

    test('التحديث بعد الرجوع من درس يبدّل الدورة بلا loading', () async {
      const attended = CourseDetails(course: _course, semesters: [], pointsCount: 610, isFirstStory: false);
      final results = <Either<Failure, CourseDetails>>[const Right(_details), const Right(attended)];
      repository.details = (_) async => results.removeAt(0);
      final cubit = CourseDetailsCubit(GetCourseDetails(repository));
      await cubit.load('1');

      final states = expectLater(
        cubit.stream,
        emits(const CourseDetailsState(status: CourseDetailsStatus.success, details: attended)),
      );
      await cubit.refresh('1');
      await states;
    });

    test('فشل التحديث لا يغيّر ما يراه الطالب', () async {
      final results = <Either<Failure, CourseDetails>>[
        const Right(_details),
        const Left(ServerFailure('تعذّر الاتصال')),
      ];
      repository.details = (_) async => results.removeAt(0);
      final cubit = CourseDetailsCubit(GetCourseDetails(repository));
      await cubit.load('1');

      await cubit.refresh('1');

      expect(cubit.state, const CourseDetailsState(status: CourseDetailsStatus.success, details: _details));
    });
  });

  group('SubjectDetailsCubit', () {
    test('يحمّل المادة المطلوبة بتبويباتها', () async {
      final cubit = SubjectDetailsCubit(GetSubjectDetails(repository));

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          const SubjectDetailsState(status: SubjectDetailsStatus.loading),
          const SubjectDetailsState(
            status: SubjectDetailsStatus.success,
            details: SubjectDetails(course: _course, pointsCount: 300, exams: [], activities: []),
          ),
        ]),
      );
      await cubit.load('13');
      await states;
      expect(repository.subjectRequests, ['13']);
    });

    test('الفشل يصل برسالته', () async {
      repository.subjectDetails = (_) async => const Left(ServerFailure('تعذّر الاتصال'));
      final cubit = SubjectDetailsCubit(GetSubjectDetails(repository));

      await cubit.load('13');

      expect(cubit.state, const SubjectDetailsState(status: SubjectDetailsStatus.failure, error: 'تعذّر الاتصال'));
    });
  });

  group('MyCoursesCubit', () {
    test('يبدأ initial، ثم loading، ثم success بدورات الاشتراكات', () async {
      final cubit = MyCoursesCubit(GetMyCourses(repository));
      expect(cubit.state.status, MyCoursesStatus.initial);

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          const MyCoursesState(status: MyCoursesStatus.loading),
          const MyCoursesState(status: MyCoursesStatus.success, courses: [_course]),
        ]),
      );
      await cubit.load();
      await states;
    });

    test('الفشل يصل برسالته، وإعادة المحاولة تمسحها', () async {
      final results = <Either<Failure, List<Course>>>[const Left(ServerFailure('x')), const Right([])];
      repository.myCourses = () async => results.removeAt(0);
      final cubit = MyCoursesCubit(GetMyCourses(repository));

      await cubit.load();
      expect(cubit.state, const MyCoursesState(status: MyCoursesStatus.failure, error: 'x'));

      await cubit.load();
      expect(cubit.state, const MyCoursesState(status: MyCoursesStatus.success));
    });

    test('إغلاق الصفحة قبل وصول الرد لا يرمي خطأ', () async {
      final response = Completer<Either<Failure, List<Course>>>();
      repository.myCourses = () => response.future;
      final cubit = MyCoursesCubit(GetMyCourses(repository));

      final loading = cubit.load();
      await cubit.close();
      response.complete(const Right([_course]));

      await expectLater(loading, completes);
    });
  });

  group('LessonCubit', () {
    late _FakeAuth auth;
    setUp(() => auth = _FakeAuth());

    LessonCubit build() => LessonCubit(
          getLesson: GetLesson(repository),
          attendLesson: AttendLesson(repository),
          addComment: AddComment(repository),
          getCurrentUser: GetCurrentUser(auth),
        );

    test('يحمّل الدرس وفصله ومعهما صاحب الجلسة', () async {
      final cubit = build();

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          const LessonState(status: LessonStatus.loading),
          const LessonState(status: LessonStatus.success, details: _lessonDetails, user: _me),
        ]),
      );
      await cubit.load('3');
      await states;
    });

    test('تعذّر قراءة صاحب الجلسة لا يمنع عرض الدرس', () async {
      auth.user = const Left(CacheFailure('x'));
      final cubit = build();

      await cubit.load('3');

      expect(cubit.state, const LessonState(status: LessonStatus.success, details: _lessonDetails));
    });

    test('التعليق يُرسل بنص الطالب، ثم يُجلب الدرس بتعليقاته', () async {
      const withComment = LessonDetails(
        lesson: _lesson,
        semester: Semester(
          id: '2',
          name: 'السيدة بتول الترابين',
          isFree: true,
          price: 71,
          lessonsCount: 1,
          isSubscribed: false,
          lessons: [_lesson],
        ),
        comments: [Comment(id: '1', text: 'شرح ممتاز', authorId: '30', authorName: 'Rashed eybo')],
      );
      final results = <Either<Failure, LessonDetails>>[const Right(_lessonDetails), const Right(withComment)];
      repository.lesson = (_) async => results.removeAt(0);
      final cubit = build();
      await cubit.load('3');

      final states = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<LessonState>().having((s) => s.commentStatus, 'commentStatus', CommentStatus.sending),
          isA<LessonState>()
              .having((s) => s.commentStatus, 'commentStatus', CommentStatus.done)
              .having((s) => s.details, 'details', withComment),
        ]),
      );
      await cubit.sendComment('شرح ممتاز');
      await states;
      expect(repository.comments, [const NewComment(lessonId: '3', text: 'شرح ممتاز')]);
    });

    test('فشل التعليق يصل برسالته ولا يُعاد جلب الدرس', () async {
      repository.comment = (_) async => const Left(ValidationFailure('اكتب تعليقك أولاً'));
      var loads = 0;
      repository.lesson = (_) async {
        loads++;
        return const Right(_lessonDetails);
      };
      final cubit = build();
      await cubit.load('3');

      await cubit.sendComment('');

      expect(cubit.state.commentStatus, CommentStatus.failure);
      expect(cubit.state.commentError, 'اكتب تعليقك أولاً');
      expect(loads, 1);
    });

    test('الفشل يصل برسالته', () async {
      repository.lesson = (_) async => const Left(ServerFailure('المحتوى المطلوب غير موجود'));
      final cubit = build();

      await cubit.load('999');

      expect(
        cubit.state,
        const LessonState(status: LessonStatus.failure, error: 'المحتوى المطلوب غير موجود', user: _me),
      );
    });

    test('الحضور يُرسل مرة واحدة مهما تكرر الفتح', () async {
      final cubit = build();
      await cubit.load('3');

      await Future.wait([cubit.attend(), cubit.attend()]);
      await cubit.attend();

      expect(repository.attended, ['3']);
      expect(cubit.state.attendStatus, AttendStatus.done);
    });

    test('درس محضور من قبل لا يُرسل حضوره', () async {
      repository.lesson = (_) async => const Right(
            LessonDetails(
              lesson: Lesson(
                id: '3',
                title: 'رسلان الدين عباد',
                type: LessonType.video,
                order: 6,
                isFree: true,
                isSubscribed: false,
                isAttended: true,
              ),
              semester: Semester(
                id: '2',
                name: 'س',
                isFree: true,
                price: 0,
                lessonsCount: 0,
                isSubscribed: false,
                lessons: [],
              ),
            ),
          );
      final cubit = build();
      await cubit.load('3');

      await cubit.attend();

      expect(repository.attended, isEmpty);
    });

    test('فشل الحضور لا يغيّر حالة الصفحة، ويُعاد عند الفتح التالي', () async {
      final results = <Either<Failure, void>>[const Left(ServerFailure('x')), const Right(null)];
      repository.attend = (_) async => results.removeAt(0);
      final cubit = build();
      await cubit.load('3');

      await cubit.attend();
      expect(cubit.state.status, LessonStatus.success);
      expect(cubit.state.attendStatus, AttendStatus.failure);

      await cubit.attend();
      expect(cubit.state.attendStatus, AttendStatus.done);
      expect(repository.attended, ['3', '3']);
    });

    test('إغلاق الصفحة قبل وصول رد الحضور لا يرمي خطأ', () async {
      final response = Completer<Either<Failure, void>>();
      repository.attend = (_) => response.future;
      final cubit = build();
      await cubit.load('3');

      final attending = cubit.attend();
      await cubit.close();
      response.complete(const Right(null));

      await expectLater(attending, completes);
    });
  });
}
