import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/downloaded_file.dart';

abstract class DownloadsRepository {
  Future<Either<Failure, List<DownloadedFile>>> getDownloads();
}
