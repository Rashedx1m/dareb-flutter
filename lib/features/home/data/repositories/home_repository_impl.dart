import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._remote);
  final HomeRemoteDataSource _remote;

  @override
  Future<Either<Failure, HomeFeed>> getHome() => guard(_remote.getHome);
}
