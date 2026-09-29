import '../../../../core/data/mock_catalog.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/gallery_album.dart';

/// مصدر ألبومات المعرض. يرمي [ServerException] عند الفشل.
abstract class GalleryRemoteDataSource {
  Future<List<GalleryAlbum>> getAlbums();
  Future<GalleryAlbum> getAlbum(String id);
}

/// تنفيذ تجريبي من [MockCatalog]، يُستبدل بتنفيذ الـ API في حقن الاعتماديات فقط.
class GalleryMockDataSource implements GalleryRemoteDataSource {
  const GalleryMockDataSource();

  @override
  Future<List<GalleryAlbum>> getAlbums() async {
    await Future<void>.delayed(MockCatalog.latency);
    return MockCatalog.galleryAlbums;
  }

  @override
  Future<GalleryAlbum> getAlbum(String id) async {
    await Future<void>.delayed(MockCatalog.latency);
    for (final album in MockCatalog.galleryAlbums) {
      if (album.id == id) return album;
    }
    throw const ServerException('الألبوم غير موجود');
  }
}
