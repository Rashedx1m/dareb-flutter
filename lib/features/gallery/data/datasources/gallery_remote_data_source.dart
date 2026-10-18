import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
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
