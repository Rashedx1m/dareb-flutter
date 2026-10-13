import 'package:equatable/equatable.dart';

import 'course.dart';

/// صفحة المادة بتبويباتها الثلاثة، من `subjects/details`: دورتها (المحتوى)،
/// واختباراتها، ونشاطاتها اليومية.
class SubjectDetails extends Equatable {
  const SubjectDetails({
    required this.course,
    required this.pointsCount,
    required this.exams,
    required this.activities,
  });

  /// الخادم يجعل المادة دورة واحدة، فتبويب «المحتوى» بطاقة واحدة.
  final Course course;
  final int pointsCount;
  final List<SubjectExam> exams;
  final List<SubjectExam> activities;

  @override
  List<Object?> get props => [course, pointsCount, exams, activities];
}

/// اختبار أو نشاط يومي في مادة.
class SubjectExam extends Equatable {
  const SubjectExam({
    required this.id,
    required this.title,
    required this.instructor,
    required this.questionsCount,
    required this.isFree,
    required this.isSubscribed,
  });

  /// معرّف الاختبار نفسه، لا رقم ربطه بالمادة.
  final String id;
  final String title;

  /// قد يكون فارغاً.
  final String instructor;
  final int questionsCount;
  final bool isFree;
  final bool isSubscribed;

  @override
  List<Object?> get props => [id, title, instructor, questionsCount, isFree, isSubscribed];
}
