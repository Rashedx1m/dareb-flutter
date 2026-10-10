import '../../domain/entities/semester.dart';
import 'lesson_model.dart';

/// فصل كما يأتي في `courses/details` و`lessions/details`. قد يصل بلا دروس
/// (`lessions: []` و`lessions_count: 0`).
class SemesterModel extends Semester {
  const SemesterModel({
    required super.id,
    required super.name,
    required super.isFree,
    required super.price,
    required super.lessonsCount,
    required super.isSubscribed,
    required super.lessons,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: '${json['id']}',
      name: json['name'] as String,
      isFree: json['is_free'] as bool,
      price: (json['price'] as num).toDouble(),
      lessonsCount: json['lessions_count'] as int,
      isSubscribed: json['is_subscription'] as bool,
      lessons: [
        for (final lesson in (json['lessions'] as List).cast<Map<String, dynamic>>()) LessonModel.fromJson(lesson),
      ],
    );
  }
}
