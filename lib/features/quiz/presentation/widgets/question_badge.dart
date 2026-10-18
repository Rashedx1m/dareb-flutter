import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// رقم السؤال في دائرة. في صفحة الحل فاتحة برقم فيروزي، وفي المراجعة تأخذ لون
/// صحة الإجابة.
class QuestionBadge extends StatelessWidget {
  const QuestionBadge({
    super.key,
    required this.number,
    this.size = 38,
    this.fill = AppColors.primarySoft,
    this.textColor = AppColors.primary,
  });

  final int number;
  final double size;
  final Color fill;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      child: Text(
        '$number',
        style: TextStyle(color: textColor, fontSize: 15, fontFamily: 'Lato'),
      ),
    );
  }
}
