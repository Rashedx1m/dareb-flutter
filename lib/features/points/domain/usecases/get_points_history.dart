import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/point_record.dart';
import '../repositories/points_repository.dart';

class GetPointsHistory implements UseCase<List<PointRecord>, NoParams> {
  const GetPointsHistory(this.repository);
  final PointsRepository repository;

  @override
  Future<Either<Failure, List<PointRecord>>> call(NoParams params) {
    return repository.getPointsHistory();
  }
}