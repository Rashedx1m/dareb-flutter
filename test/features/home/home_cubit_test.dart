import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:educational_app/features/auth/domain/usecases/refresh_profile.dart';
import 'package:educational_app/features/courses/domain/entities/course.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:educational_app/features/home/domain/entities/home_banner.dart';
import 'package:educational_app/features/home/domain/entities/home_feed.dart';
import 'package:educational_app/features/home/domain/entities/news_item.dart';
import 'package:educational_app/features/home/domain/repositories/home_repository.dart';
import 'package:educational_app/features/home/domain/usecases/get_home.dart';
import 'package:educational_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = User(id: 'u1', name: 'أحمد', phone: '0501234567', progress: 0.4, points: 55);

const _news = [NewsItem(id: 'nw1', imageUrl: 'x', link: 'https://example.com')];

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
    semesterRate: 0,
    lessonsCount: 6,
    lessonRate: 0,
    subscriptionsCount: 3,
    isFree: false,
    isSubscribed: false,
  ),
];

const _subjects = [
  Subject(id: '1', name: 'الرياضيات', imageUrl: 'x', isFree: false, isSubscribed: false),
  Subject(id: '2', name: 'العلوم', imageUrl: 'y', isFree: true, isSubscribed: false),
];

const _feed = HomeFeed(
  sliders: [HomeBanner(id: '1', imageUrl: 's', link: 'https://example.com')],
  subjects: _subjects,
  news: _news,
  courses: _courses,
  completionRate: 0.4,
  subjectCount: 22,
);

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository({this.failure});

  final Failure? failure;

  @override
  Future<Either<Failure, HomeFeed>> getHome() async =>
      failure != null ? Left(failure!) : const Right(_feed);
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

HomeCubit _cubit({
  Failure? homeFailure,
  User? user = _user,
  User? fresh,
}) {
  final auth = _FakeAuthRepository(user, fresh: fresh);
  return HomeCubit(
    getHome: GetHome(_FakeHomeRepository(failure: homeFailure)),
    getCurrentUser: GetCurrentUser(auth),
    refreshProfile: RefreshProfile(auth),
  );
}

void main() {
  test('load ينجح ويملأ الدورات والمواد والأخبار والسلايدر', () async {
    final cubit = _cubit();
    await cubit.load();

    expect(cubit.state.status, HomeStatus.success);
    expect(cubit.state.courses, _courses);
    expect(cubit.state.subjects, _subjects);
    expect(cubit.state.news, _news);
    expect(cubit.state.sliders, _feed.sliders);
    expect(cubit.state.progress, 0.4);
  });

  test('load يعرض المستخدم المحدّث من الخادم', () async {
    const fresh = User(id: 'u1', name: 'أحمد', phone: '0501234567', points: 120);
    final cubit = _cubit(fresh: fresh);
    await cubit.load();

    expect(cubit.state.user, fresh);
    expect(cubit.state.points, 120);
  });

  test('تعذّر التحديث: الاسم والنقاط من النسخة المحفوظة', () async {
    final cubit = _cubit();
    await cubit.load();

    expect(cubit.state.user, _user);
    expect(cubit.state.points, 55);
  });

  test('غياب الجلسة لا يُفشل الصفحة', () async {
    final cubit = _cubit(user: null);
    await cubit.load();

    expect(cubit.state.status, HomeStatus.success);
    expect(cubit.state.points, 0);
  });

  test('فشل الرئيسية يضبط الحالة failure', () async {
    final cubit = _cubit(homeFailure: const ServerFailure('تعذر جلب الصفحة'));
    await cubit.load();

    expect(cubit.state.status, HomeStatus.failure);
    expect(cubit.state.error, 'تعذر جلب الصفحة');
  });

  test('load يعدّ مواد المنهاج من subject_count', () async {
    final cubit = _cubit();
    await cubit.load();

    expect(cubit.state.curriculumCoursesCount, 22);
  });
}
