import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/points/domain/entities/point_record.dart';
import 'package:educational_app/features/points/domain/repositories/points_repository.dart';
import 'package:educational_app/features/points/domain/usecases/get_points_history.dart';
import 'package:educational_app/features/points/presentation/cubit/points_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _lesson = PointRecord(id: 'p1', points: 5, reason: 'مشاهدة درس');
const _exam = PointRecord(id: 'p2', points: 10);

/// مستودع مزيّف: كل طلب يُرجع ما تعيده [respond].
class _FakeRepository implements PointsRepository {
  _FakeRepository(this.respond);
  final Future<Either<Failure, List<PointRecord>>> Function() respond;

  @override
  Future<Either<Failure, List<PointRecord>>> getPointsHistory() => respond();
}

PointsCubit _cubit(Future<Either<Failure, List<PointRecord>>> Function() respond) =>
    PointsCubit(GetPointsHistory(_FakeRepository(respond)));

void main() {
  test('يبدأ initial، ثم loading، ثم success بالسجل', () async {
    final cubit = _cubit(() async => const Right([_lesson, _exam]));
    expect(cubit.state.status, PointsStatus.initial);

    final states = expectLater(
      cubit.stream,
      emitsInOrder([
        const PointsState(status: PointsStatus.loading),
        const PointsState(status: PointsStatus.success, items: [_lesson, _exam]),
      ]),
    );
    await cubit.load();
    await states;
  });

  test('سجل فارغ نجاح بقائمة فارغة، لا فشل', () async {
    final cubit = _cubit(() async => const Right([]));
    await cubit.load();

    expect(cubit.state, const PointsState(status: PointsStatus.success));
  });

  test('الفشل يصل برسالته', () async {
    final cubit = _cubit(() async => const Left(ServerFailure('تعذّر الاتصال')));
    await cubit.load();

    expect(cubit.state, const PointsState(status: PointsStatus.failure, error: 'تعذّر الاتصال'));
  });

  test('إغلاق الصفحة قبل وصول الرد لا يرمي خطأ', () async {
    final response = Completer<Either<Failure, List<PointRecord>>>();
    final cubit = _cubit(() => response.future);

    final loading = cubit.load();
    await cubit.close();
    response.complete(const Right([_lesson]));

    await expectLater(loading, completes);
  });

  test('total يجمع نقاط السجل', () {
    expect(const PointsState(items: [_lesson, _exam]).total, 15);
    expect(const PointsState().total, 0);
  });
}
