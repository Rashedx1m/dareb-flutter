import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/quiz.dart';
import '../cubit/quiz_result_cubit.dart';

/// شاشة إنهاء الاختبار: النسبة والعدّادات من `GET /exams/result`.
class QuizResultPage extends StatelessWidget {
  const QuizResultPage({super.key, required this.quizId});

  final String quizId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<QuizResultCubit, QuizResultState>(
          builder: (context, state) => switch (state.status) {
            QuizResultStatus.failure => ErrorView(
                message: state.error,
                onRetry: () => context.read<QuizResultCubit>().load(quizId),
              ),
            QuizResultStatus.success when state.quiz != null => _Body(quizId: quizId, quiz: state.quiz!),
            _ => const LoadingView(),
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.quizId, required this.quiz});

  final String quizId;
  final QuizDetails quiz;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 112,
            height: 112,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(PhosphorIconsRegular.medal, color: Colors.white, size: 56),
          ),
          const SizedBox(height: 28),
          const Text(
            AppStrings.quizFinishedTitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.nameDark, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.quizFinishedSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          Text(
            '${quiz.percent}%',
            style: const TextStyle(color: AppColors.iconBlue, fontSize: 48, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _StatCard(
                icon: PhosphorIconsRegular.exam,
                iconColor: AppColors.primary,
                value: quiz.questionsCount,
                label: AppStrings.questionsCountLabel,
                barColor: AppColors.primary,
              ),
              const SizedBox(width: 10),
              _StatCard(
                icon: PhosphorIconsFill.sealCheck,
                iconColor: AppColors.success,
                value: quiz.correctAnswers,
                label: AppStrings.correctAnswersLabel,
                barColor: AppColors.primary,
              ),
              const SizedBox(width: 10),
              _StatCard(
                icon: PhosphorIconsRegular.xCircle,
                iconColor: AppColors.danger,
                value: quiz.failedAnswers,
                label: AppStrings.wrongAnswersLabel,
                barColor: AppColors.danger,
              ),
            ],
          ),
          const Spacer(),
          AppButton(
            label: AppStrings.reviewAnswers,
            onPressed: () => context.push('/quiz/$quizId/review'),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: AppStrings.backToHome,
            outlined: true,
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.barColor,
  });

  final IconData icon;
  final Color iconColor;
  final int value;
  final String label;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 10, offset: Offset(0, 4))],
          border: Border(bottom: BorderSide(color: barColor, width: 3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
