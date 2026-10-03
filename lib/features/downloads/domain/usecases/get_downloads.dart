import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/downloaded_file.dart';
import '../repositories/downloads_repository.dart';

class GetDownloads implements UseCase<List<DownloadedFile>, NoParams> {
  const GetDownloads(this.repository);
  final DownloadsRepository repository;

  @override
  Future<Either<Failure, List<DownloadedFile>>> call(NoParams params) {
    return repository.getDownloads();
  }
}
