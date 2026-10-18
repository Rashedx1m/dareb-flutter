import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// أزرار شاشات الاختبار كما في التصميم: زوايا 12 ونص عادي وأيقونة اختيارية قبل
/// النص. [muted] للزر الرمادي الفاتح «الرجوع للصفحة الرئيسية».
class QuizButton extends StatelessWidget {
  const QuizButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.muted = false,
    this.loading = false,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool muted;
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) {
    final foreground = muted ? AppColors.textPrimary : Colors.white;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: muted ? AppColors.mutedButtonFill : AppColors.statTeal,
          foregroundColor: foreground,
          // «النتيجة» يبقى فيروزياً باهتاً حتى تُجاب كل الأسئلة.
          disabledBackgroundColor: AppColors.statTeal.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white,
          minimumSize: Size.fromHeight(height),
          side: muted ? const BorderSide(color: AppColors.cardBorder) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // نمط الزر يحل محل نمط الثيم كاملاً، فتُذكر عائلة الخط من جديد.
          textStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontFamilyFallback: AppTheme.fontFallback,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon case final icon?) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  // يضيق بنقاط على الشاشات الضيقة أو مع خط مكبّر بدل أن يفيض.
                  Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                ],
              ),
      ),
    );
  }
}
