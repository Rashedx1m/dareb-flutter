import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/gallery_album.dart';

/// بطاقة ألبوم في شبكة المعرض: مصغّرة على هيئة صور مكدّسة، ثم اسم الألبوم وعدد
/// صوره بين قوسين كما في التصميم («ألبوم الأعمال ( 12 )»).
class AlbumCard extends StatelessWidget {
  const AlbumCard({super.key, required this.album, required this.onTap});

  final GalleryAlbum album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.albumBorder),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowLight, blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: _StackedThumb(photos: album.photos, cover: album.cover),
            ),
            const SizedBox(height: 14),
            Text(
              '${album.title} ( ${album.count} )',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// مصغّرة «كومة صور»: صورتان مائلتان في الخلف وصورة الغلاف مستقيمة في المقدمة.
class _StackedThumb extends StatelessWidget {
  const _StackedThumb({required this.photos, required this.cover});

  final List<String> photos;
  final String cover;

  @override
  Widget build(BuildContext context) {
    final back1 = photos.length > 1 ? photos[1] : cover;
    final back2 = photos.length > 2 ? photos[2] : back1;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _tilted(angle: 0.13, path: back2),
        _tilted(angle: -0.11, path: back1),
        FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.94,
          child: _Photo(path: cover, front: true),
        ),
      ],
    );
  }

  Widget _tilted({required double angle, required String path}) {
    return Transform.rotate(
      angle: angle,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        heightFactor: 0.82,
        child: _Photo(path: path),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.path, this.front = false});

  final String path;
  final bool front;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Color(front ? 0x30000000 : 0x1F000000),
            blurRadius: front ? 10 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.asset(path, fit: BoxFit.cover),
      ),
    );
  }
}
