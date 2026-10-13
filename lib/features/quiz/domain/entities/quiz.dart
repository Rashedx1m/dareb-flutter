import 'package:equatable/equatable.dart';

/// نوع البطاقة في شاشة «اختباراتي».
enum QuizKind { test, activity }

/// بطاقة اختبار أو نشاط يومي في القائمة. الشكل الحقيقي لـ `/exams/my` لم يُرَ.
class Quiz extends Equatable {
  const Quiz({
    required this.id,
    required this.title,
    this.instructor = '',
    required this.questionsCount,
    this.kind = QuizKind.test,
  });

  final String id;
  final String title;

  /// قد يكون فارغاً؛ الحقل لم يُرَ في قائمة «اختباراتي».
  final String instructor;
  final int questionsCount;
  final QuizKind kind;

  @override
  List<Object?> get props => [id, title, instructor, questionsCount, kind];
}

/// اختبار كامل من `exams/result`: الأسئلة والعدّادات بعد الحضور أو قبله.
class QuizDetails extends Equatable {
  const QuizDetails({
    required this.id,
    required this.title,
    required this.questionsCount,
    required this.correctAnswers,
    required this.failedAnswers,
    required this.questions,
  });

  final String id;
  final String title;
  final int questionsCount;

  /// 0 قبل الحضور، ويحدّثه الخادم بعد `attend-exam`.
  final int correctAnswers;
  final int failedAnswers;
  final List<QuizQuestion> questions;

  /// النسبة من عدّادات الخادم، لا من احتساب محلي.
  int get percent => questionsCount == 0 ? 0 : ((correctAnswers / questionsCount) * 100).round();

  @override
  List<Object?> get props => [id, title, questionsCount, correctAnswers, failedAnswers, questions];
}

class QuizQuestion extends Equatable {
  const QuizQuestion({required this.id, required this.text, required this.answers});

  final String id;

  /// نص السؤال بعد إزالة HTML.
  final String text;
  final List<QuizAnswer> answers;

  QuizAnswer? get selected {
    for (final answer in answers) {
      if (answer.isSelected) return answer;
    }
    return null;
  }

  QuizAnswer? get correct {
    for (final answer in answers) {
      if (answer.isCorrect) return answer;
    }
    return null;
  }

  @override
  List<Object?> get props => [id, text, answers];
}

class QuizAnswer extends Equatable {
  const QuizAnswer({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.isSelected = false,
  });

  final String id;
  final String text;
  final bool isCorrect;

  /// `current_answer == 1` بعد الحضور؛ غائب قبله فيُعدّ false.
  final bool isSelected;

  @override
  List<Object?> get props => [id, text, isCorrect, isSelected];
}

/// عدّادات رد `POST /exams/attend-exam`.
class QuizScore extends Equatable {
  const QuizScore({
    required this.questionsCount,
    required this.correctAnswers,
    required this.failedAnswers,
  });

  final int questionsCount;
  final int correctAnswers;
  final int failedAnswers;

  @override
  List<Object?> get props => [questionsCount, correctAnswers, failedAnswers];
}
