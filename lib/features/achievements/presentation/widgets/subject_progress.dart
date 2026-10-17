import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../courses/domain/entities/course.dart';

/// تقدّم مادة واحدة كما في تصميم الإنجازات: نسبة المادة ثم النقاط والفصول والدروس.
class SubjectProgress extends StatelessWidget {
  const SubjectProgress({super.key, required this.course, required this.icon});

  final Course course;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final overall = course.subjectRate > 0 ? course.subjectRate : course.lessonRate;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Bar(rate: overall),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _SubjectIcon(icon: icon),
            ],
          ),
          const SizedBox(height: 18),
          _MetricRow(
            icon: PhosphorIconsRegular.medal,
            label: AppStrings.statPoints,
            rate: course.pointRate,
            total: course.pointsCount,
          ),
          const SizedBox(height: 14),
          _MetricRow(
            icon: PhosphorIconsRegular.books,
            label: AppStrings.statSemesters,
            rate: course.semesterRate,
            total: course.semestersCount,
          ),
          const SizedBox(height: 14),
          _MetricRow(
            icon: PhosphorIconsRegular.bookOpen,
            label: AppStrings.statLessons,
            rate: course.lessonRate,
            total: course.lessonsCount,
          ),
        ],
      ),
    );
  }
}

class _SubjectIcon extends StatelessWidget {
  const _SubjectIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.iconTileBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.accentBlue, size: 24),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.label,
    required this.rate,
    required this.total,
  });

  final IconData icon;
  final String label;
  final int rate;
  final int total;

  @override
  Widget build(BuildContext context) {
    final current = (rate * total / 100).round();
    return Row(
      children: [
        Icon(icon, color: AppColors.accentBlue, size: 22),
        const SizedBox(width: 8),
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.statLabel, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$current',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Lato',
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: _Track(rate: rate))),
        SizedBox(
          width: 40,
          child: Text(
            '$rate%',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Lato',
              color: AppColors.progressText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$total',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Lato',
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.rate});

  final int rate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Track(rate: rate)),
        const SizedBox(width: 10),
        Text(
          '$rate%',
          style: const TextStyle(
            fontFamily: 'Lato',
            color: AppColors.progressText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({required this.rate});

  final int rate;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: (rate / 100).clamp(0, 1),
        minHeight: 6,
        color: AppColors.primary,
        backgroundColor: AppColors.progressTrack,
      ),
    );
  }
}
