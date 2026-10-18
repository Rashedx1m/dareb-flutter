import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/gallery/domain/entities/gallery_album.dart';
import 'package:educational_app/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:educational_app/features/gallery/domain/usecases/get_album.dart';
import 'package:educational_app/features/gallery/domain/usecases/get_albums.dart';
import 'package:educational_app/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _album = GalleryAlbum(id: '14', title: 'Tamkeen', cover: 'https://x/1.jpg', photos: ['https://x/1.jpg']);

/// مستودع مزيّف يبحث في قائمة ثابتة كما يفعل المصدر الحقيقي بـ `galleries/all`.
class _FakeRepository implements GalleryRepository {
  @override
  Future<Either<Failure, List<GalleryAlbum>>> getAlbums() async => const Right([_album]);

  @override
  Future<Either<Failure, GalleryAlbum>> getAlbum(String id) async =>
      id == _album.id ? const Right(_album) : const Left(ServerFailure('الألبوم غير موجود'));
}

GalleryCubit _cubit() {
  final repository = _FakeRepository();
  return GalleryCubit(getAlbums: GetAlbums(repository), getAlbum: GetAlbum(repository));
}

void main() {
  test('loadAlbums يحمّل كل الألبومات', () async {
    final cubit = _cubit();
    await cubit.loadAlbums();

    expect(cubit.state.status, GalleryStatus.success);
    expect(cubit.state.albums, [_album]);
  });

  test('loadAlbum يحمّل الألبوم المطلوب', () async {
    final cubit = _cubit();
    await cubit.loadAlbum('14');

    expect(cubit.state.status, GalleryStatus.success);
    expect(cubit.state.album, _album);
  });

  test('ألبوم غير موجود يصل للواجهة كـ failure برسالة عربية', () async {
    final cubit = _cubit();
    await cubit.loadAlbum('missing');

    expect(cubit.state.status, GalleryStatus.failure);
    expect(cubit.state.error, 'الألبوم غير موجود');
  });
}
