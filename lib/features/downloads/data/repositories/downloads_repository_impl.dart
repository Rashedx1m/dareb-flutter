import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/downloaded_file.dart';
import '../../domain/repositories/downloads_repository.dart';
import '../datasources/downloads_local_data_source.dart';

class DownloadsRepositoryImpl implements DownloadsRepository {
  const DownloadsRepositoryImpl(this._local);
  final DownloadsLocalDataSource _local;

  @override
  Future<Either<Failure, List<DownloadedFile>>> getDownloads() => guard(_local.getDownloads);
}
