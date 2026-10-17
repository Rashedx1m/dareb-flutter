import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/home_feed.dart';
import '../repositories/home_repository.dart';

class GetHome implements UseCase<HomeFeed, NoParams> {
  const GetHome(this.repository);
  final HomeRepository repository;

  @override
  Future<Either<Failure, HomeFeed>> call(NoParams params) {
    return repository.getHome();
  }
}
