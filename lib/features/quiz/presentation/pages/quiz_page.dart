import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/quiz.dart';
import '../cubit/quiz_cubit.dart';
import '../widgets/question_badge.dart';

/// صفحة حل الاختبار: كل الأسئلة في صفحة واحدة، و«النتيجة» بعد الإجابة عنها كلها.
class QuizPage extends StatelessWidget {
  const QuizPage({super.key, required this.quizId});

  final String quizId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listenWhen: (previous, current) => previous.attend != current.attend,
      listener: (context, state) {
        switch (state.attend) {
          case AttendStatus.done:
            context.go('/quiz/$quizId/result');
          case AttendStatus.failure:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.attendError ?? AppStrings.loadError)));
          case AttendStatus.idle || AttendStatus.sending:
            break;
        }
      },
      builder: (context, state) {
        final quiz = state.quiz;
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              PageHeader(
                title: quiz?.title ?? AppStrings.myTests,
                onBack: () => context.pop(),
                onNotifications: () => context.push('/notifications'),
              ),
              Expanded(
                child: switch (state.status) {
                  QuizStatus.failure => ErrorView(
                      message: state.error,
                      onRetry: () => context.read<QuizCubit>().load(quizId),
                    ),
                  QuizStatus.success when quiz != null => _Questions(quiz: quiz, selected: state.selected),
                  _ => const LoadingView(),
                },
              ),
              if (state.status == QuizStatus.success && quiz != null)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: AppButton(
                      label: AppStrings.quizResult,
                      loading: state.attend == AttendStatus.sending,
                      onPressed: context.read<QuizCubit>().allAnswered ? context.read<QuizCubit>().submit : null,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Questions extends StatelessWidget {
  const _Questions({required this.quiz, required this.selected});

  final QuizDetails quiz;
  final Map<String, String> selected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      itemCount: quiz.questions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        final question = quiz.questions[i];
        return _QuestionCard(
          number: i + 1,
          question: question,
          selectedId: selected[question.id],
          onSelect: (answerId) => context.read<QuizCubit>().select(question.id, answerId),
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.selectedId,
    required this.onSelect,
  });

  final int number;
  final QuizQuestion question;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700, height: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              QuestionBadge(number: number),
            ],
          ),
          const SizedBox(height: 16),
          for (final answer in question.answers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AnswerTile(
                text: answer.text,
                selected: answer.id == selectedId,
                onTap: () => onSelect(answer.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.text, required this.selected, required this.onTap});

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52, minWidth: double.infinity),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              if (selected)
                const PositionedDirectional(
                  end: 14,
                  child: _SelectedMark(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedMark extends StatelessWidget {
  const _SelectedMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      ),
    );
  }
}
