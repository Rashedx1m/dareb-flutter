import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// يفتح رابطاً خارج التطبيق، ويعيد `false` إن تعذّر فتحه.
typedef LinkOpener = Future<bool> Function(Uri uri);

/// التطبيق المناسب للرابط (فيسبوك، واتساب...) أو المتصفح إن لم يوجد.
/// على Windows وضع `externalApplication` قد يجمّد الواجهة حتى يُفتح المتصفح.
Future<bool> openExternalLink(Uri uri) async {
  final mode = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows
      ? LaunchMode.platformDefault
      : LaunchMode.externalApplication;
  try {
    return await launchUrl(uri, mode: mode).timeout(const Duration(seconds: 8), onTimeout: () => false);
  } catch (_) {
    // لا تطبيق يفتح الرابط على الجهاز، أو رابط غير صالح.
    return false;
  }
}
