import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/mock_catalog.dart';
import '../widgets/album_card.dart';
import '../widgets/gallery_header.dart';

/// شاشة المعرض الرئيسية: شبكة ألبومات الصور. تفتح كتبويب في الشريط السفلي.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final albums = MockCatalog.galleryAlbums;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            GalleryHeader(onNotify: () => context.push('/notifications')),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                ),
                itemCount: albums.length,
                itemBuilder: (context, i) {
                  final album = albums[i];
                  return AlbumCard(
                    album: album,
                    onTap: () => context.push('/gallery/${album.id}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
