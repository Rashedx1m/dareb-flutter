import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/theme/app_colors.dart';

/// يبني مشغّل فيديو الدرس داخل مساحة 16:9. [onPlaying] عند كل انتقال إلى حالة
/// «يعمل»، و[onError] حين يرفض يوتيوب التشغيل (فيديو محذوف، أو منع صاحبه
/// التضمين) أو يتعذّر تحميل المشغّل نفسه.
typedef LessonPlayerBuilder = Widget Function({
  required String videoId,
  required VoidCallback onPlaying,
  required VoidCallback onError,
});

/// المشغّل يعمل على WebView، ولا تنفيذ له على Windows وLinux.
bool youtubePlayerSupported() =>
    kIsWeb ||
    const {TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS}.contains(defaultTargetPlatform);

/// فشل تحميل ما لا يعمل المشغّل بدونه: الصفحة، وسكربتا واجهة يوتيوب، وإطار
/// الفيديو. فشل غيرها (صورة أو إعلان) لا يوقف التشغيل.
bool isPlayerLoadError(YoutubeWebResourceError error) {
  if (error.isForMainFrame ?? false) return true;
  final path = Uri.tryParse(error.url ?? '')?.path ?? '';
  return path == '/iframe_api' || path.startsWith('/embed') || path.endsWith('/www-widgetapi.js');
}

Widget youtubeLessonPlayer({
  required String videoId,
  required VoidCallback onPlaying,
  required VoidCallback onError,
}) {
  return YoutubeLessonPlayer(key: ValueKey(videoId), videoId: videoId, onPlaying: onPlaying, onError: onError);
}

/// مشغّل `youtube_player_iframe`: متحكم واحد لكل درس يُغلق مع الصفحة. ملء الشاشة
/// وتدوير الجهاز يديرهما [YoutubePlayer] نفسه.
class YoutubeLessonPlayer extends StatefulWidget {
  const YoutubeLessonPlayer({
    super.key,
    required this.videoId,
    required this.onPlaying,
    required this.onError,
  });

  final String videoId;
  final VoidCallback onPlaying;
  final VoidCallback onError;

  @override
  State<YoutubeLessonPlayer> createState() => _YoutubeLessonPlayerState();
}

class _YoutubeLessonPlayerState extends State<YoutubeLessonPlayer> {
  late final YoutubePlayerController _controller;
  late final StreamSubscription<YoutubePlayerValue> _subscription;
  PlayerState _lastState = PlayerState.unknown;

  @override
  void initState() {
    super.initState();
    // يُبنى بعد ضغط الطالب على غلاف الدرس، فيبدأ مباشرة. الإطار من youtube.com لا
    // youtube-nocookie.com: سكربت المشغّل يأتي من youtube.com أصلاً، فلا يتوقف
    // التشغيل على نطاق ثانٍ. على هاتف حقيقي لم يُحَلّ youtube-nocookie.com
    // (net::ERR_NAME_NOT_RESOLVED، 2026-10-18) فبقي المشغّل أسود بلا رسالة.
    _controller = YoutubePlayerController(
      key: widget.videoId,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        interfaceLanguage: 'ar',
        privacyEnhancedMode: false,
      ),
      onWebResourceError: (error) {
        if (isPlayerLoadError(error)) _fail();
      },
    )..loadVideoById(videoId: widget.videoId);
    _subscription = _controller.listen(_onValue);
  }

  /// بعد الإطار الحالي حتى لا يُعاد بناء الصفحة أثناء إنشاء المشغّل فيعلّق. والخطأ
  /// قد يصل والشاشة ساكنة، فيُطلب إطار.
  void _fail() {
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        if (mounted) widget.onError();
      })
      ..ensureVisualUpdate();
  }

  void _onValue(YoutubePlayerValue value) {
    if (value.hasError) {
      _fail();
      return;
    }
    if (value.playerState == PlayerState.playing && _lastState != PlayerState.playing) {
      widget.onPlaying();
    }
    _lastState = value.playerState;
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(controller: _controller, backgroundColor: AppColors.videoBackground);
  }
}
