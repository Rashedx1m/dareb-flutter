import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';

/// ترويسة المعرض (الشريط الفيروزي المدوّر) المشتركة بين شاشتَي الألبومات وصور
/// الألبوم. يسار: جرس الإشعارات، الوسط: أيقونة الصور + «المعرض»، يمين: شعار درب
/// (في شاشة الألبومات) أو سهم الرجوع (عند فتح ألبوم).
class GalleryHeader extends StatelessWidget {
  const GalleryHeader({super.key, required this.onNotify, this.onBack});

  final VoidCallback onNotify;

  /// عند تمريره تظهر أيقونة الرجوع بدل الشعار.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.headerTeal,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          _HeaderIconButton(
            tooltip: AppStrings.notifications,
            onTap: onNotify,
            child: const Icon(PhosphorIconsRegular.bell, color: Colors.white, size: 22),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  AppStrings.gallery,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(PhosphorIconsRegular.image, color: Colors.white, size: 24),
              ],
            ),
          ),
          if (onBack != null)
            _HeaderIconButton(
              tooltip: AppStrings.back,
              onTap: onBack!,
              child: const Icon(PhosphorIconsRegular.arrowRight, color: Colors.white, size: 22),
            )
          else
            SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.logo,
                  width: 34,
                  height: 34,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.child,
    required this.onTap,
    required this.tooltip,
  });

  final Widget child;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
