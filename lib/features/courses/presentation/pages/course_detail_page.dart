import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/course_details.dart';
import '../../domain/entities/lesson.dart';
import '../cubit/course_details_cubit.dart';
import '../lesson_access.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
      builder: (context, state) => switch (state.status) {
        CourseDetailsStatus.failure => Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              message: state.error,
              onRetry: () => context.read<CourseDetailsCubit>().load(courseId),
            ),
          ),
        CourseDetailsStatus.success => _CourseView(details: state.details!),
        _ => const Scaffold(body: LoadingView()),
      },
    );
  }
}

class _CourseView extends StatelessWidget {
  const _CourseView({required this.details});

  final CourseDetails details;

  @override
  Widget build(BuildContext context) {
    final course = details.course;
    final semesters = details.semesters.where((s) => s.lessons.isNotEmpty).toList();
    final firstOpenable = [
      for (final semester in semesters) ...semester.lessons,
    ].where(canOpenLesson).firstOrNull;
    // الدورة المدفوعة بلا اشتراك تعرض زر الاشتراك حتى إن كان فيها درس مجاني للتجربة،
    // فهو يُفتح من القائمة. أما المجانية فتبدأ مباشرة.
    final canStart = (course.isSubscribed || course.isFree) && firstOpenable != null;

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
                      _Meta(
                        Icons.play_circle_outline,
                        '${course.lessonsCount} ${AppStrings.lessonsLabel}',
                        AppColors.primary,
                      ),
                      const SizedBox(width: 16),
                      _Meta(Icons.group_outlined, '${course.subscriptionsCount}', AppColors.navy),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(course.description, style: const TextStyle(height: 1.6, color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  const Text(AppStrings.lessonsTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  if (semesters.isEmpty)
                    const Text(AppStrings.noLessons, style: TextStyle(color: AppColors.textSecondary)),
                  for (final semester in semesters) ...[
                    const SizedBox(height: 8),
                    Text(semester.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    for (final lesson in semester.lessons)
                      _LessonTile(
                        lesson: lesson,
                        onTap: canOpenLesson(lesson)
                            ? () => context.push('/courses/${course.id}/video/${lesson.id}')
                            : lesson.isLocked
                                ? () => showLockedLessonMessage(context)
                                : null,
                      ),
                  ],
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
            label: canStart
                ? AppStrings.startLesson
                : '${AppStrings.subscribe} · ${course.price.toInt()} ${AppStrings.currency}',
            onPressed: () {
              if (canStart) {
                context.push('/courses/${course.id}/video/${firstOpenable.id}');
              } else {
                context.push('/subscription');
              }
            },
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.onTap});

  final Lesson lesson;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = lesson.isLocked
        ? Icons.lock_outline
        : switch (lesson.type) {
            LessonType.video => PhosphorIconsFill.playCircle,
            LessonType.file => PhosphorIconsFill.filePdf,
            LessonType.exam => PhosphorIconsRegular.exam,
          };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primarySoft,
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(lesson.type == LessonType.exam ? AppStrings.examLesson : lesson.duration ?? ''),
      onTap: onTap,
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
