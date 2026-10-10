import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../domain/entities/course.dart';

/// بطاقة مادة مشترك بها في تبويب «المواد»: الصورة والعنوان والأستاذ والعدّادات،
/// ثم شريطا التقدم وزر «متابعة التعلم».
class MySubjectCard extends StatelessWidget {
  const MySubjectCard({super.key, required this.course, required this.onContinue});

  final Course course;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderSoft),
        boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: course.imageUrl,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const ColoredBox(color: AppColors.primarySoft),
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: AppColors.primarySoft,
                    child: Icon(PhosphorIconsFill.bookOpen, color: AppColors.primary, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            course.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(PhosphorIconsFill.bookOpen, color: AppColors.iconBlue, size: 18),
                      ],
                    ),
                    if (course.instructor.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        course.instructor,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${course.semestersCount} ${AppStrings.chaptersLabel} , '
                      '${course.lessonsCount} ${AppStrings.lessonsLabel}',
                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            course.subjectName,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _RateBar(label: AppStrings.completedUnits, rate: course.semesterRate),
          const SizedBox(height: 10),
          _RateBar(label: AppStrings.completedLessons, rate: course.lessonRate),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onContinue,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(AppStrings.keepLearning, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _RateBar extends StatelessWidget {
  const _RateBar({required this.label, required this.rate});

  final String label;

  /// من 0 إلى 100.
  final int rate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(color: AppColors.progressText, fontSize: 13)),
            ),
            Text(
              '$rate%',
              style: const TextStyle(
                color: AppColors.progressText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lato',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: rate.clamp(0, 100) / 100,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
          color: AppColors.primary,
          backgroundColor: AppColors.progressTrack,
        ),
      ],
    );
  }
}
