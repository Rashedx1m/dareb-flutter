import '../../domain/entities/course.dart';

/// بطاقة المادة كما يعيدها `courses/paginate` و`courses/details`: العنوان في
/// `course_name` واسم المادة في `name`. العدّادات والسعر أعداد صحيحة، والأعلام
/// منطقية. تحمل أيضاً `story_*` و`*_rate` و`points_count`، ولا شاشة تعرضها.
class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.subjectName,
    required super.instructor,
    required super.description,
    required super.imageUrl,
    required super.price,
    required super.semestersCount,
    required super.lessonsCount,
    required super.subscriptionsCount,
    required super.isFree,
    required super.isSubscribed,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: '${json['id']}',
      title: json['course_name'] as String,
      subjectName: json['name'] as String,
      instructor: json['professor'] as String,
      description: json['text'] as String,
      imageUrl: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      semestersCount: json['semesters_count'] as int,
      lessonsCount: json['lessions_count'] as int,
      subscriptionsCount: json['subscriptions_count'] as int,
      isFree: json['is_free'] as bool,
      isSubscribed: json['is_subscription'] as bool,
    );
  }
}
