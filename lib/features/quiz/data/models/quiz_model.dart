import '../../../../core/utils/html_text.dart';
import '../../domain/entities/quiz.dart';

/// عنصر `/exams/my` و`/daily-activities/my`. الشكل لم يُرَ (القائمة بقيت فارغة
/// لحساب الاختبار بعد حضور الاختبار 6 في 2026-10-13). يُقرأ بغلاف `exam` أو من
/// المستوى الأعلى، والحقول الغائبة بقيم افتراضية.
class QuizModel extends Quiz {
  const QuizModel({
    required super.id,
    required super.title,
    super.instructor,
    required super.questionsCount,
    super.kind,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json, {required QuizKind kind}) {
    final exam = (json['exam'] as Map<String, dynamic>?) ?? json;
    return QuizModel(
      id: '${exam['id'] ?? ''}',
      title: (exam['title'] as String?) ?? '',
      instructor: (exam['professor'] as String?) ?? '',
      questionsCount: (exam['questions_count'] as num?)?.toInt() ?? 0,
      kind: kind,
    );
  }
}

/// رد `exams/result` كما في 2026-10-13: العدّادات أعداد صحيحة، والأسئلة قائمة.
class QuizDetailsModel extends QuizDetails {
  const QuizDetailsModel({
    required super.id,
    required super.title,
    required super.questionsCount,
    required super.correctAnswers,
    required super.failedAnswers,
    required super.questions,
  });

  factory QuizDetailsModel.fromJson(Map<String, dynamic> json) {
    return QuizDetailsModel(
      id: '${json['id']}',
      title: json['title'] as String,
      questionsCount: json['questions_count'] as int,
      correctAnswers: json['correct_answers'] as int,
      failedAnswers: json['failed_answers'] as int,
      questions: [
        for (final question in (json['questions'] as List).cast<Map<String, dynamic>>())
          QuizQuestionModel.fromJson(question),
      ],
    );
  }
}

class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({required super.id, required super.text, required super.answers});

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: '${json['id']}',
      text: HtmlText.plain(json['title'] as String),
      answers: [
        for (final answer in (json['answers'] as List).cast<Map<String, dynamic>>()) QuizAnswerModel.fromJson(answer),
      ],
    );
  }
}

class QuizAnswerModel extends QuizAnswer {
  const QuizAnswerModel({
    required super.id,
    required super.text,
    required super.isCorrect,
    super.isSelected,
  });

  /// `current_answer` ظهر بعد `attend-exam` كـ 0 أو 1، وغائب قبل الحضور.
  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerModel(
      id: '${json['id']}',
      text: json['title'] as String,
      isCorrect: json['correct'] as bool,
      isSelected: json['current_answer'] == true || json['current_answer'] == 1,
    );
  }
}

/// رد `POST /exams/attend-exam` (201) في 2026-10-13: ثلاثة أعداد بلا معرّف اختبار.
class QuizScoreModel extends QuizScore {
  const QuizScoreModel({
    required super.questionsCount,
    required super.correctAnswers,
    required super.failedAnswers,
  });

  factory QuizScoreModel.fromJson(Map<String, dynamic> json) {
    return QuizScoreModel(
      questionsCount: json['questions_count'] as int,
      correctAnswers: json['correct_answers'] as int,
      failedAnswers: json['failed_answers'] as int,
    );
  }
}
