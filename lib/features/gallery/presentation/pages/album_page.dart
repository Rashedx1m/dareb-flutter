import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../cubit/gallery_cubit.dart';
import '../widgets/gallery_header.dart';

/// شاشة ألبوم واحد: شبكة صوره. الضغط على صورة يفتح عارض الصور.
class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            GalleryHeader(
              onNotify: () => context.push('/notifications'),
              onBack: () => context.pop(),
            ),
            Expanded(
              child: BlocBuilder<GalleryCubit, GalleryState>(
                builder: (context, state) {
                  final photos = state.album?.photos ?? const <String>[];
                  return switch (state.status) {
                    GalleryStatus.initial || GalleryStatus.loading => const LoadingView(),
                    GalleryStatus.failure => ErrorView(
                        message: state.error,
                        onRetry: () => context.read<GalleryCubit>().loadAlbum(albumId),
                      ),
                    GalleryStatus.success when photos.isEmpty => const Center(
                        child: Text(
                          AppStrings.galleryEmpty,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ),
                    GalleryStatus.success => GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: photos.length,
                        itemBuilder: (context, i) => _PhotoTile(
                          path: photos[i],
                          onTap: () => context.push('/gallery/$albumId/photo/$i'),
                        ),
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

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.path, required this.onTap});

  final String path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(path, fit: BoxFit.cover),
          ),
          const Positioned(
            right: 8,
            bottom: 8,
            child: Icon(
              Icons.crop_free_rounded,
              color: Colors.white,
              size: 20,
              shadows: [Shadow(color: AppColors.overlay60, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}
