import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/news_item.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<NewsItem>>> getNews();
}
