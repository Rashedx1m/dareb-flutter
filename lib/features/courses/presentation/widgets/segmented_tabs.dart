import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// تبويبات صفحة المادة على مسار أزرق فاتح واحد، والمختار يملأ مكانه فيروزياً بنص
/// أبيض.
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({super.key, required this.tabs, required this.selected, required this.onSelect});

  /// كل تبويب واسمه، بالترتيب الذي يظهر به.
  final Map<T, String> tabs;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.subjectChip, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          for (final MapEntry(key: tab, value: label) in tabs.entries)
            Expanded(
              child: Semantics(
                selected: tab == selected,
                button: true,
                child: GestureDetector(
                  onTap: () => onSelect(tab),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tab == selected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(color: tab == selected ? Colors.white : AppColors.iconBlue, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
