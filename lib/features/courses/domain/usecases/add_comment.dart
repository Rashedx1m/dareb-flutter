import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/comment.dart';
import '../repositories/courses_repository.dart';

/// يضيف تعليق الطالب إلى «النقاشات» تحت الدرس.
class AddComment implements UseCase<void, NewComment> {
  const AddComment(this.repository);
  final CoursesRepository repository;

  @override
  Future<Either<Failure, void>> call(NewComment comment) {
    return repository.addComment(comment);
  }
}
