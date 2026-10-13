import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/utils/external_link.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_details.dart';
import '../../domain/entities/lesson.dart';
import '../cubit/course_details_cubit.dart';
import '../lesson_access.dart';
import '../lesson_path.dart';
import '../widgets/course_header.dart';
import '../widgets/course_story_dialog.dart';
import '../widgets/learning_path.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.courseId, this.openLink = openExternalLink});

  final String courseId;

  /// يفتح ملف الدرس من زر التنزيل، ويُستبدل في الاختبارات.
  final LinkOpener openLink;

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
        CourseDetailsStatus.success => _CourseView(details: state.details!, openLink: openLink),
        _ => const Scaffold(body: LoadingView()),
      },
    );
  }
}

class _CourseView extends StatefulWidget {
  const _CourseView({required this.details, required this.openLink});

  final CourseDetails details;
  final LinkOpener openLink;

  @override
  State<_CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<_CourseView> {
  Course get _course => widget.details.course;

  @override
  void initState() {
    super.initState();
    if (widget.details.hasStory) WidgetsBinding.instance.addPostFrameCallback((_) => _showStory());
  }

  void _showStory() {
    if (!mounted) return;
    final details = widget.details;
    showCourseStory(
      context,
      imageUrl: details.storyImageUrl,
      text: details.storyText,
      onStart: () {
        // «ابدأ الآن» يفتح الدرس الذي عليه «قيد التشغيل»، إن وُجد.
        final current = [
          for (final (_, lessons) in learningPath(details.semesters)) ...lessons,
        ].where((item) => item.isCurrent).firstOrNull;
        if (current != null) _openLesson(current.lesson);
      },
    );
  }

  Future<void> _openLesson(Lesson lesson) async {
    final cubit = context.read<CourseDetailsCubit>();
    await context.push('/courses/${_course.id}/video/${lesson.id}');
    // الحضور يُسجَّل في صفحة الدرس، فتُحدَّث الدورة عند الرجوع.
    await cubit.refresh(_course.id);
  }

  void _onLessonTap(PathLesson item) {
    switch (item.step) {
      case LessonStep.open:
        _openLesson(item.lesson);
      case LessonStep.locked:
        showSubscribeDialog(context);
      case LessonStep.waiting:
        showFinishPreviousDialog(context, onStart: () => _openLesson(item.previous!));
      case LessonStep.exam:
        break;
    }
  }

  Future<void> _download(Lesson lesson) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(lesson.fileUrl ?? '');
    final opened = uri != null && await widget.openLink(uri);
    if (!opened && mounted) messenger.showSnackBar(const SnackBar(content: Text(AppStrings.linkOpenError)));
  }

  @override
  Widget build(BuildContext context) {
    final path = learningPath(widget.details.semesters);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 32),
          children: [
            CourseHeader(imageUrl: _course.imageUrl),
            _CourseInfo(course: _course, pointsCount: widget.details.pointsCount),
            const SizedBox(height: 18),
            const ColoredBox(color: AppColors.divider, child: SizedBox(height: 4)),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_course.description.trim().isNotEmpty) ...[
                    const Text(AppStrings.courseDescription, style: TextStyle(color: AppColors.primary, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      _course.description.trim(),
                      style: const TextStyle(color: AppColors.questionText, fontSize: 14, height: 1.75),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const LearningPathTitle(),
                  if (path.isEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(AppStrings.noLessons, style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            for (final (i, (semester, lessons)) in path.indexed) ...[
              if (i > 0) const SizedBox(height: 32),
              SemesterPath(
                semester: semester,
                lessons: lessons,
                onLessonTap: _onLessonTap,
                onDownload: _download,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// اسم الأستاذ ونقاط الدورة في البداية، واسم الدورة وعدد فصولها ودروسها في النهاية.
class _CourseInfo extends StatelessWidget {
  const _CourseInfo({required this.course, required this.pointsCount});

  final Course course;
  final int pointsCount;

  static const _teal = TextStyle(color: AppColors.primary, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (course.instructor.isNotEmpty) Text(course.instructor, style: _teal),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('$pointsCount', style: _teal),
                    const SizedBox(width: 4),
                    const Icon(PhosphorIconsRegular.coins, color: AppColors.iconBlue, size: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  course.title,
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w500, height: 1.4),
                ),
                const SizedBox(height: 10),
                Text(
                  '${course.semestersCount} ${AppStrings.chaptersLabel} , '
                  '${course.lessonsCount} ${AppStrings.lessonsLabel}',
                  style: const TextStyle(color: AppColors.questionText, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
