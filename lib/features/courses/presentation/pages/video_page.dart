import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/utils/external_link.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_details.dart';
import '../cubit/lesson_cubit.dart';
import '../lesson_access.dart';
import '../widgets/youtube_lesson_player.dart';

/// صفحة الدرس. فيديو يوتيوب يعمل داخل التطبيق، ويُفتح خارجياً إن تعذّر المشغّل.
/// الملف يُفتح خارجياً، وطريق التشغيل عبر الخادم (`yt-dlp`) يرد 500.
class VideoPage extends StatelessWidget {
  const VideoPage({
    super.key,
    required this.courseId,
    required this.lessonId,
    this.openLink = openExternalLink,
    this.playerBuilder = youtubeLessonPlayer,
  });

  /// معرّف المادة من المسار، للانتقال إلى دروس الفصل الأخرى.
  final String courseId;
  final String lessonId;

  /// يُستبدل في الاختبارات حتى لا يُفتح رابط حقيقي.
  final LinkOpener openLink;

  /// يُستبدل في الاختبارات، لأن WebView لا يعمل داخل `flutter test`.
  final LessonPlayerBuilder playerBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonCubit, LessonState>(
      builder: (context, state) => switch (state.status) {
        LessonStatus.success => _LessonView(
            courseId: courseId,
            details: state.details!,
            openLink: openLink,
            playerBuilder: playerBuilder,
          ),
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

class _LessonView extends StatefulWidget {
  const _LessonView({
    required this.courseId,
    required this.details,
    required this.openLink,
    required this.playerBuilder,
  });

  final String courseId;
  final LessonDetails details;
  final LinkOpener openLink;
  final LessonPlayerBuilder playerBuilder;

  @override
  State<_LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<_LessonView> {
  /// يوقف تكرار طلب الحضور مع كل استئناف للتشغيل.
  bool _attendRequested = false;
  bool _playerFailed = false;

  void _attendOnce() {
    if (_attendRequested) return;
    _attendRequested = true;
    context.read<LessonCubit>().attend();
  }

  Future<void> _open(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(url);
    final opened = uri != null && await widget.openLink(uri);
    if (!mounted) return;
    if (opened) {
      _attendOnce();
    } else {
      messenger.showSnackBar(const SnackBar(content: Text(AppStrings.linkOpenError)));
    }
  }

  Widget _playerArea(Lesson lesson) {
    if (lesson.isLocked) return const _LockedNotice();
    final videoUrl = lesson.videoUrl;
    if (lesson.type == LessonType.video && videoUrl != null) {
      final videoId = YoutubePlayerController.convertUrlToId(videoUrl);
      if (videoId == null || _playerFailed || !youtubePlayerSupported()) {
        return _WatchOnYoutube(onTap: () => _open(videoUrl));
      }
      return widget.playerBuilder(
        videoId: videoId,
        onPlaying: _attendOnce,
        onError: () {
          if (mounted && !_playerFailed) setState(() => _playerFailed = true);
        },
      );
    }
    final fileUrl = lesson.type == LessonType.file ? lesson.fileUrl : null;
    return Material(
      color: AppColors.videoBackground,
      child: InkWell(
        onTap: fileUrl == null ? null : () => _open(fileUrl),
        child: Center(
          child: CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary,
            child: Icon(_playerIcon(lesson), color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    final lesson = details.lesson;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(lesson.title),
      ),
      body: Column(
        children: [
          AspectRatio(aspectRatio: 16 / 9, child: _playerArea(lesson)),
          // Material لا Container ملوّن: دروس القائمة تستجيب للضغط، وأثر الضغط يُرسم
          // على أقرب Material.
          Expanded(
            child: Material(
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
                      onTap: _onLessonTap(item, current: lesson),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// درس آخر يُفتح مكان الحالي (لا يتراكم في سجل الرجوع)، والمقفل يشرح سببه.
  /// الدرس الحالي والاختبار لا يستجيبان.
  VoidCallback? _onLessonTap(Lesson item, {required Lesson current}) {
    if (item.id == current.id) return null;
    if (canOpenLesson(item)) {
      return () => context.pushReplacement('/courses/${widget.courseId}/video/${item.id}');
    }
    return item.isLocked ? () => showLockedLessonMessage(context) : null;
  }

  static IconData _playerIcon(Lesson lesson) {
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

class _LockedNotice extends StatelessWidget {
  const _LockedNotice();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.videoBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text(
              AppStrings.subscribersOnlyLesson,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchOnYoutube extends StatelessWidget {
  const _WatchOnYoutube({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.videoBackground,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(PhosphorIconsRegular.youtubeLogo),
          label: const Text(AppStrings.watchOnYoutube),
        ),
      ),
    );
  }
}
