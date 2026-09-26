import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class QuizResultPage extends StatelessWidget {
  const QuizResultPage({super.key, required this.score, required this.total});

  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((score / total) * 100).round();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  '$percent%',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              const Text('أحسنت!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'أجبت بشكل صحيح على $score من $total أسئلة',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              AppButton(label: 'العودة للرئيسية', onPressed: () => context.go('/home')),
            ],
          ),
        ),
      ),
    );
  }
}
