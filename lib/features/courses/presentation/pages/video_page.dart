import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/utils/external_link.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_details.dart';
import '../cubit/lesson_cubit.dart';

/// صفحة الدرس. الفيديو والملف يُفتحان خارج التطبيق: روابط الفيديو من يوتيوب،
/// وطريق التشغيل الداخلي (`yt-dlp`) يرد 500.
class VideoPage extends StatelessWidget {
  const VideoPage({super.key, required this.lessonId, this.openLink = openExternalLink});

  final String lessonId;

  /// يُستبدل في الاختبارات حتى لا يُفتح رابط حقيقي.
  final LinkOpener openLink;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonCubit, LessonState>(
      builder: (context, state) => switch (state.status) {
        LessonStatus.success => _LessonView(details: state.details!, openLink: openLink),
        LessonStatus.failure => _Frame(
            title: AppStrings.lesson,
            child: ErrorView(message: state.error, onRetry: () => context.read<LessonCubit>().load(lessonId)),
          ),
        _ => const _Frame(title: AppStrings.lesson, child: LoadingView()),
      },
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Container(width: double.infinity, color: AppColors.background, child: child),
    );
  }
}

class _LessonView extends StatelessWidget {
  const _LessonView({required this.details, required this.openLink});

  final LessonDetails details;
  final LinkOpener openLink;

  Future<void> _open(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<LessonCubit>();
    final uri = Uri.tryParse(url);
    final opened = uri != null && await openLink(uri);
    if (opened) {
      cubit.attend();
    } else {
      messenger.showSnackBar(const SnackBar(content: Text(AppStrings.linkOpenError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = details.lesson;
    final url = lesson.isLocked
        ? null
        : switch (lesson.type) {
            LessonType.video => lesson.videoUrl,
            LessonType.file => lesson.fileUrl,
            LessonType.exam => null,
          };

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(lesson.title),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Material(
              color: AppColors.videoBackground,
              child: InkWell(
                onTap: url == null ? null : () => _open(context, url),
                child: Center(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: Icon(_playerIcon(lesson), color: Colors.white, size: 40),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.background,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(lesson.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(details.semester.name, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  const Text(AppStrings.semesterLessons, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  for (final item in details.semester.lessons)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        item.id == lesson.id ? Icons.pause_circle_filled : _listIcon(item),
                        color: AppColors.primary,
                      ),
                      title: Text(item.title),
                      trailing: Text(
                        item.type == LessonType.exam ? AppStrings.examLesson : item.duration ?? '',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _playerIcon(Lesson lesson) {
    if (lesson.isLocked) return Icons.lock_outline;
    return switch (lesson.type) {
      LessonType.video => Icons.play_arrow_rounded,
      LessonType.file => PhosphorIconsFill.filePdf,
      LessonType.exam => PhosphorIconsRegular.exam,
    };
  }

  static IconData _listIcon(Lesson lesson) {
    if (lesson.isLocked) return Icons.lock_outline;
    return switch (lesson.type) {
      LessonType.video => Icons.play_circle_outline,
      LessonType.file => PhosphorIconsFill.filePdf,
      LessonType.exam => PhosphorIconsRegular.exam,
    };
  }
}
