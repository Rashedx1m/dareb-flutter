import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/courses_bloc.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        final details = state.selected;
        if (details == null || details.course.id != courseId) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final course = details.course;
        final lessons = [for (final semester in details.semesters) ...semester.lessons];
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: course.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const ColoredBox(color: AppColors.primary),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.subjectName, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(course.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(course.instructor, style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _Meta(Icons.play_circle_outline, '${course.lessonsCount} درس', AppColors.primary),
                          const SizedBox(width: 16),
                          _Meta(Icons.group_outlined, '${course.subscriptionsCount}', AppColors.navy),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(course.description, style: const TextStyle(height: 1.6, color: AppColors.textSecondary)),
                      const SizedBox(height: 20),
                      const Text('الدروس', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      ...lessons.map(
                        (lesson) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primarySoft,
                            child: Icon(
                              lesson.isLocked ? Icons.lock_outline : Icons.play_arrow_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(lesson.duration ?? ''),
                          onTap: lesson.isLocked
                              ? null
                              : () => context.push('/courses/${course.id}/video/${lesson.id}'),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: AppButton(
                label: course.isSubscribed && lessons.isNotEmpty
                    ? AppStrings.startLesson
                    : '${AppStrings.subscribe} · ${course.price.toInt()} ${AppStrings.currency}',
                onPressed: () {
                  if (course.isSubscribed && lessons.isNotEmpty) {
                    context.push('/courses/${course.id}/video/${lessons.first.id}');
                  } else {
                    context.push('/subscription');
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
