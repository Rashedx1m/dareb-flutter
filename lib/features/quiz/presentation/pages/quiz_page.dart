import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/quiz_bloc.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key, required this.quizId});
  final String quizId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state.status == QuizStatus.completed) {
          context.go(
            '/quiz/$quizId/result',
            extra: {
              'score': state.score,
              'total': state.current?.questions.length ?? 0,
            },
          );
        }
      },
      builder: (context, state) {
        final quiz = state.current;
        if (quiz == null || state.status == QuizStatus.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final question = quiz.questions[state.currentIndex];
        final selected = state.answers[state.currentIndex];
        return Scaffold(
          appBar: AppBar(
            title: Text('سؤال ${state.currentIndex + 1} / ${quiz.questions.length}'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (state.currentIndex + 1) / quiz.questions.length,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primarySoft,
                ),
                const SizedBox(height: 20),
                Text(question.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.4)),
                const SizedBox(height: 20),
                ...List.generate(question.answers.length, (i) {
                  final isSelected = selected == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => context.read<QuizBloc>().add(
                            QuizAnswerSelected(questionIndex: state.currentIndex, optionIndex: i),
                          ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primarySoft : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                        ),
                        child: Text(question.answers[i].text, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                AppButton(
                  label: state.currentIndex + 1 == quiz.questions.length ? 'إنهاء الاختبار' : 'التالي',
                  onPressed: selected == null ? null : () => context.read<QuizBloc>().add(const QuizNextPressed()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
