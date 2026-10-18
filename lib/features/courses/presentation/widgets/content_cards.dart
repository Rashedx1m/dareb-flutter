import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/subject_details.dart';
import '../lesson_access.dart';

/// بطاقات صفحة المادة والبحث: صورة أو أيقونة في البداية، ثم العنوان الفيروزي
/// وتحته الأستاذ والعدّاد، وفي النهاية النقاط إن وُجدت.
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.height,
    required this.leading,
    required this.title,
    this.titleIcon,
    this.subtitle = '',
    this.meta,
    this.trailing,
    this.onTap,
    this.borderColor = AppColors.albumBorder,
    this.radius = 20,
  });

  final double height;
  final Widget leading;
  final String title;
  final IconData? titleIcon;
  final String subtitle;
  final String? meta;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// أزرق أوضح في نتائج البحث.
  final Color borderColor;

  /// زوايا أصغر (10) في قائمة «اختباراتي».
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: BorderSide(color: borderColor)),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              const SizedBox(width: 14),
              leading,
              const SizedBox(width: 26),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.primary, fontSize: 16),
                          ),
                        ),
                        if (titleIcon case final icon?) ...[
                          const SizedBox(width: 6),
                          Icon(icon, color: AppColors.iconBlue, size: 18),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(subtitle, style: const TextStyle(color: AppColors.metaText, fontSize: 14)),
                    ],
                    if (meta case final meta?) ...[
                      const SizedBox(height: 6),
                      Text(meta, style: const TextStyle(color: AppColors.primary, fontSize: 15)),
                    ],
                  ],
                ),
              ),
              if (trailing case final trailing?) ...[const SizedBox(width: 8), trailing],
              const SizedBox(width: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// صورة المادة أو الدورة في دائرة زرقاء فاتحة.
class CircleImage extends StatelessWidget {
  const CircleImage({super.key, required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.subjectChip),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) =>
            Icon(PhosphorIconsRegular.chalkboardTeacher, color: AppColors.iconBlue, size: size * 0.42),
      ),
    );
  }
}

/// بطاقة دورة المادة بعدد فصولها ودروسها ونقاطها، والضغط يفتحها.
class CourseContentCard extends StatelessWidget {
  const CourseContentCard({super.key, required this.course, required this.pointsCount});

  final Course course;
  final int pointsCount;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      onTap: () => context.push('/courses/${course.id}'),
      height: 131,
      leading: CircleImage(url: course.imageUrl, size: 112),
      title: course.title,
      titleIcon: PhosphorIconsFill.bookOpen,
      subtitle: course.instructor,
      meta: '${course.semestersCount} ${AppStrings.chaptersLabel} , ${course.lessonsCount} ${AppStrings.lessonsLabel}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$pointsCount', style: const TextStyle(color: AppColors.primary, fontSize: 16)),
          const SizedBox(width: 4),
          const Icon(PhosphorIconsRegular.coins, color: AppColors.iconBlue, size: 16),
        ],
      ),
    );
  }
}

/// مادة في نتائج البحث: الخادم يرسل اسمها وصورتها فقط، والضغط يفتح دورتها.
class SubjectContentCard extends StatelessWidget {
  const SubjectContentCard({super.key, required this.subject, this.borderColor = AppColors.albumBorder});

  final Subject subject;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      onTap: () => context.push('/courses/${subject.id}'),
      height: 100,
      borderColor: borderColor,
      leading: CircleImage(url: subject.imageUrl, size: 80),
      title: subject.name,
      titleIcon: PhosphorIconsFill.bookOpen,
    );
  }
}

/// بطاقة اختبار أو نشاط يومي بأيقونته وعدد أسئلته. المجاني أو المشترك يفتح
/// `/quiz/:id`، وغيره نافذة الاشتراك.
class ExamContentCard extends StatelessWidget {
  const ExamContentCard({
    super.key,
    required this.exam,
    required this.icon,
    this.borderColor = AppColors.albumBorder,
  });

  final SubjectExam exam;

  /// مسار أيقونة SVG من `AppAssets`.
  final String icon;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      onTap: () {
        if (exam.isFree || exam.isSubscribed) {
          context.push('/quiz/${exam.id}');
        } else {
          showSubscribeDialog(context);
        }
      },
      height: 108,
      borderColor: borderColor,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 14, end: 10),
        child: SvgPicture.asset(icon, width: 55, height: 60),
      ),
      title: exam.title,
      subtitle: exam.instructor,
      meta: '${exam.questionsCount} ${AppStrings.questionsUnit}',
    );
  }
}
