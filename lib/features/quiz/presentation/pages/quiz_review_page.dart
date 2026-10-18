import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/quiz.dart';
import '../cubit/quiz_result_cubit.dart';
import '../widgets/question_badge.dart';
import '../widgets/question_text.dart';
import '../widgets/quiz_button.dart';

/// مراجعة تفصيلية بعد الحضور، من `GET /exams/result` لا من حالة الصفحة السابقة.
class QuizReviewPage extends StatelessWidget {
  const QuizReviewPage({super.key, required this.quizId});

  final String quizId;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
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
            child: Stack(
              children: [
                BlocBuilder<QuizResultCubit, QuizResultState>(
                  builder: (context, state) => switch (state.status) {
                    QuizResultStatus.failure => ErrorView(
                        message: state.error,
                        onRetry: () => context.read<QuizResultCubit>().load(quizId),
                      ),
                    QuizResultStatus.success when state.quiz != null => _ReviewList(quiz: state.quiz!),
                    _ => const LoadingView(),
                  },
                ),
                PositionedDirectional(
                  start: 16,
                  end: 15,
                  bottom: bottom + 16,
                  child: QuizButton(label: AppStrings.backToHome, onPressed: () => context.go('/home')),
                ),
              ],
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
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(15, 22, 22, MediaQuery.paddingOf(context).bottom + 96),
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.only(start: 1),
          child: Text(AppStrings.detailedReview, style: TextStyle(color: AppColors.metaText, fontSize: 15)),
        ),
        const Padding(
          padding: EdgeInsetsDirectional.only(top: 14, bottom: 26, end: 2),
          child: Divider(height: 1, color: AppColors.divider),
        ),
        for (final (i, question) in quiz.questions.indexed) ...[
          if (i > 0) const SizedBox(height: 19),
          _ReviewCard(number: i + 1, question: question),
        ],
      ],
    );
  }
}

/// بطاقة سؤال في المراجعة: حافة البداية ورقم السؤال بلون صحة الإجابة، وإجابة
/// الطالب، ثم الإجابات الصحيحة إن أخطأ.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.number, required this.question});

  final int number;
  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    final selected = question.selected;
    final isRight = question.isAnsweredCorrectly;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 16, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(23, 20, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuestionBadge(
                  number: number,
                  size: 40,
                  fill: isRight ? AppColors.statTeal : AppColors.reviewWrongBadge,
                  textColor: isRight ? Colors.white : AppColors.reviewWrongBar,
                ),
                const SizedBox(width: 17),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // بارتفاع الرقم على الأقل، فيتوسط السطر الواحد بجانبه.
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 40),
                        child: Row(
                          children: [
                            Expanded(
                              child: QuestionText(
                                question.text,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isRight ? PhosphorIconsFill.checkCircle : PhosphorIconsFill.xCircle,
                              color: isRight ? AppColors.statTeal : AppColors.danger,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (selected != null)
                        _AnswerBox(
                          caption: isRight ? AppStrings.yourAnswerCorrect : AppStrings.yourAnswerWrong,
                          text: selected.text,
                          correct: isRight,
                        ),
                      if (!isRight && question.correctAnswers.isNotEmpty) ...[
                        if (selected != null) const SizedBox(height: 12),
                        _AnswerBox(
                          caption: AppStrings.correctAnswerLabel,
                          text: question.correctAnswers.map((a) => a.text).join('، '),
                          correct: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: 6,
            child: ColoredBox(color: isRight ? AppColors.statTeal : AppColors.reviewWrongBar),
          ),
        ],
      ),
    );
  }
}

/// صندوق إجابة: فيروزي فاتح للصحيحة، وأحمر فاتح بإطار وخط مشطوب للخاطئة.
class _AnswerBox extends StatelessWidget {
  const _AnswerBox({required this.caption, required this.text, required this.correct});

  final String caption;
  final String text;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final valueColor = correct ? AppColors.primary : AppColors.reviewWrongBar;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: correct ? AppColors.answerFill : AppColors.reviewWrongFill,
        borderRadius: BorderRadius.circular(14),
        border: correct ? null : Border.all(color: AppColors.reviewWrongBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(caption, style: const TextStyle(color: AppColors.metaText, fontSize: 15)),
          const SizedBox(height: 6),
          QuestionText(
            text,
            style: TextStyle(
              color: valueColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              decoration: correct ? null : TextDecoration.lineThrough,
              decorationColor: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
