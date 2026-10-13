import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';

/// رأس صفحة الدورة: خلفية فيروزية بزوايا سفلية دائرية، وصورة الدورة في وسطها
/// ملتصقة بأسفلها، وزر الرجوع في البداية.
class CourseHeader extends StatelessWidget {
  const CourseHeader({super.key, required this.imageUrl});

  final String imageUrl;

  /// ارتفاع الرأس تحت شريط الحالة.
  static const _height = 330.0;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: top + _height,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: ColoredBox(
          color: AppColors.headerTeal,
          child: Stack(
            children: [
              PositionedDirectional(
                top: top + 18,
                start: 24,
                end: 24,
                bottom: 0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorWidget: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              PositionedDirectional(
                top: top + 3,
                start: 25,
                child: Tooltip(
                  message: AppStrings.back,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(PhosphorIconsRegular.arrowRight, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
