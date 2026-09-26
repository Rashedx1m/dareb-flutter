import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/courses/domain/entities/course.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/get_courses.dart';
import 'package:educational_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _courses = [
  Course(
    id: 'c1',
    title: 'دورة الرياضيات',
    instructor: 'أ. عمر النابلسي',
    imageUrl: 'x',
    categoryId: 'math',
    categoryName: 'الرياضيات',
    lessonsCount: 12,
    chaptersCount: 9,
    studentsCount: 22,
    rating: 4.8,
    price: 120,
    progress: 0.4,
    description: '',
    lessons: [],
  ),
];

const _categories = [
  Category(id: 'math', name: 'الرياضيات', icon: 'math', coursesCount: 6),
  Category(id: 'science', name: 'العلوم', icon: 'science', coursesCount: 5),
];

/// مستودع مزيّف يتيح ضبط الفشل لاختبار مسارات النجاح والخطأ.
class _FakeCoursesRepository implements CoursesRepository {
  _FakeCoursesRepository({this.failure});

  final Failure? failure;

  @override
  Future<Either<Failure, List<Course>>> getCourses() async =>
      failure != null ? Left(failure!) : const Right(_courses);

  @override
  Future<Either<Failure, List<Category>>> getCategories() async =>
      failure != null ? Left(failure!) : const Right(_categories);

  @override
  Future<Either<Failure, List<Course>>> getMyCourses() async => const Right(_courses);

  @override
  Future<Either<Failure, Course>> getCourse(String id) async => Right(_courses.first);

  @override
  Future<Either<Failure, List<Course>>> searchCourses(String query) async => const Right(_courses);
}

HomeCubit _cubit(_FakeCoursesRepository repository) {
  return HomeCubit(
    getCourses: GetCourses(repository),
    getCategories: GetCategories(repository),
  );
}

void main() {
  test('load ينجح ويملأ الدورات والمواد والأخبار', () async {
    final cubit = _cubit(_FakeCoursesRepository());
    await cubit.load();

    expect(cubit.state.status, HomeStatus.success);
    expect(cubit.state.courses, _courses);
    expect(cubit.state.categories, _categories);
    expect(cubit.state.news, isNotEmpty);
  });

  test('load يحسب إجمالي دورات المنهاج من مجموع المواد', () async {
    final cubit = _cubit(_FakeCoursesRepository());
    await cubit.load();

    // 6 + 5 = 11
    expect(cubit.state.curriculumCoursesCount, 11);
  });

  test('load عند الفشل يضبط الحالة failure ويحمل الرسالة', () async {
    final cubit = _cubit(_FakeCoursesRepository(failure: const ServerFailure('خطأ في الخادم')));
    await cubit.load();

    expect(cubit.state.status, HomeStatus.failure);
    expect(cubit.state.error, 'خطأ في الخادم');
  });
}
