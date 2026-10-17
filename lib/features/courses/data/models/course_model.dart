import '../../domain/entities/course.dart';

/// بطاقة المادة كما يعيدها `courses/paginate` و`courses/details` و`subscriptions/my`:
/// العنوان في `course_name` واسم المادة في `name`. العدّادات والسعر والنسب أعداد
/// صحيحة، والأعلام منطقية. `subject_rate` و`points_count` و`point_rate` تظهر في
/// `courses/details` وقد تغيب عن القائمة فتصير 0. `story_*` لتفاصيل الدورة.
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
    required super.semesterRate,
    required super.lessonsCount,
    required super.lessonRate,
    required super.subscriptionsCount,
    required super.isFree,
    required super.isSubscribed,
    super.subjectRate,
    super.pointsCount,
    super.pointRate,
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
      semesterRate: json['semester_rate'] as int,
      lessonsCount: json['lessions_count'] as int,
      lessonRate: json['lession_rate'] as int,
      subscriptionsCount: json['subscriptions_count'] as int,
      isFree: json['is_free'] as bool,
      isSubscribed: json['is_subscription'] as bool,
      subjectRate: (json['subject_rate'] as num?)?.toInt() ?? 0,
      pointsCount: (json['points_count'] as num?)?.toInt() ?? 0,
      pointRate: (json['point_rate'] as num?)?.toInt() ?? 0,
    );
  }
}
