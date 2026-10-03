import 'package:equatable/equatable.dart';

/// نوع البطاقة في شاشة «اختباراتي»: اختبار أو نشاط يومي (تبويبان بنفس الشكل).
enum QuizKind { test, activity }

class Quiz extends Equatable {
  const Quiz({
    required this.id,
    required this.title,
    required this.courseTitle,
    required this.instructor,
    required this.questionsCount,
    required this.durationMinutes,
    required this.participants,
    required this.progress,
    required this.questions,
    this.kind = QuizKind.test,
  });

  final String id;
  final String title;
  final String courseTitle;
  final String instructor;
  final int questionsCount;
  final int durationMinutes;

  /// العدد المعروض بجانب أيقونة الأكوام في البطاقة (مثل «22»).
  final int participants;
  final double progress;
  final List<QuizQuestion> questions;
  final QuizKind kind;

  @override
  List<Object?> get props => [id, title];
}

class QuizQuestion extends Equatable {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;

  @override
  List<Object?> get props => [id, text];
}
