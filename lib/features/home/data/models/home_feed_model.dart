import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/entities/subject.dart';
import '../../domain/entities/home_feed.dart';
import 'home_banner_model.dart';
import 'news_item_model.dart';

/// رد `home-page/index` كما أعاده خادم التدريب في 2026-10-16:
/// `{sliders, subjects, news, courses, notification_unread, completion_rate, subject_count}`.
/// `notification_unread` لا مكان له في تصميم الترويسة فيُترك.
class HomeFeedModel extends HomeFeed {
  const HomeFeedModel({
    required super.sliders,
    required super.subjects,
    required super.news,
    required super.courses,
    required super.completionRate,
    required super.subjectCount,
  });

  factory HomeFeedModel.fromJson(Map<String, dynamic> json) {
    return HomeFeedModel(
      sliders: [
        for (final item in (json['sliders'] as List).cast<Map<String, dynamic>>()) HomeBannerModel.fromJson(item),
      ],
      subjects: [
        for (final item in (json['subjects'] as List).cast<Map<String, dynamic>>()) _subject(item),
      ],
      news: [
        for (final item in (json['news'] as List).cast<Map<String, dynamic>>()) NewsItemModel.fromJson(item),
      ],
      courses: [
        for (final item in (json['courses'] as List).cast<Map<String, dynamic>>()) _course(item),
      ],
      // الخادم يرسل عدداً صحيحاً 0–100 مثل `semester_rate`.
      completionRate: (json['completion_rate'] as num).toInt() / 100,
      subjectCount: json['subject_count'] as int,
    );
  }

  /// نفس حقول `subjects/all`: `{id, name, is_free, image, is_subscription}`.
  static Subject _subject(Map<String, dynamic> json) {
    return Subject(
      id: '${json['id']}',
      name: json['name'] as String,
      imageUrl: json['image'] as String,
      isFree: json['is_free'] as bool,
      isSubscribed: json['is_subscription'] as bool,
    );
  }

  /// نفس حقول بطاقة `courses/paginate`.
  static Course _course(Map<String, dynamic> json) {
    return Course(
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
