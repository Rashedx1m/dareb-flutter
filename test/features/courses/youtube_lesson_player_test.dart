import 'package:educational_app/features/courses/presentation/widgets/youtube_lesson_player.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

YoutubeWebResourceError _error(String url, {bool? mainFrame = false}) {
  return YoutubeWebResourceError(
    errorCode: -2,
    description: 'net::ERR_NAME_NOT_RESOLVED',
    url: url,
    isForMainFrame: mainFrame,
  );
}

void main() {
  test('فشل الصفحة أو إطار الفيديو أو سكربتي يوتيوب يوقف المشغّل', () {
    // الإطار كما فشل على الهاتف في 2026-10-18، بلا معرّف الفيديو في مساره.
    expect(isPlayerLoadError(_error('https://www.youtube-nocookie.com/embed/?autoplay=1&enablejsapi=1')), isTrue);
    expect(isPlayerLoadError(_error('https://www.youtube.com/embed/q0zaEGbs-cE')), isTrue);
    expect(isPlayerLoadError(_error('https://www.youtube.com/iframe_api')), isTrue);
    expect(
      isPlayerLoadError(_error('https://www.youtube.com/s/player/0229cd64/www-widgetapi.vflset/www-widgetapi.js')),
      isTrue,
    );
    expect(isPlayerLoadError(_error('https://www.youtube.com/', mainFrame: true)), isTrue);
  });

  test('فشل صورة أو إعلان أو إحصاء لا يوقفه', () {
    expect(isPlayerLoadError(_error('https://i.ytimg.com/vi/q0zaEGbs-cE/hqdefault.jpg')), isFalse);
    expect(isPlayerLoadError(_error('https://googleads.g.doubleclick.net/pagead/id')), isFalse);
    expect(isPlayerLoadError(_error('https://www.youtube.com/api/stats/qoe?x=1', mainFrame: null)), isFalse);
  });
}
