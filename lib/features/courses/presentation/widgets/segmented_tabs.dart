import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// تبويبات على مسار واحد، والمختار يملأ مكانه فيروزياً بنص أبيض.
/// الافتراضي ألوان صفحة المادة؛ «اختباراتي» يمرّر [trackColor] و[labelColor].
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelect,
    this.trackColor = AppColors.subjectChip,
    this.labelColor = AppColors.iconBlue,
  });

  /// كل تبويب واسمه، بالترتيب الذي يظهر به.
  final Map<T, String> tabs;
  final T selected;
  final ValueChanged<T> onSelect;

  /// لون المسار خلف التبويبات.
  final Color trackColor;

  /// لون نص التبويب غير المختار.
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: trackColor, borderRadius: BorderRadius.circular(10)),
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
                      style: TextStyle(color: tab == selected ? Colors.white : labelColor, fontSize: 15),
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
