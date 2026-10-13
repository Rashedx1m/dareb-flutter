import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/quiz.dart';

/// بطاقة قائمة «اختباراتي»: الأيقونة والعنوان والأستاذ وعدد الأسئلة، بلا نقاط.
class QuizCard extends StatelessWidget {
  const QuizCard({super.key, required this.quiz, required this.onTap});

  final Quiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = quiz.kind == QuizKind.activity ? AppAssets.icActivity : AppAssets.icQuiz;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.quizCardBorder, width: 1.3),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(width: 56, height: 56, child: SvgPicture.asset(icon, fit: BoxFit.contain)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    if (quiz.instructor.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        quiz.instructor,
                        style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '${quiz.questionsCount} ${AppStrings.questionUnit}',
                      style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
