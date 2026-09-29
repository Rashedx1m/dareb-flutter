import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl(this._remote);
  final NewsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<NewsItem>>> getNews() {
    return guard(_remote.getNews);
  }
}
