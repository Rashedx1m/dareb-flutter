import '../../domain/entities/subject.dart';

/// مادة كما يعيدها `subjects/all`: `{id, name, is_free, image, is_subscription}`.
/// الأعلام منطقية (`true`/`false`) لا 0/1، والصورة رابط كامل دائماً.
class SubjectModel extends Subject {
  const SubjectModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.isFree,
    required super.isSubscribed,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: '${json['id']}',
      name: json['name'] as String,
      imageUrl: json['image'] as String,
      isFree: json['is_free'] as bool,
      isSubscribed: json['is_subscription'] as bool,
    );
  }
}
