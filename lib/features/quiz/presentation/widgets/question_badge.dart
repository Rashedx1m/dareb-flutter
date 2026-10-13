import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// رقم السؤال في دائرة فيروزية كما في شاشتي الحل والمراجعة.
class QuestionBadge extends StatelessWidget {
  const QuestionBadge({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      child: Text(
        '$number',
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}
