import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/error_view.dart';
import '../cubit/gallery_cubit.dart';
import '../widgets/album_card.dart';
import '../widgets/gallery_header.dart';

/// شاشة المعرض الرئيسية: شبكة ألبومات الصور. تفتح كتبويب في الشريط السفلي.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            GalleryHeader(onNotify: () => context.push('/notifications')),
            Expanded(
              child: BlocBuilder<GalleryCubit, GalleryState>(
                builder: (context, state) {
                  return switch (state.status) {
                    GalleryStatus.initial || GalleryStatus.loading => const LoadingView(),
                    GalleryStatus.failure => ErrorView(
                        message: state.error,
                        onRetry: () => context.read<GalleryCubit>().loadAlbums(),
                      ),
                    GalleryStatus.success when state.albums.isEmpty => const EmptyView(message: AppStrings.galleryNoAlbums),
                    GalleryStatus.success => GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: state.albums.length,
                        itemBuilder: (context, i) {
                          final album = state.albums[i];
                          return AlbumCard(
                            album: album,
                            onTap: () => context.push('/gallery/${album.id}'),
                          );
                        },
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
