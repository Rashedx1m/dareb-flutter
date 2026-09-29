import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lookup_option.dart';
import '../repositories/registration_options_repository.dart';

class GetGovernorates implements UseCase<List<LookupOption>, NoParams> {
  const GetGovernorates(this.repository);
  final RegistrationOptionsRepository repository;

  @override
  Future<Either<Failure, List<LookupOption>>> call(NoParams params) {
    return repository.getGovernorates();
  }
}

class GetSchools implements UseCase<List<LookupOption>, SchoolsQuery> {
  const GetSchools(this.repository);
  final RegistrationOptionsRepository repository;

  @override
  Future<Either<Failure, List<LookupOption>>> call(SchoolsQuery params) {
    return repository.getSchools(kind: params.kind, governorateId: params.governorateId);
  }
}

class GetBranches implements UseCase<List<LookupOption>, NoParams> {
  const GetBranches(this.repository);
  final RegistrationOptionsRepository repository;

  @override
  Future<Either<Failure, List<LookupOption>>> call(NoParams params) {
    return repository.getBranches();
  }
}

/// مرشّحات قائمة المدارس؛ الحقل الفارغ يعني «الكل».
class SchoolsQuery extends Equatable {
  const SchoolsQuery({this.kind, this.governorateId});

  final SchoolKind? kind;
  final String? governorateId;

  @override
  List<Object?> get props => [kind, governorateId];
}
