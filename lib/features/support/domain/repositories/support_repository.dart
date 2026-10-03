import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/contact_links.dart';
import '../entities/contact_message.dart';

abstract class SupportRepository {
  Future<Either<Failure, void>> sendContactMessage(ContactMessage message);

  Future<Either<Failure, ContactLinks>> getContactLinks();
}
