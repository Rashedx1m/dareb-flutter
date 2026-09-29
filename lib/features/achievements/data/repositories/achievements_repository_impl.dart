import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievements_repository.dart';
import '../datasources/achievements_remote_data_source.dart';

class AchievementsRepositoryImpl implements AchievementsRepository {
  const AchievementsRepositoryImpl(this._remote);
  final AchievementsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Achievement>>> getAchievements() {
    return guard(_remote.getAchievements);
  }
}
