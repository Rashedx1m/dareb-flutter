import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/contact_message.dart';
import '../repositories/support_repository.dart';

class SendContactMessage implements UseCase<void, ContactMessage> {
  const SendContactMessage(this.repository);
  final SupportRepository repository;

  @override
  Future<Either<Failure, void>> call(ContactMessage params) {
    return repository.sendContactMessage(params);
  }
}
