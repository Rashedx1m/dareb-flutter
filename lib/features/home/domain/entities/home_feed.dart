import 'package:equatable/equatable.dart';

import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/entities/subject.dart';
import 'home_banner.dart';
import 'news_item.dart';

/// محتوى الصفحة الرئيسية كما يجمعه `home-page/index`.
class HomeFeed extends Equatable {
  const HomeFeed({
    required this.sliders,
    required this.subjects,
    required this.news,
    required this.courses,
    required this.completionRate,
    required this.subjectCount,
  });

  final List<HomeBanner> sliders;
  final List<Subject> subjects;
  final List<NewsItem> news;
  final List<Course> courses;

  /// نسبة إنجاز المنهاج بين 0 و1، من `completion_rate` المئوية.
  final double completionRate;

  /// عدد مواد المستخدم المعروض في بطاقة التقدم.
  final int subjectCount;

  @override
  List<Object?> get props => [sliders, subjects, news, courses, completionRate, subjectCount];
}
