import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/domain/entities/lookup_option.dart';
import 'package:educational_app/features/auth/domain/repositories/registration_options_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_branches.dart';
import 'package:educational_app/features/auth/domain/usecases/get_governorates.dart';
import 'package:educational_app/features/auth/domain/usecases/get_schools.dart';
import 'package:educational_app/features/auth/presentation/cubit/registration_options_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _damascus = LookupOption(id: 'damascus', name: 'دمشق');
const _branch = LookupOption(id: '1', name: 'علمي');
const _school = LookupOption(id: '7', name: 'مدرسة يامن');

/// مستودع مزيّف: المدارس تنتظر [schoolsGate] إن ضُبط، لاختبار الردود المتأخرة.
class _FakeRepository implements RegistrationOptionsRepository {
  Failure? failure;
  Completer<void>? schoolsGate;
  final schoolQueries = <String?>[];

  @override
  Future<Either<Failure, List<LookupOption>>> getGovernorates() async =>
      failure != null ? Left(failure!) : const Right([_damascus]);

  @override
  Future<Either<Failure, List<LookupOption>>> getBranches() async => const Right([_branch]);

  @override
  Future<Either<Failure, List<LookupOption>>> getSchools({
    SchoolKind? kind,
    String? governorateId,
  }) async {
    schoolQueries.add(governorateId);
    final gate = schoolsGate;
    if (gate != null) await gate.future;
    return Right(governorateId == 'damascus' ? const [_school] : const []);
  }
}

RegistrationOptionsCubit _cubit(_FakeRepository repository) => RegistrationOptionsCubit(
      getGovernorates: GetGovernorates(repository),
      getSchools: GetSchools(repository),
      getBranches: GetBranches(repository),
    );

void main() {
  test('load يحمّل المحافظات والفروع معاً', () async {
    final cubit = _cubit(_FakeRepository());
    await cubit.load();

    expect(cubit.state.status, OptionsStatus.success);
    expect(cubit.state.governorates, [_damascus]);
    expect(cubit.state.branches, [_branch]);
  });

  test('فشل أيّ قائمة يضبط الحالة failure برسالته', () async {
    final cubit = _cubit(_FakeRepository()..failure = const ServerFailure('تعذر التحميل'));
    await cubit.load();

    expect(cubit.state.status, OptionsStatus.failure);
    expect(cubit.state.error, 'تعذر التحميل');
  });

  test('loadSchools يحمّل مدارس الاختيار', () async {
    final cubit = _cubit(_FakeRepository());
    await cubit.loadSchools(const SchoolsQuery(kind: SchoolKind.school, governorateId: 'damascus'));

    expect(cubit.state.schoolsStatus, OptionsStatus.success);
    expect(cubit.state.schools, [_school]);
  });

  test('ردّ متأخر لمحافظة سابقة لا يغطّي الاختيار الأحدث', () async {
    final damascusGate = Completer<void>();
    final repository = _FakeRepository()..schoolsGate = damascusGate;
    final cubit = _cubit(repository);

    // طلب دمشق يبقى معلّقاً، ثم يختار المستخدم حلب ويصل ردّها أولاً.
    final stale = cubit.loadSchools(const SchoolsQuery(governorateId: 'damascus'));
    repository.schoolsGate = null;
    await cubit.loadSchools(const SchoolsQuery(governorateId: 'aleppo'));

    damascusGate.complete();
    await stale;

    expect(repository.schoolQueries, ['damascus', 'aleppo']);
    expect(cubit.state.schoolsQuery?.governorateId, 'aleppo');
    expect(cubit.state.schools, isEmpty);
  });
}
