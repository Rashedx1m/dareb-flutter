import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/gallery_album.dart';
import '../repositories/gallery_repository.dart';

class GetAlbums implements UseCase<List<GalleryAlbum>, NoParams> {
  const GetAlbums(this.repository);
  final GalleryRepository repository;

  @override
  Future<Either<Failure, List<GalleryAlbum>>> call(NoParams params) {
    return repository.getAlbums();
  }
}
