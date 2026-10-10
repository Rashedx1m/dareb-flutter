import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:educational_app/features/auth/domain/usecases/refresh_profile.dart';
import 'package:educational_app/features/courses/domain/entities/course.dart';
import 'package:educational_app/features/courses/domain/entities/course_details.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/get_courses.dart';
import 'package:educational_app/features/courses/domain/usecases/get_subjects.dart';
import 'package:educational_app/features/home/domain/entities/news_item.dart';
import 'package:educational_app/features/home/domain/repositories/news_repository.dart';
import 'package:educational_app/features/home/domain/usecases/get_news.dart';
import 'package:educational_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = User(id: 'u1', name: 'أحمد', phone: '0501234567', progress: 0.4, points: 55);

const _news = [NewsItem(id: 'nw1', title: 'خبر', imageUrl: 'x', date: 'اليوم')];

const _courses = [
  Course(
    id: '1',
    title: 'الدكتور هناء القطيشات',
    subjectName: 'ناردين الشطناوي',
    instructor: 'أكرم أبو الرب',
    description: '',
    imageUrl: 'x',
    price: 36,
    semestersCount: 3,
    lessonsCount: 6,
    subscriptionsCount: 3,
    isFree: false,
    isSubscribed: false,
  ),
];

const _subjects = [
  Subject(id: '1', name: 'الرياضيات', imageUrl: 'x', isFree: false, isSubscribed: false),
  Subject(id: '2', name: 'العلوم', imageUrl: 'y', isFree: true, isSubscribed: false),
];

/// مستودع مزيّف يتيح ضبط الفشل لاختبار مسارات النجاح والخطأ.
class _FakeCoursesRepository implements CoursesRepository {
  _FakeCoursesRepository({this.failure});

  final Failure? failure;

  @override
  Future<Either<Failure, List<Course>>> getCourses() async =>
      failure != null ? Left(failure!) : const Right(_courses);

  @override
  Future<Either<Failure, List<Subject>>> getSubjects() async =>
      failure != null ? Left(failure!) : const Right(_subjects);

  @override
  Future<Either<Failure, List<Course>>> getMyCourses() async => const Right(_courses);

  @override
  Future<Either<Failure, CourseDetails>> getCourseDetails(String subjectId) async =>
      Right(CourseDetails(course: _courses.first, semesters: const []));

  @override
  Future<Either<Failure, List<Course>>> searchCourses(String query) async => const Right(_courses);
}

class _FakeNewsRepository implements NewsRepository {
  _FakeNewsRepository({this.failure});

  final Failure? failure;

  @override
  Future<Either<Failure, List<NewsItem>>> getNews() async =>
      failure != null ? Left(failure!) : const Right(_news);
}

/// الصفحة الرئيسية تحتاج من مستودع المصادقة المستخدم المحفوظ ونسخته من الخادم.
/// بلا [fresh] يفشل التحديث، فتُعرض النسخة المحفوظة.
class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository(this.user, {this.fresh});

  final User? user;
  final User? fresh;

  @override
  Future<Either<Failure, User?>> currentUser() async => Right(user);

  @override
  Future<Either<Failure, User>> refreshProfile() async =>
      fresh == null ? const Left(ServerFailure()) : Right(fresh!);
}

HomeCubit _cubit(
  _FakeCoursesRepository repository, {
  _FakeNewsRepository? news,
  User? user = _user,
  User? fresh,
}) {
  final auth = _FakeAuthRepository(user, fresh: fresh);
  return HomeCubit(
    getCourses: GetCourses(repository),
    getSubjects: GetSubjects(repository),
    getNews: GetNews(news ?? _FakeNewsRepository()),
    getCurrentUser: GetCurrentUser(auth),
    refreshProfile: RefreshProfile(auth),
  );
}

void main() {
  test('load ينجح ويملأ الدورات والمواد والأخبار', () async {
    final cubit = _cubit(_FakeCoursesRepository());
    await cubit.load();

    expect(cubit.state.status, HomeStatus.success);
    expect(cubit.state.courses, _courses);
    expect(cubit.state.subjects, _subjects);
    expect(cubit.state.news, _news);
  });

  test('load يعرض المستخدم المحدّث من الخادم', () async {
    const fresh = User(id: 'u1', name: 'أحمد', phone: '0501234567', points: 120);
    final cubit = _cubit(_FakeCoursesRepository(), fresh: fresh);
    await cubit.load();

    expect(cubit.state.user, fresh);
    expect(cubit.state.points, 120);
  });

  test('تعذّر التحديث: الاسم والنقاط والإنجاز من النسخة المحفوظة', () async {
    final cubit = _cubit(_FakeCoursesRepository());
    await cubit.load();

    expect(cubit.state.user, _user);
    expect(cubit.state.points, 55);
    expect(cubit.state.progress, 0.4);
  });

  test('غياب الجلسة لا يُفشل الصفحة', () async {
    final cubit = _cubit(_FakeCoursesRepository(), user: null);
    await cubit.load();

    expect(cubit.state.status, HomeStatus.success);
    expect(cubit.state.points, 0);
  });

  test('فشل الأخبار يضبط الحالة failure', () async {
    final cubit = _cubit(
      _FakeCoursesRepository(),
      news: _FakeNewsRepository(failure: const ServerFailure('تعذر جلب الأخبار')),
    );
    await cubit.load();

    expect(cubit.state.status, HomeStatus.failure);
    expect(cubit.state.error, 'تعذر جلب الأخبار');
  });

  test('load يعدّ دورات المنهاج من قائمة الدورات', () async {
    final cubit = _cubit(_FakeCoursesRepository());
    await cubit.load();

    expect(cubit.state.curriculumCoursesCount, _courses.length);
  });

  test('load عند الفشل يضبط الحالة failure ويحمل الرسالة', () async {
    final cubit = _cubit(_FakeCoursesRepository(failure: const ServerFailure('خطأ في الخادم')));
    await cubit.load();

    expect(cubit.state.status, HomeStatus.failure);
    expect(cubit.state.error, 'خطأ في الخادم');
  });
}
