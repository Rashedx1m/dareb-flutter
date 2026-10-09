import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// دائرة الاختيار في بطاقات الباقات ووسائل الدفع كما في التصميم: المختارة رمادية
/// بنقطة زرقاء، وغير المختارة إطار فيروزي.
class ChoiceRadio extends StatelessWidget {
  const ChoiceRadio({super.key, required this.selected});

  final bool selected;

  static const _size = 24.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.controlFill : null,
        border: selected ? null : Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: selected
          ? Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(color: AppColors.iconBlue, shape: BoxShape.circle),
            )
          : null,
    );
  }
}
