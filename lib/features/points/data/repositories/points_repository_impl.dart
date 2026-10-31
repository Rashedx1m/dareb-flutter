import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/point_record.dart';
import '../../domain/repositories/points_repository.dart';
import '../datasources/points_remote_data_source.dart';

class PointsRepositoryImpl implements PointsRepository {
  const PointsRepositoryImpl(this._remote);
  final PointsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<PointRecord>>> getPointsHistory() {
    return guard(_remote.getPointsHistory);
  }
}
