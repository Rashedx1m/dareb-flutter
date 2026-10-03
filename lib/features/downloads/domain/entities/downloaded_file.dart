import 'package:equatable/equatable.dart';

enum DownloadKind { video, pdf }

/// درس أو ملخص محفوظ على الجهاز للمتابعة دون اتصال.
class DownloadedFile extends Equatable {
  const DownloadedFile({
    required this.id,
    required this.title,
    required this.chapter,
    required this.kind,
    this.duration,
    this.pages,
  });

  final String id;
  final String title;

  /// رقم الفصل الظاهر في المربع الأزرق.
  final int chapter;
  final DownloadKind kind;

  /// مدة الفيديو بالشكل "22:30".
  final String? duration;

  /// عدد صفحات الملف.
  final int? pages;

  @override
  List<Object?> get props => [id, title, chapter, kind, duration, pages];
}
