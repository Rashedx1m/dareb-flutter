import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/lookup_option.dart';
import '../../domain/repositories/registration_options_repository.dart';
import '../datasources/registration_options_remote_data_source.dart';

class RegistrationOptionsRepositoryImpl implements RegistrationOptionsRepository {
  const RegistrationOptionsRepositoryImpl(this._remote);
  final RegistrationOptionsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<LookupOption>>> getGovernorates() => guard(_remote.getGovernorates);

  @override
  Future<Either<Failure, List<LookupOption>>> getSchools({
    SchoolKind? kind,
    String? governorateId,
  }) {
    return guard(() => _remote.getSchools(kind: kind, governorateId: governorateId));
  }

  @override
  Future<Either<Failure, List<LookupOption>>> getBranches() => guard(_remote.getBranches);
}
