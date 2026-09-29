import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/lookup_option.dart';

/// القوائم التي يختار منها المستخدم عند إكمال حسابه.
abstract class RegistrationOptionsRepository {
  Future<Either<Failure, List<LookupOption>>> getGovernorates();

  /// المدارس، مصفّاة بالنوع و/أو المحافظة إن حُدّدا.
  Future<Either<Failure, List<LookupOption>>> getSchools({
    SchoolKind? kind,
    String? governorateId,
  });

  Future<Either<Failure, List<LookupOption>>> getBranches();
}
