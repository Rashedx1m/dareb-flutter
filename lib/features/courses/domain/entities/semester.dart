import 'package:equatable/equatable.dart';

import 'lesson.dart';

/// فصل من الدورة، وتحته دروسه بالترتيب الذي يرسله الخادم.
class Semester extends Equatable {
  const Semester({
    required this.id,
    required this.name,
    required this.isFree,
    required this.price,
    required this.lessonsCount,
    required this.isSubscribed,
    required this.lessons,
  });

  final String id;
  final String name;
  final bool isFree;

  /// بالليرة السورية.
  final double price;
  final int lessonsCount;
  final bool isSubscribed;
  final List<Lesson> lessons;

  @override
  List<Object?> get props => [id, name, isFree, price, lessonsCount, isSubscribed, lessons];
}
