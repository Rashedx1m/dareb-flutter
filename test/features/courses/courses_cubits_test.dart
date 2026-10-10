import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/get_subjects.dart';
import 'package:educational_app/features/courses/presentation/cubit/subjects_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _subject = Subject(id: '2', name: 'سارين الطراونة', imageUrl: 'x', isFree: true, isSubscribed: false);

/// مستودع مزيّف: كل دالة تُرجع ما يعيده الرد المضبوط لها.
class _FakeRepository extends Fake implements CoursesRepository {
  Future<Either<Failure, List<Subject>>> Function() subjects = () async => const Right([_subject]);

  @override
  Future<Either<Failure, List<Subject>>> getSubjects() => subjects();
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
}
