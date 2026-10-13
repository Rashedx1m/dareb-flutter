import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../domain/entities/course.dart';
import 'content_cards.dart';

/// بطاقة مادة مشترك بها في تبويب «المواد» كما في التصميم: صورة دائرية في البداية
/// وبجانبها العنوان والأستاذ والعدّادات، ثم اسم المادة وشريط الدروس المنجزة وزر
/// «متابعة التعلم».
///
/// التصميم يضع فوق شريط الدروس شريط «الوحدات المكتملة»، ولا يُعرض: `semester_rate`
/// ظهرت 75 لمادة لم يُحضر فيها أي درس، فهي ليست نسبة إنجاز.
class MySubjectCard extends StatelessWidget {
  const MySubjectCard({super.key, required this.course, required this.onContinue});

  final Course course;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(23, 27, 24, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 20, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 6),
                child: CircleImage(url: course.imageUrl, size: 110),
              ),
              const SizedBox(width: 13),
              Expanded(child: _Summary(course: course)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            course.subjectName,
            style: const TextStyle(color: AppColors.lessonTitle, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _RateRow(label: AppStrings.completedLessons, rate: course.lessonRate),
          const SizedBox(height: 26),
          OutlinedButton(
            onPressed: onContinue,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.cardBorder),
              minimumSize: const Size.fromHeight(40),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(AppStrings.keepLearning, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}

/// العنوان الفيروزي بأيقونته، ثم الأستاذ، ثم عدد الفصول والدروس.
class _Summary extends StatelessWidget {
  const _Summary({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                course.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.primary, fontSize: 17),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(PhosphorIconsFill.bookOpen, color: AppColors.iconBlue, size: 20),
          ],
        ),
        if (course.instructor.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(course.instructor, style: const TextStyle(color: AppColors.metaText, fontSize: 15)),
        ],
        const SizedBox(height: 8),
        Text(
          '${course.semestersCount} ${AppStrings.chaptersLabel} , '
          '${course.lessonsCount} ${AppStrings.lessonsLabel}',
          style: const TextStyle(color: AppColors.primary, fontSize: 16),
        ),
      ],
    );
  }
}

/// اسم النسبة في البداية، ثم الشريط، ثم النسبة في النهاية.
class _RateRow extends StatelessWidget {
  const _RateRow({required this.label, required this.rate});

  final String label;

  /// من 0 إلى 100.
  final int rate;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: AppColors.metaText, fontSize: 13);
    return Row(
      children: [
        SizedBox(width: 106, child: Text(label, style: style)),
        Expanded(
          child: LinearProgressIndicator(
            value: rate.clamp(0, 100) / 100,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
            color: AppColors.iconBlue,
            backgroundColor: AppColors.controlFill,
          ),
        ),
        const SizedBox(width: 27),
        Text('$rate%', style: style.copyWith(fontFamily: 'Lato')),
      ],
    );
  }
}
