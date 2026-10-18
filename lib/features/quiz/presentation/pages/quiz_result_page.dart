import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/quiz.dart';
import '../cubit/quiz_result_cubit.dart';
import '../widgets/quiz_button.dart';

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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
            child: Column(
              children: [
                const _Badge(),
                const SizedBox(height: 28),
                const Text(
                  AppStrings.quizFinishedTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppStrings.quizFinishedSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.metaText, fontSize: 15),
                ),
                const SizedBox(height: 22),
                Text(
                  '${quiz.percent}%',
                  style: const TextStyle(
                    color: AppColors.accentBlue,
                    fontSize: 76,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 56),
                // عرض التصميم 103، وتضيق البطاقات على الهواتف الأضيق بدل أن تفيض.
                // والارتفاع بارتفاع أطولها إن التفّ اسم أحدها على سطرين.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = math.min(103.0, (constraints.maxWidth - 32) / 3);
                    return IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _StatCard(
                            icon: PhosphorIconsFill.sealQuestion,
                            iconColor: AppColors.primary,
                            iconFill: AppColors.primarySoft,
                            value: quiz.questionsCount,
                            label: AppStrings.questionsCountLabel,
                            width: width,
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            icon: PhosphorIconsFill.checkCircle,
                            iconColor: AppColors.statTeal,
                            iconFill: AppColors.primarySoft,
                            value: quiz.correctAnswers,
                            label: AppStrings.correctAnswersLabel,
                            width: width,
                            barColor: AppColors.statTeal,
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            icon: PhosphorIconsFill.xCircle,
                            iconColor: AppColors.resultWrongIcon,
                            iconFill: AppColors.resultWrongFill,
                            value: quiz.failedAnswers,
                            label: AppStrings.wrongAnswersLabel,
                            width: width,
                            barColor: AppColors.resultWrongBar,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Column(
            children: [
              QuizButton(
                label: AppStrings.reviewAnswers,
                icon: PhosphorIconsFill.listChecks,
                height: 55,
                onPressed: () => context.push('/quiz/$quizId/review'),
              ),
              const SizedBox(height: 16),
              QuizButton(
                label: AppStrings.backToHome,
                icon: PhosphorIconsRegular.house,
                height: 55,
                muted: true,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// الوسام في دائرة فيروزية، ونجمتان صغيرتان حوله كما في التصميم.
class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: const BoxDecoration(color: AppColors.statTeal, shape: BoxShape.circle),
            child: const Icon(PhosphorIconsFill.medal, color: Colors.white, size: 60),
          ),
          // مواضع بصرية ثابتة لا تنعكس مع اتجاه النص.
          const Positioned(left: 187, top: 0, child: Icon(PhosphorIconsFill.star, color: AppColors.iconBlue, size: 20)),
          const Positioned(
            left: 7,
            top: 127,
            child: Icon(PhosphorIconsFill.star, color: AppColors.primaryMid, size: 24),
          ),
        ],
      ),
    );
  }
}

/// بطاقة عدّاد: الأيقونة في دائرة، ثم الرقم واسمه، وشريط ملوّن في أسفلها.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconFill,
    required this.value,
    required this.label,
    required this.width,
    this.barColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconFill;
  final int value;
  final String label;
  final double width;

  /// لا شريط تحت «عدد الأسئلة».
  final Color? barColor;

  @override
  Widget build(BuildContext context) {
    final bar = barColor;
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 16, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 26, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(color: iconFill, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(height: 14),
                Text(
                  '$value',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.metaText, fontSize: 14, height: 1.3),
                ),
              ],
            ),
          ),
          if (bar != null)
            Positioned(
              left: 6,
              right: 6,
              bottom: 0,
              height: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: bar,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
