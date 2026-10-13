import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';

/// حقل البحث الأبيض داخل الترويسة الفيروزية في صفحة المادة: مستطيل بزوايا صغيرة
/// والعدسة قبل النص.
class HeaderSearchField extends StatelessWidget {
  const HeaderSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.magnifyingGlass, color: AppColors.iconBlue, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              // حدود الحقل في الثيم العام لا تظهر داخل الحاوية البيضاء.
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
