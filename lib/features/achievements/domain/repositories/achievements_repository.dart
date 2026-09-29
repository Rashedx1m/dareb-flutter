import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/achievement.dart';

abstract class AchievementsRepository {
  Future<Either<Failure, List<Achievement>>> getAchievements();
}
