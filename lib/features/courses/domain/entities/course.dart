import 'package:equatable/equatable.dart';

/// بطاقة دورة من `courses/paginate`. الخادم لا يفصل الدورة عن مادتها: [id] هو
/// معرّف المادة، وبه تُطلب تفاصيل الدورة.
class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.instructor,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.semestersCount,
    required this.semesterRate,
    required this.lessonsCount,
    required this.lessonRate,
    required this.subscriptionsCount,
    required this.isFree,
    required this.isSubscribed,
    this.subjectRate = 0,
    this.pointsCount = 0,
    this.pointRate = 0,
  });

  final String id;
  final String title;
  final String subjectName;

  /// قد يكون فارغاً إن لم يُسجَّل اسم الأستاذ.
  final String instructor;
  final String description;
  final String imageUrl;

  /// بالليرة السورية، و0 للدورة المجانية.
  final double price;

  /// عدد الفصول، وهي وحدات الدورة التي تُجمع تحتها الدروس.
  final int semestersCount;

  /// نسبة مئوية (0 إلى 100) يحسبها الخادم من فصول المادة. ظهرت 75 لمادة من 4
  /// فصول لم يُحضر فيها أي درس، فهي لا تعني بالضرورة فصولاً منتهية.
  final int semesterRate;
  final int lessonsCount;

  /// نسبة الدروس المحضورة من دروس المادة، من 0 إلى 100.
  final int lessonRate;
  final int subscriptionsCount;
  final bool isFree;
  final bool isSubscribed;

  /// نسبة إنجاز المادة من 0 إلى 100. قد تغيب عن `courses/paginate` فتُحسب 0.
  final int subjectRate;

  /// مجموع نقاط المادة، و`point_rate` نسبتها المكتسبة. يظهران في `courses/details`
  /// وقد يغيبان عن بطاقة القائمة.
  final int pointsCount;
  final int pointRate;

  @override
  List<Object?> get props => [
        id,
        title,
        subjectName,
        instructor,
        description,
        imageUrl,
        price,
        semestersCount,
        semesterRate,
        lessonsCount,
        lessonRate,
        subscriptionsCount,
        isFree,
        isSubscribed,
        subjectRate,
        pointsCount,
        pointRate,
      ];
}
