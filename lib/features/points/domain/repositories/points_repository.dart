import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/point_record.dart';

abstract class PointsRepository {
  Future<Either<Failure, List<PointRecord>>> getPointsHistory();
}
