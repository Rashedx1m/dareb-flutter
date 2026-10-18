import '../../domain/entities/downloaded_file.dart';

/// الملفات المحفوظة على الجهاز. يرمي `CacheException` عند تعذّر قراءتها.
abstract class DownloadsLocalDataSource {
  Future<List<DownloadedFile>> getDownloads();
}

/// تنفيذ تجريبي ببيانات التصميم، يُستبدل بالتخزين الفعلي حين تُبنى ميزة التنزيل.
class DownloadsMockDataSource implements DownloadsLocalDataSource {
  const DownloadsMockDataSource();

  static const _title = 'مقدمة الإحصاء 4';

  /// زمن قراءة محاكى حتى يظهر التحميل.
  static const _latency = Duration(milliseconds: 250);

  @override
  Future<List<DownloadedFile>> getDownloads() async {
    await Future<void>.delayed(_latency);
    return const [
      DownloadedFile(id: 'd1', title: _title, chapter: 1, kind: DownloadKind.video, duration: '22:30'),
      DownloadedFile(id: 'd2', title: _title, chapter: 2, kind: DownloadKind.pdf, pages: 40),
      DownloadedFile(id: 'd3', title: _title, chapter: 2, kind: DownloadKind.video, duration: '22:30'),
      DownloadedFile(id: 'd4', title: _title, chapter: 1, kind: DownloadKind.video, duration: '22:30'),
      DownloadedFile(id: 'd5', title: _title, chapter: 2, kind: DownloadKind.pdf, pages: 40),
      DownloadedFile(id: 'd6', title: _title, chapter: 2, kind: DownloadKind.video, duration: '22:30'),
      DownloadedFile(id: 'd7', title: _title, chapter: 1, kind: DownloadKind.video, duration: '22:30'),
      DownloadedFile(id: 'd8', title: _title, chapter: 2, kind: DownloadKind.pdf, pages: 40),
    ];
  }
}
