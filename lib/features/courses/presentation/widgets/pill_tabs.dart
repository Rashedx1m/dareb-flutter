import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// تبويبات «موادي»: حبّات منفصلة متساوية العرض. المختارة فيروزية بنص أبيض عريض،
/// والبقية بيضاء بإطار رمادي.
class PillTabs<T> extends StatelessWidget {
  const PillTabs({super.key, required this.tabs, required this.selected, required this.onSelect});

  /// كل تبويب واسمه، بالترتيب الذي يظهر به.
  final Map<T, String> tabs;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, MapEntry(key: tab, value: label)) in tabs.entries.indexed) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _Pill(label: label, selected: tab == selected, onTap: () => onSelect(tab))),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 43,
        decoration: ShapeDecoration(
          color: selected ? AppColors.statTeal : Colors.white,
          shape: StadiumBorder(side: selected ? BorderSide.none : const BorderSide(color: AppColors.cardBorder)),
          shadows: selected
              ? const [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 3))]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.metaText,
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
