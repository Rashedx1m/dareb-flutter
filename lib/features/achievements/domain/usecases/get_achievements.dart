import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/achievement.dart';
import '../repositories/achievements_repository.dart';

class GetAchievements implements UseCase<List<Achievement>, NoParams> {
  const GetAchievements(this.repository);
  final AchievementsRepository repository;

  @override
  Future<Either<Failure, List<Achievement>>> call(NoParams params) {
    return repository.getAchievements();
  }
}
