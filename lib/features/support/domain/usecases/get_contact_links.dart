import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/contact_links.dart';
import '../repositories/support_repository.dart';

class GetContactLinks implements UseCase<ContactLinks, NoParams> {
  const GetContactLinks(this.repository);
  final SupportRepository repository;

  @override
  Future<Either<Failure, ContactLinks>> call(NoParams params) {
    return repository.getContactLinks();
  }
}
