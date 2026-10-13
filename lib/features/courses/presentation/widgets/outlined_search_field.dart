import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';

/// حقل البحث بإطار رفيع تحت الترويسة، والعدسة قبل النص. إطاره رمادي في «موادي»
/// وأزرق في «نتائج البحث».
class OutlinedSearchField extends StatelessWidget {
  const OutlinedSearchField({
    super.key,
    required this.onChanged,
    this.borderColor = AppColors.cardBorder,
    this.autofocus = false,
  });

  final ValueChanged<String> onChanged;
  final Color borderColor;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.magnifyingGlass, color: AppColors.iconBlue, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              autofocus: autofocus,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              // حدود الحقل في الثيم العام لا تظهر داخل الإطار.
              decoration: const InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: AppStrings.searchHere,
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
