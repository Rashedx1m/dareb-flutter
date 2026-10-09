import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/contact_links.dart';
import '../../domain/entities/contact_message.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_data_source.dart';

class SupportRepositoryImpl implements SupportRepository {
  const SupportRepositoryImpl(this._remote);
  final SupportRemoteDataSource _remote;

  @override
  Future<Either<Failure, void>> sendContactMessage(ContactMessage message) async {
    final error = Validators.notEmpty(message.firstName) ??
        Validators.notEmpty(message.lastName) ??
        Validators.phone(message.phone) ??
        Validators.notEmpty(message.text);
    if (error != null) return Left(ValidationFailure(error));

    return guard(
      () => _remote.sendContactMessage(
        ContactMessage(
          firstName: message.firstName.trim(),
          lastName: message.lastName.trim(),
          phone: Validators.normalizedPhone(message.phone),
          text: message.text.trim(),
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, ContactLinks>> getContactLinks() => guard(_remote.getContactLinks);
}
