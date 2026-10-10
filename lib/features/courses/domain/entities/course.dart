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
    required this.lessonsCount,
    required this.subscriptionsCount,
    required this.isFree,
    required this.isSubscribed,
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
  final int lessonsCount;
  final int subscriptionsCount;
  final bool isFree;
  final bool isSubscribed;

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
        lessonsCount,
        subscriptionsCount,
        isFree,
        isSubscribed,
      ];
}
