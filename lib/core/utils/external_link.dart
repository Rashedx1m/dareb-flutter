import 'package:url_launcher/url_launcher.dart';

/// يفتح رابطاً خارج التطبيق، ويعيد `false` إن تعذّر فتحه.
typedef LinkOpener = Future<bool> Function(Uri uri);

/// التطبيق المناسب للرابط (فيسبوك، واتساب...) أو المتصفح إن لم يوجد.
Future<bool> openExternalLink(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // لا تطبيق يفتح الرابط على الجهاز، أو رابط غير صالح.
    return false;
  }
}
