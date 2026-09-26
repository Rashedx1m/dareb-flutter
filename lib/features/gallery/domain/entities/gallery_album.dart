import 'package:equatable/equatable.dart';

/// ألبوم صور يظهر في شاشة المعرض (مثل: «ألبوم الأعمال»).
///
/// [cover] و [photos] مسارات صور محلية (assets). العدد المعروض بين قوسين
/// في التصميم هو [count]، ويطابق طول قائمة [photos].
class GalleryAlbum extends Equatable {
  const GalleryAlbum({
    required this.id,
    required this.title,
    required this.cover,
    required this.photos,
  });

  final String id;
  final String title;
  final String cover;
  final List<String> photos;

  int get count => photos.length;

  @override
  List<Object?> get props => [id, title, cover, photos];
}
