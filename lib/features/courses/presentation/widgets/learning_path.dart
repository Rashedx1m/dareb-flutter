import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/semester.dart';
import '../lesson_path.dart';

/// عنوان «مسار التعلم» بأيقونته، في صفحتي الدورة والدرس.
class LearningPathTitle extends StatelessWidget {
  const LearningPathTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        // أيقونة المسار في التصميم عمودية.
        RotatedBox(
          quarterTurns: 1,
          child: Icon(PhosphorIconsRegular.path, color: AppColors.blueStrong, size: 26),
        ),
        SizedBox(width: 6),
        Text(
          AppStrings.learningPath,
          style: TextStyle(color: AppColors.pathTitle, fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

/// فصل في «مسار التعلم»: اسمه وعدد دروسه، ثم دروسه على خط زمني.
class SemesterPath extends StatelessWidget {
  const SemesterPath({
    super.key,
    required this.semester,
    required this.lessons,
    required this.onLessonTap,
    required this.onDownload,
  });

  final Semester semester;
  final List<PathLesson> lessons;
  final ValueChanged<PathLesson> onLessonTap;

  /// زر التنزيل في درس الملف المفتوح.
  final ValueChanged<Lesson> onDownload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 15, end: 15),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: semester.name),
                const TextSpan(text: '  '),
                TextSpan(
                  text: '${lessons.length}',
                  style: const TextStyle(color: AppColors.accentBlue, fontFamily: 'Lato'),
                ),
              ],
            ),
            style: const TextStyle(color: AppColors.listText, fontSize: 16),
          ),
        ),
        const SizedBox(height: 32),
        for (final (i, item) in lessons.indexed)
          _PathRow(
            item: item,
            isLast: i == lessons.length - 1,
            onTap: () => onLessonTap(item),
            onDownload: () => onDownload(item.lesson),
          ),
      ],
    );
  }
}

/// صف الدرس: دائرة الحالة وخط المسار في البداية، والبطاقة بعدهما.
class _PathRow extends StatelessWidget {
  const _PathRow({required this.item, required this.isLast, required this.onTap, required this.onDownload});

  final PathLesson item;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final open = item.step == LessonStep.open;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 20),
          SizedBox(
            width: 41,
            child: Column(
              children: [
                _StepDot(step: item.step),
                if (!isLast)
                  const Expanded(child: VerticalDivider(width: 2, thickness: 2, color: AppColors.timelineLine)),
              ],
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: 31, bottom: isLast ? 0 : 32),
              // الدرس غير المتاح يظهر باهتاً كما في التصميم.
              child: Opacity(
                opacity: open ? 1 : 0.6,
                child: _LessonCard(item: item, onTap: onTap, onDownload: onDownload),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.step});

  final LessonStep step;

  @override
  Widget build(BuildContext context) {
    final open = step == LessonStep.open;
    return Container(
      width: 41,
      height: 41,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: open ? AppColors.statTeal : AppColors.stepIdleFill,
      ),
      child: Icon(
        switch (step) {
          LessonStep.open => PhosphorIconsRegular.play,
          LessonStep.exam => PhosphorIconsRegular.exam,
          LessonStep.locked || LessonStep.waiting => PhosphorIconsRegular.lock,
        },
        color: open ? Colors.white : AppColors.stepIdleIcon,
        size: 18,
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.item, required this.onTap, required this.onDownload});

  final PathLesson item;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final lesson = item.lesson;
    final open = item.step == LessonStep.open;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: item.step == LessonStep.exam ? null : onTap,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 23, 20, 23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.lessonTitle, fontSize: 15),
                    ),
                  ),
                  if (open) ...[
                    if (lesson.type == LessonType.file && lesson.fileUrl != null) ...[
                      const SizedBox(width: 8),
                      _DownloadButton(onPressed: onDownload),
                    ],
                    if (lesson.isAttended) ...[
                      const SizedBox(width: 12),
                      const _WatchedBadge(),
                    ] else if (lesson.type == LessonType.video) ...[
                      const SizedBox(width: 12),
                      const Icon(PhosphorIconsFill.playCircle, color: AppColors.blueStrong, size: 26),
                    ],
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  ?_chip(lesson),
                  const Spacer(),
                  if (item.isCurrent)
                    const Text(AppStrings.nowPlaying, style: TextStyle(color: AppColors.primary, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// شارة المدة للفيديو، والنوع للملف والاختبار.
  static Widget? _chip(Lesson lesson) {
    return switch (lesson.type) {
      LessonType.video when lesson.duration != null =>
        _InfoChip(icon: PhosphorIconsRegular.timer, label: lessonDurationLabel(lesson.duration!)),
      LessonType.video => null,
      LessonType.file => const _InfoChip(icon: PhosphorIconsRegular.fileText, label: AppStrings.pdfFile),
      LessonType.exam => const _InfoChip(icon: PhosphorIconsRegular.exam, label: AppStrings.examLesson),
    };
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: AppColors.chipFill, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.metaText),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.metaText, fontSize: 11)),
        ],
      ),
    );
  }
}

class _WatchedBadge extends StatelessWidget {
  const _WatchedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.watchedFill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.watchedBorder),
      ),
      child: const Text(AppStrings.watched, style: TextStyle(color: AppColors.watchedText, fontSize: 9)),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppStrings.downloadFile,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(2),
          child: Icon(PhosphorIconsFill.trayArrowDown, color: AppColors.blueStrong, size: 26),
        ),
      ),
    );
  }
}
