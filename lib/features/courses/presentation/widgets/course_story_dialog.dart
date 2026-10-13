import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// نافذة التعريف بالدورة: صورتها ونصها من `story_image` و`story_text`، و«ابدأ الآن».
Future<void> showCourseStory(
  BuildContext context, {
  String? imageUrl,
  String? text,
  required VoidCallback onStart,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.overlay70,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 44, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              AspectRatio(
                aspectRatio: 341 / 300,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => const ColoredBox(color: AppColors.primarySoft),
                ),
              ),
            if (text != null && text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 16, 23, 0),
                child: Text(text.trim(), style: const TextStyle(color: AppColors.primary, fontSize: 14, height: 1.45)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 18, 23, 20),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onStart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(AppStrings.startNow, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
