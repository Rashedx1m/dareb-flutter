import '../../domain/entities/gallery_album.dart';

/// ألبوم كما يعيده `galleries/all` في 2026-10-16: `{id, name, images}`.
/// `images` مصفوفة روابط كاملة. لا مسار `galleries/details`.
class GalleryAlbumModel extends GalleryAlbum {
  const GalleryAlbumModel({
    required super.id,
    required super.title,
    required super.cover,
    required super.photos,
  });

  factory GalleryAlbumModel.fromJson(Map<String, dynamic> json) {
    final photos = (json['images'] as List).cast<String>();
    return GalleryAlbumModel(
      id: '${json['id']}',
      title: json['name'] as String,
      cover: photos.isEmpty ? '' : photos.first,
      photos: photos,
    );
  }
}
