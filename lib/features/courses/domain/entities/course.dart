import 'package:equatable/equatable.dart';

class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.lessonsCount,
    this.chaptersCount = 0,
    required this.studentsCount,
    required this.rating,
    required this.price,
    required this.progress,
    required this.description,
    required this.lessons,
  });

  final String id;
  final String title;
  final String instructor;
  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final int lessonsCount;

  /// عدد الفصول/الوحدات في الدورة (يظهر بجانب عدد الدروس في بطاقة الدورة).
  final int chaptersCount;
  final int studentsCount;
  final double rating;
  final double price;
  final double progress;
  final String description;
  final List<Lesson> lessons;

  @override
  List<Object?> get props => [id, title, progress];
}

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.isLocked,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String duration;
  final bool isLocked;
  final bool isCompleted;

  @override
  List<Object?> get props => [id, title];
}

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.coursesCount,
  });

  final String id;
  final String name;
  final String icon;
  final int coursesCount;

  @override
  List<Object?> get props => [id, name];
}
