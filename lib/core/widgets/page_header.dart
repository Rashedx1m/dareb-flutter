import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_strings.dart';
import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

/// الترويسة الفيروزية لصفحات الملف الشخصي كما في التصميم: في البداية (اليمين)
/// الشعار أو سهم الرجوع، العنوان في الوسط، وفي النهاية زر الإشعارات.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.titleIcon,
    this.onBack,
    this.onNotifications,
    this.trailing,
    this.bottom,
  });

  final String title;

  /// أيقونة تظهر بعد العنوان (يساره).
  final IconData? titleIcon;

  /// عند تمريره يظهر سهم الرجوع بدل الشعار.
  final VoidCallback? onBack;
  final VoidCallback? onNotifications;

  /// يحل محل زر الإشعارات في نهاية الترويسة، كعدد غير المقروء في صفحة الإشعارات.
  final Widget? trailing;

  /// يظهر تحت صف العنوان داخل الترويسة، كحقل البحث في «موادي».
  final Widget? bottom;

  /// عرض طرفي الترويسة متساوٍ حتى يبقى العنوان في المنتصف تماماً.
  static const _sideWidth = 52.0;

  @override
  Widget build(BuildContext context) {
    final back = onBack;
    final bottom = this.bottom;
    final titleRow = Row(
      children: [
        SizedBox(
          width: _sideWidth,
          child: back == null
              ? Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SvgPicture.asset(
                    AppAssets.logoMark,
                    width: 52,
                    height: 34,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                )
              : Align(
                  alignment: AlignmentDirectional.centerStart,
                  // بارتفاع زر الإشعارات (36)؛ IconButton يفرض 48 فتزيد الترويسة عن التصميم.
                  child: Tooltip(
                    message: AppStrings.back,
                    child: InkWell(
                      onTap: back,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(PhosphorIconsRegular.arrowRight, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
              if (titleIcon case final icon?) ...[
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 26),
              ],
            ],
          ),
        ),
        SizedBox(
          width: _sideWidth,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: trailing ??
                Tooltip(
                  message: AppStrings.notifications,
                  child: Material(
                    color: AppColors.accentBlue,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: onNotifications,
                      borderRadius: BorderRadius.circular(8),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(PhosphorIconsFill.bell, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 27, 16, bottom == null ? 36 : 22),
      decoration: const BoxDecoration(
        color: AppColors.headerTeal,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: bottom == null
          ? titleRow
          : Column(mainAxisSize: MainAxisSize.min, children: [titleRow, const SizedBox(height: 18), bottom]),
    );
  }
}
