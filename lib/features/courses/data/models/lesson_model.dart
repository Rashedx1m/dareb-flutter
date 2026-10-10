import '../../domain/entities/lesson.dart';

/// درس كما يأتي داخل `semesters[].lessions`. النوع في `type.id`:
/// 1 File (`time` و`file`)، و2 Video (`time` و`url`، و`drive_link_*` كانت `null`
/// دائماً)، و3 Exam (`exam` كائن أو `null`، ويغيب المفتاح في `lessions/details`).
class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.title,
    required super.type,
    super.duration,
    super.videoUrl,
    super.fileUrl,
    required super.order,
    required super.isFree,
    required super.isSubscribed,
    required super.isAttended,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final type = _types[(json['type'] as Map<String, dynamic>)['id']];
    if (type == null) throw const FormatException('نوع درس غير معروف');
    return LessonModel(
      id: '${json['id']}',
      title: json['name'] as String,
      type: type,
      duration: json['time'] as String?,
      videoUrl: json['url'] as String?,
      fileUrl: json['file'] as String?,
      order: json['order'] as int,
      isFree: json['is_free'] as bool,
      isSubscribed: json['is_subscription'] as bool,
      isAttended: json['is_attended'] as bool,
    );
  }

  static const _types = {1: LessonType.file, 2: LessonType.video, 3: LessonType.exam};
}
