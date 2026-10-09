import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/gallery_album.dart';
import '../repositories/gallery_repository.dart';

class GetAlbum implements UseCase<GalleryAlbum, String> {
  const GetAlbum(this.repository);
  final GalleryRepository repository;

  @override
  Future<Either<Failure, GalleryAlbum>> call(String params) {
    return repository.getAlbum(params);
  }
}
