import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lookup_option.dart';
import '../repositories/registration_options_repository.dart';

class GetBranches implements UseCase<List<LookupOption>, NoParams> {
  const GetBranches(this.repository);
  final RegistrationOptionsRepository repository;

  @override
  Future<Either<Failure, List<LookupOption>>> call(NoParams params) {
    return repository.getBranches();
  }
}
