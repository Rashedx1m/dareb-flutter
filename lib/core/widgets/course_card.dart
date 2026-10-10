import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../features/courses/domain/entities/course.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.horizontal = false,
  });

  final Course course;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return _HorizontalCard(course: course, onTap: onTap);
    }
    return _VerticalCard(course: course, onTap: onTap);
  }
}

class _VerticalCard extends StatelessWidget {
  const _VerticalCard({required this.course, required this.onTap});
  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: course.imageUrl,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: AppColors.primarySoft),
              errorWidget: (_, _, _) => const ColoredBox(
                color: AppColors.primarySoft,
                child: Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 36),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.subjectName,
                    style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        '${course.price.toInt()} ${AppStrings.currency}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalCard extends StatelessWidget {
  const _HorizontalCard({required this.course, required this.onTap});
  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: course.imageUrl,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => const ColoredBox(
            color: AppColors.primarySoft,
            child: Icon(Icons.menu_book_rounded, color: AppColors.primary),
          ),
        ),
      ),
      title: Text(course.title, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
      subtitle: Text(
        '${course.instructor} · ${course.lessonsCount} ${AppStrings.lessonsLabel}',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_left),
    );
  }
}
