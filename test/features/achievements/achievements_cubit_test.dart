import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/achievements/presentation/cubit/achievements_cubit.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:educational_app/features/auth/domain/usecases/refresh_profile.dart';
import 'package:educational_app/features/courses/domain/entities/course.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/get_my_courses.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = User(
  id: '30',
  name: 'راشد عيبو',
  phone: '0937857596',
  points: 22,
  enrolledCoursesCount: 1,
  semestersCount: 3,
  medalsCount: 0,
);

const _course = Course(
  id: '1',
  title: 'دورة الرياضيات',
  subjectName: 'الرياضيات',
  instructor: 'أ.عمر النابلسي',
  description: '',
  imageUrl: 'x',
  price: 0,
  semestersCount: 9,
  semesterRate: 40,
  lessonsCount: 30,
  lessonRate: 20,
  subscriptionsCount: 1,
  isFree: true,
  isSubscribed: true,
  subjectRate: 20,
  pointsCount: 600,
  pointRate: 40,
);

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

class _FakeCoursesRepository extends Fake implements CoursesRepository {
  _FakeCoursesRepository([this.result = const Right([_course])]);

  final Either<Failure, List<Course>> result;

  @override
  Future<Either<Failure, List<Course>>> getMyCourses() async => result;
}

AchievementsCubit _cubit({
  User? cached = _user,
  User? fresh = _user,
  Either<Failure, List<Course>> courses = const Right([_course]),
}) {
  return AchievementsCubit(
    getCurrentUser: GetCurrentUser(_FakeAuthRepository(cached, fresh: fresh)),
    refreshProfile: RefreshProfile(_FakeAuthRepository(cached, fresh: fresh)),
    getMyCourses: GetMyCourses(_FakeCoursesRepository(courses)),
  );
}

void main() {
  test('يحمّل الملف ومواد الاشتراك', () async {
    final cubit = _cubit();
    await cubit.load();

    expect(cubit.state.status, AchievementsStatus.success);
    expect(cubit.state.user?.name, 'راشد عيبو');
    expect(cubit.state.courses.single.subjectName, 'الرياضيات');
    expect(cubit.state.lessonsCount, 30);
  });

  test('فشل المواد يصل برسالته', () async {
    final cubit = _cubit(courses: const Left(ServerFailure('تعذر جلب المواد')));
    await cubit.load();

    expect(
      cubit.state,
      const AchievementsState(status: AchievementsStatus.failure, error: 'تعذر جلب المواد'),
    );
  });

  test('فشل تحديث الملف يُبقي النسخة المحفوظة إن نجحت المواد', () async {
    final cubit = _cubit(fresh: null);
    await cubit.load();

    expect(cubit.state.status, AchievementsStatus.success);
    expect(cubit.state.user, _user);
  });
}
