import 'package:equatable/equatable.dart';

enum LessonType { video, file, exam }

/// درس داخل فصل. الفيديو يحمل [videoUrl]، والملف [fileUrl]، والاختبار لا رابط له.
class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.type,
    this.duration,
    this.videoUrl,
    this.fileUrl,
    required this.order,
    required this.isFree,
    required this.isSubscribed,
    required this.isAttended,
  });

  final String id;
  final String title;
  final LessonType type;

  /// المدة كما يرسلها الخادم "HH:MM:SS"، و`null` لدرس الاختبار.
  final String? duration;
  final String? videoUrl;
  final String? fileUrl;

  /// ترتيب الدرس في فصله، وقد يتكرر أو يبدأ من 0.
  final int order;
  final bool isFree;
  final bool isSubscribed;
  final bool isAttended;

  /// مستنتج من الأعلام فقط: الخادم لا يمنع فتح رابط درس مقفل.
  bool get isLocked => !isFree && !isSubscribed;

  @override
  List<Object?> get props =>
      [id, title, type, duration, videoUrl, fileUrl, order, isFree, isSubscribed, isAttended];
}
