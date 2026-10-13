import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/search_results.dart';
import '../repositories/courses_repository.dart';

/// يبحث في المواد والاختبارات والنشاطات اليومية. نص فارغ يعطي نتائج فارغة دون طلب.
class SearchContent implements UseCase<SearchResults, String> {
  const SearchContent(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, SearchResults>> call(String query) {
    return repository.search(query);
  }
}
