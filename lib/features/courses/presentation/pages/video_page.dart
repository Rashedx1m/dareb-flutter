import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/external_link.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_details.dart';
import '../cubit/lesson_cubit.dart';
import '../lesson_access.dart';
import '../lesson_path.dart';
import '../widgets/learning_path.dart';
import '../widgets/lesson_discussions.dart';
import '../widgets/lesson_media.dart';
import '../widgets/youtube_lesson_player.dart';

/// صفحة الدرس كما في التصميم: مساحة الفيديو أو الملف في الأعلى، ثم «النقاشات»، ثم
/// «مسار التعلم» لفصل الدرس. فيديو يوتيوب يعمل داخل التطبيق بعد الضغط على غلافه،
/// ويُفتح خارجياً إن تعذّر المشغّل. الملف يُفتح خارجياً، وطريق التشغيل عبر الخادم
/// (`yt-dlp`) يرد 500.
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
      buildWhen: (previous, current) => previous.status != current.status || previous.details != current.details,
      builder: (context, state) => switch (state.status) {
        LessonStatus.success => _LessonView(
            courseId: courseId,
            details: state.details!,
            openLink: openLink,
            playerBuilder: playerBuilder,
          ),
        LessonStatus.failure => _Frame(
            child: ErrorView(message: state.error, onRetry: () => context.read<LessonCubit>().load(lessonId)),
          ),
        _ => const _Frame(child: LoadingView()),
      },
    );
  }
}

/// التحميل والخطأ: مساحة الدرس الداكنة فارغة، وتحتها الرسالة.
class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const LessonMediaFrame(child: SizedBox.expand()),
            Expanded(child: child),
          ],
        ),
      ),
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
  final _comment = TextEditingController();

  /// يوقف تكرار طلب الحضور مع كل استئناف للتشغيل.
  bool _attendRequested = false;
  bool _playing = false;
  bool _playerFailed = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

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

  /// لا حزمة مشاركة في المشروع بعد، فيُنسخ رابط الدرس.
  Future<void> _share(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: url));
    messenger.showSnackBar(const SnackBar(content: Text(AppStrings.lessonLinkCopied)));
  }

  void _play(String videoUrl) {
    if (youtubePlayerSupported()) {
      setState(() => _playing = true);
    } else {
      _open(videoUrl);
    }
  }

  Widget _media(Lesson lesson) {
    if (lesson.isLocked) return const LockedCover();
    final videoUrl = lesson.videoUrl;
    if (lesson.type == LessonType.video && videoUrl != null) {
      final videoId = YoutubePlayerController.convertUrlToId(videoUrl);
      if (videoId == null || _playerFailed) return WatchOnYoutubeCover(onTap: () => _open(videoUrl));
      if (!_playing) {
        return VideoCover(
          lesson: lesson,
          videoId: videoId,
          onPlay: () => _play(videoUrl),
          onShare: () => _share(videoUrl),
        );
      }
      // المشغّل بنسبته 16:9 في أسفل المساحة، تحت شريط الحالة.
      return Align(
        alignment: Alignment.bottomCenter,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: widget.playerBuilder(
            videoId: videoId,
            onPlaying: _attendOnce,
            onError: () {
              if (mounted && !_playerFailed) setState(() => _playerFailed = true);
            },
          ),
        ),
      );
    }
    final fileUrl = lesson.type == LessonType.file ? lesson.fileUrl : null;
    if (fileUrl != null) return FileCover(onOpen: () => _open(fileUrl), onShare: () => _share(fileUrl));
    return const SizedBox.expand();
  }

  /// الدرس الحالي لا يستجيب، ودرس آخر يُفتح مكانه (لا يتراكم في سجل الرجوع).
  void _onPathTap(PathLesson item) {
    final current = widget.details.lesson;
    if (item.lesson.id == current.id) return;
    void open(Lesson lesson) {
      if (lesson.id != current.id) context.pushReplacement('/courses/${widget.courseId}/video/${lesson.id}');
    }

    switch (item.step) {
      case LessonStep.open:
        open(item.lesson);
      case LessonStep.locked:
        showSubscribeDialog(context);
      case LessonStep.waiting:
        showFinishPreviousDialog(context, onStart: () => open(item.previous!));
      case LessonStep.exam:
        break;
    }
  }

  void _onCommentStatus(BuildContext context, LessonState state) {
    switch (state.commentStatus) {
      case CommentStatus.done:
        _comment.clear();
        FocusScope.of(context).unfocus();
      case CommentStatus.failure:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.commentError ?? '')));
      case CommentStatus.idle || CommentStatus.sending:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    final lesson = details.lesson;
    final user = context.select((LessonCubit cubit) => cubit.state.user);
    final sending = context.select((LessonCubit cubit) => cubit.state.commentStatus == CommentStatus.sending);
    // «قيد التشغيل» في صفحة الدرس على الدرس المفتوح نفسه.
    final path = [
      for (final (_, lessons) in learningPath([details.semester]))
        for (final item in lessons)
          PathLesson(item.lesson, item.step, previous: item.previous, isCurrent: item.lesson.id == lesson.id),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<LessonCubit, LessonState>(
        listenWhen: (previous, current) => previous.commentStatus != current.commentStatus,
        listener: _onCommentStatus,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              LessonMediaFrame(
                clip: !_playing,
                child: _media(lesson),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 32),
                  children: [
                    const SizedBox(height: 46),
                    LessonDiscussions(
                      comments: details.comments,
                      user: user,
                      controller: _comment,
                      sending: sending,
                      onSend: () => context.read<LessonCubit>().sendComment(_comment.text),
                    ),
                    if (path.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: LearningPathTitle(),
                      ),
                      const SizedBox(height: 8),
                      SemesterPath(
                        semester: details.semester,
                        lessons: path,
                        onLessonTap: _onPathTap,
                        onDownload: (item) => _open(item.fileUrl!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
