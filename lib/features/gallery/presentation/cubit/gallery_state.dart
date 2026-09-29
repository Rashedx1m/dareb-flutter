part of 'gallery_cubit.dart';

enum GalleryStatus { initial, loading, success, failure }

class GalleryState extends Equatable {
  const GalleryState({
    this.status = GalleryStatus.initial,
    this.albums = const [],
    this.album,
    this.error,
  });

  final GalleryStatus status;
  final List<GalleryAlbum> albums;

  /// الألبوم المفتوح في شاشة الألبوم أو عارض الصور.
  final GalleryAlbum? album;
  final String? error;

  GalleryState copyWith({
    GalleryStatus? status,
    List<GalleryAlbum>? albums,
    GalleryAlbum? album,
    String? error,
  }) {
    return GalleryState(
      status: status ?? this.status,
      albums: albums ?? this.albums,
      album: album ?? this.album,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, albums, album, error];
}
