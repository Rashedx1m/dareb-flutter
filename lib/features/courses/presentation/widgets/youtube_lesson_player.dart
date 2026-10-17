import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/theme/app_colors.dart';

/// يبني مشغّل فيديو الدرس داخل مساحة 16:9. [onPlaying] عند كل انتقال إلى حالة
/// «يعمل»، و[onError] حين يرفض يوتيوب التشغيل (فيديو محذوف، أو منع صاحبه
/// التضمين).
typedef LessonPlayerBuilder = Widget Function({
  required String videoId,
  required VoidCallback onPlaying,
  required VoidCallback onError,
});

/// المشغّل يعمل على WebView، ولا تنفيذ له على Windows وLinux.
bool youtubePlayerSupported() =>
    kIsWeb ||
    const {TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS}.contains(defaultTargetPlatform);

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
    // يُبنى بعد ضغط الطالب على غلاف الدرس، فيبدأ مباشرة.
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: true, interfaceLanguage: 'ar'),
    );
    _subscription = _controller.listen(_onValue);
  }

  void _onValue(YoutubePlayerValue value) {
    if (value.hasError) {
      // بعد الإطار الحالي حتى لا يُعاد بناء الصفحة أثناء إنشاء المشغّل فيعلّق.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onError();
      });
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
