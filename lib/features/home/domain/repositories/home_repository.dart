import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/home_feed.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeFeed>> getHome();
}
