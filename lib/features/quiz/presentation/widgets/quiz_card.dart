import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../courses/presentation/widgets/content_cards.dart';
import '../../domain/entities/quiz.dart';

/// بطاقة قائمة «اختباراتي» بشكل بطاقة الاختبار في صفحة المادة: الأيقونة والعنوان
/// والأستاذ وعدد الأسئلة. النقاط التي في التصميم لا يرسلها الخادم فلا تظهر.
class QuizCard extends StatelessWidget {
  const QuizCard({super.key, required this.quiz, required this.onTap});

  final Quiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      onTap: onTap,
      height: 108,
      borderColor: AppColors.quizCardBorder,
      radius: 10,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 14, end: 10),
        child: SvgPicture.asset(
          quiz.kind == QuizKind.activity ? AppAssets.icActivity : AppAssets.icQuiz,
          width: 55,
          height: 60,
        ),
      ),
      title: quiz.title,
      subtitle: quiz.instructor,
      meta: '${quiz.questionsCount} ${AppStrings.questionsUnit}',
    );
  }
}
