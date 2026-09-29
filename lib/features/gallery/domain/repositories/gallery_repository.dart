import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/gallery_album.dart';

abstract class GalleryRepository {
  Future<Either<Failure, List<GalleryAlbum>>> getAlbums();
  Future<Either<Failure, GalleryAlbum>> getAlbum(String id);
}
