import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';

/// صورة معرض من رابط الخادم، ومكانها ملوّن بأيقونة إن غاب الرابط أو فشل.
class GalleryImage extends StatelessWidget {
  const GalleryImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (_, _) => const ColoredBox(color: AppColors.primarySoft),
        errorWidget: (_, _, _) => const ColoredBox(
          color: AppColors.primarySoft,
          child: Icon(PhosphorIconsRegular.image, color: AppColors.primary, size: 28),
        ),
      );
    }
    return const ColoredBox(
      color: AppColors.primarySoft,
      child: Icon(PhosphorIconsRegular.image, color: AppColors.primary, size: 28),
    );
  }
}
