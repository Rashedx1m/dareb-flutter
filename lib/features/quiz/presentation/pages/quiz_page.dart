import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/quiz.dart';
import '../cubit/quiz_cubit.dart';
import '../widgets/question_badge.dart';
import '../widgets/quiz_button.dart';

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
                  QuizStatus.success when quiz != null => _Questions(
                      quiz: quiz,
                      selected: state.selected,
                      sending: state.attend == AttendStatus.sending,
                    ),
                  _ => const LoadingView(),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// الأسئلة في قائمة، وزر «النتيجة» يطفو فوق آخرها كما في التصميم.
class _Questions extends StatelessWidget {
  const _Questions({required this.quiz, required this.selected, required this.sending});

  final QuizDetails quiz;
  final Map<String, String> selected;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuizCubit>();
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Stack(
      children: [
        ListView.separated(
          padding: EdgeInsetsDirectional.fromSTEB(16, 28, 22, bottom + 96),
          itemCount: quiz.questions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 30),
          itemBuilder: (context, i) {
            final question = quiz.questions[i];
            return _QuestionCard(
              number: i + 1,
              question: question,
              selectedId: selected[question.id],
              onSelect: (answerId) => cubit.select(question.id, answerId),
            );
          },
        ),
        PositionedDirectional(
          start: 16,
          end: 15,
          bottom: bottom + 16,
          child: QuizButton(
            label: AppStrings.quizResult,
            loading: sending,
            onPressed: cubit.allAnswered ? cubit.submit : null,
          ),
        ),
      ],
    );
  }
}

/// بطاقة السؤال: خط متدرّج في أعلاها، ثم الرقم والنص، ثم الخيارات.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.number, required this.question, required this.selectedId, required this.onSelect});

  final int number;
  final QuizQuestion question;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 16, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الطرف الداكن في البداية (اليمين) كما في التصميم.
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [AppColors.quizLineDark, AppColors.quizLineLight],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 25, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    QuestionBadge(number: number),
                    const SizedBox(width: 17),
                    Expanded(
                      child: Text(
                        question.text,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                for (final (i, answer) in question.answers.indexed) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _AnswerTile(text: answer.text, selected: answer.id == selectedId, onTap: () => onSelect(answer.id)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// خيار الإجابة: إطار رمادي، والمختار مظلل بلا إطار، مع دائرة الاختيار وشريط
/// فيروزي في البداية.
class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.text, required this.selected, required this.onTap});

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: selected ? BorderSide.none : const BorderSide(color: AppColors.fieldBorder),
    );
    return Semantics(
      selected: selected,
      child: Material(
        color: selected ? AppColors.answerFill : Colors.white,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 67, minWidth: double.infinity),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 16),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: selected ? AppColors.primary : AppColors.textPrimary, fontSize: 16),
                  ),
                ),
                if (selected) ...[
                  const PositionedDirectional(start: 22, child: _SelectedMark()),
                  PositionedDirectional(
                    start: 2,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ],
              ],
            ),
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
      width: 21,
      height: 21,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Container(
        width: 11,
        height: 11,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      ),
    );
  }
}
