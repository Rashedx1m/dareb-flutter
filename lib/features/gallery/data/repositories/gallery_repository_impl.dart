import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/gallery_album.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../datasources/gallery_remote_data_source.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  const GalleryRepositoryImpl(this._remote);
  final GalleryRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<GalleryAlbum>>> getAlbums() {
    return guard(_remote.getAlbums);
  }

  @override
  Future<Either<Failure, GalleryAlbum>> getAlbum(String id) {
    return guard(() => _remote.getAlbum(id));
  }
}
