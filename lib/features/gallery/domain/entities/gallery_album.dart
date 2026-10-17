import 'package:equatable/equatable.dart';

/// ألبوم من `galleries/all`: `{id, name, images}`.
class GalleryAlbum extends Equatable {
  const GalleryAlbum({
    required this.id,
    required this.title,
    required this.cover,
    required this.photos,
  });

  final String id;
  final String title;

  /// أول صورة، أو فارغ إن لم يرسل الخادم صوراً.
  final String cover;
  final List<String> photos;

  int get count => photos.length;

  @override
  List<Object?> get props => [id, title, cover, photos];
}
