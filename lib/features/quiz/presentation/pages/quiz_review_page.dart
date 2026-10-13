import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/quiz.dart';
import '../cubit/quiz_result_cubit.dart';
import '../widgets/question_badge.dart';

/// مراجعة تفصيلية بعد الحضور، من `GET /exams/result` لا من حالة الصفحة السابقة.
class QuizReviewPage extends StatelessWidget {
  const QuizReviewPage({super.key, required this.quizId});

  final String quizId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: AppStrings.quizReviewTitle,
            onBack: () => context.pop(),
            onNotifications: () => context.push('/notifications'),
          ),
          Expanded(
            child: BlocBuilder<QuizResultCubit, QuizResultState>(
              builder: (context, state) => switch (state.status) {
                QuizResultStatus.failure => ErrorView(
                    message: state.error,
                    onRetry: () => context.read<QuizResultCubit>().load(quizId),
                  ),
                QuizResultStatus.success when state.quiz != null => _ReviewList(quiz: state.quiz!),
                _ => const LoadingView(),
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AppButton(
                label: AppStrings.backToHome,
                onPressed: () => context.go('/home'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.quiz});

  final QuizDetails quiz;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: quiz.questions.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        if (i == 0) {
          return const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              AppStrings.detailedReview,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          );
        }
        return _ReviewCard(number: i, question: quiz.questions[i - 1]);
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.number, required this.question});

  final int number;
  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    final selected = question.selected;
    final correct = question.correct;
    final isRight = selected != null && selected.id == correct?.id;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              QuestionBadge(number: number),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700, height: 1.4),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                isRight ? PhosphorIconsFill.sealCheck : PhosphorIconsRegular.xCircle,
                color: isRight ? AppColors.success : AppColors.danger,
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (selected != null)
            _AnswerBox(
              caption: isRight ? AppStrings.yourAnswerCorrect : AppStrings.yourAnswerWrong,
              text: selected.text,
              correct: isRight,
            ),
          if (!isRight && correct != null) ...[
            const SizedBox(height: 10),
            _AnswerBox(caption: AppStrings.correctAnswerLabel, text: correct.text, correct: true),
          ],
        ],
      ),
    );
  }
}

class _AnswerBox extends StatelessWidget {
  const _AnswerBox({required this.caption, required this.text, required this.correct});

  final String caption;
  final String text;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final fill = correct ? AppColors.primarySoft : AppColors.reviewWrongFill;
    final border = correct ? AppColors.primaryMid : AppColors.reviewWrongBorder;
    final valueColor = correct ? AppColors.primary : AppColors.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Text(caption, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
