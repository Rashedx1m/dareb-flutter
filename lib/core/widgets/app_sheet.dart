import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

/// يعرض ورقة سفلية بشكل التصميم (حواف علوية مدوّرة 32)، وترتفع مع لوحة المفاتيح.
Future<T?> showAppSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
          child: builder(sheetContext),
        ),
      ),
    ),
  );
}

/// عنوان الورقة أو النافذة: أيقونة وعنوان في البداية، وزر الإغلاق في النهاية.
class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key, required this.title, this.icon, this.iconColor = AppColors.iconBlue, this.onClose});

  final String title;
  final IconData? icon;
  final Color iconColor;

  /// بلا قيمة تُغلق الورقة الحالية.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon case final icon?) ...[
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: AppColors.sheetTitle, fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        IconButton(
          tooltip: AppStrings.exitWord,
          onPressed: onClose ?? () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: const Icon(PhosphorIconsRegular.xCircle, color: AppColors.closeIcon, size: 42),
        ),
      ],
    );
  }
}

/// حقل النماذج في الأوراق: إطار رمادي يصير أزرق عند التركيز، وأيقونة زرقاء في بدايته.
class SheetField extends StatelessWidget {
  const SheetField({
    super.key,
    required this.hint,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.trailing,
  });

  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  /// أكثر من سطر يجعل الحقل مربع وصف، وتبقى الأيقونة في أعلاه.
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? trailing;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final multiline = maxLines > 1;
    final iconWidget = Icon(icon, color: AppColors.iconBlue, size: 22);
    final field = TextField(
      controller: controller,
      keyboardType: multiline ? TextInputType.multiline : keyboardType,
      maxLines: maxLines,
      minLines: multiline ? maxLines : 1,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: AppColors.sheetTitle, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
        prefixIcon: multiline ? null : iconWidget,
        suffixIcon: trailing,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsetsDirectional.fromSTEB(multiline ? 48 : 16, 16, 16, 16),
        enabledBorder: const OutlineInputBorder(
          borderRadius: _radius,
          borderSide: BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: _radius,
          borderSide: BorderSide(color: AppColors.blueStrong),
        ),
      ),
    );
    if (!multiline) return field;
    // أيقونة مربع الوصف في زاويته العليا، لا في منتصفه كما يضعها prefixIcon.
    return Stack(
      children: [
        field,
        PositionedDirectional(start: 16, top: 16, child: IgnorePointer(child: iconWidget)),
      ],
    );
  }
}

/// زرّا أسفل الأوراق والنوافذ: الأساسي الفيروزي في البداية، والثانوي المحدد بجانبه.
class SheetActions extends StatelessWidget {
  const SheetActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.loading = false,
    this.secondaryLabel = AppStrings.exitWord,
    this.onSecondary,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool loading;
  final String secondaryLabel;

  /// بلا قيمة يُغلق الزر الثانوي الورقة.
  final VoidCallback? onSecondary;

  static const _shape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)));

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: loading ? null : onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                elevation: 0,
                shape: _shape,
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(primaryLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: onSecondary ?? () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.iconBlue,
                side: const BorderSide(color: AppColors.blueStrong),
                shape: _shape,
              ),
              child: Text(secondaryLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            ),
          ),
        ),
      ],
    );
  }
}

/// نافذة تأكيد صغيرة في وسط الشاشة فوق طبقة داكنة (تأكيد تسجيل الخروج، ونوافذ الدروس).
/// تعيد `true` عند التأكيد.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String confirmLabel = AppStrings.confirm,
  IconData? icon,
  Color iconColor = AppColors.iconBlue,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: AppColors.overlay70,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 29, 22, 35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(
              title: title,
              icon: icon,
              iconColor: iconColor,
              onClose: () => Navigator.of(dialogContext).pop(false),
            ),
            const SizedBox(height: 29),
            SheetActions(
              primaryLabel: confirmLabel,
              onPrimary: () => Navigator.of(dialogContext).pop(true),
              secondaryLabel: AppStrings.back,
              onSecondary: () => Navigator.of(dialogContext).pop(false),
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}
