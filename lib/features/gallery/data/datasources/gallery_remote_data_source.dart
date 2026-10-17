import '../../../../core/data/mock_catalog.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/gallery_album.dart';
import '../models/gallery_album_model.dart';

/// مصدر ألبومات المعرض. يرمي استثناءات [ApiClient] أو [ServerException] عند الفشل.
abstract class GalleryRemoteDataSource {
  Future<List<GalleryAlbumModel>> getAlbums();
  Future<GalleryAlbumModel> getAlbum(String id);
}

class GalleryRemoteDataSourceImpl implements GalleryRemoteDataSource {
  const GalleryRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  /// `galleries/all` بتوكن: قائمة الألبومات مع صورها. `galleries/details` يعيد 404.
  @override
  Future<List<GalleryAlbumModel>> getAlbums() {
    return _client.get(
      '/galleries/all',
      parse: (data) => [
        for (final json in (data as List).cast<Map<String, dynamic>>()) GalleryAlbumModel.fromJson(json),
      ],
    );
  }

  /// الخادم لا يفصل ألبوماً بمعرّف، فنأخذ القائمة ونبحث فيها.
  @override
  Future<GalleryAlbumModel> getAlbum(String id) async {
    final albums = await getAlbums();
    for (final album in albums) {
      if (album.id == id) return album;
    }
    throw const ServerException('الألبوم غير موجود');
  }
}

/// تنفيذ تجريبي من [MockCatalog]، يُستبدل بتنفيذ الـ API في حقن الاعتماديات فقط.
class GalleryMockDataSource implements GalleryRemoteDataSource {
  const GalleryMockDataSource();

  @override
  Future<List<GalleryAlbumModel>> getAlbums() async {
    await Future<void>.delayed(MockCatalog.latency);
    return [for (final album in MockCatalog.galleryAlbums) _model(album)];
  }

  @override
  Future<GalleryAlbumModel> getAlbum(String id) async {
    await Future<void>.delayed(MockCatalog.latency);
    for (final album in MockCatalog.galleryAlbums) {
      if (album.id == id) return _model(album);
    }
    throw const ServerException('الألبوم غير موجود');
  }

  static GalleryAlbumModel _model(GalleryAlbum album) {
    return GalleryAlbumModel(
      id: album.id,
      title: album.title,
      cover: album.cover,
      photos: album.photos,
    );
  }
}
