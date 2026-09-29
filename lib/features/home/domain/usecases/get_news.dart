import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/news_item.dart';
import '../repositories/news_repository.dart';

class GetNews implements UseCase<List<NewsItem>, NoParams> {
  const GetNews(this.repository);
  final NewsRepository repository;

  @override
  Future<Either<Failure, List<NewsItem>>> call(NoParams params) {
    return repository.getNews();
  }
}
