import 'package:educational_app/features/gallery/data/datasources/gallery_remote_data_source.dart';
import 'package:educational_app/features/gallery/data/repositories/gallery_repository_impl.dart';
import 'package:educational_app/features/gallery/domain/usecases/get_album.dart';
import 'package:educational_app/features/gallery/domain/usecases/get_albums.dart';
import 'package:educational_app/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// يمرّ عبر الطبقات الحقيقية كلها (المصدر التجريبي ← المستودع ← الـ UseCase ← الـ Cubit).
GalleryCubit _cubit() {
  const repository = GalleryRepositoryImpl(GalleryMockDataSource());
  return GalleryCubit(
    getAlbums: const GetAlbums(repository),
    getAlbum: const GetAlbum(repository),
  );
}

void main() {
  test('loadAlbums يحمّل كل الألبومات', () async {
    final cubit = _cubit();
    await cubit.loadAlbums();

    expect(cubit.state.status, GalleryStatus.success);
    expect(cubit.state.albums, isNotEmpty);
  });

  test('loadAlbum يحمّل الألبوم المطلوب', () async {
    final cubit = _cubit();
    await cubit.loadAlbum('gal_math');

    expect(cubit.state.status, GalleryStatus.success);
    expect(cubit.state.album?.id, 'gal_math');
  });

  test('ألبوم غير موجود يصل للواجهة كـ failure برسالة عربية', () async {
    final cubit = _cubit();
    await cubit.loadAlbum('missing');

    expect(cubit.state.status, GalleryStatus.failure);
    expect(cubit.state.error, 'الألبوم غير موجود');
  });
}
