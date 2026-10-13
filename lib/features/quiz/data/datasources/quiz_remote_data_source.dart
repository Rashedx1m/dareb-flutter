import '../../../../core/data/mock_catalog.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/quiz.dart';
import '../models/quiz_model.dart';

/// مصدر الاختبارات والنشاطات. يرمي استثناءات [ApiClient] عند الفشل.
abstract class QuizRemoteDataSource {
  Future<List<QuizModel>> getMyExams();
  Future<List<QuizModel>> getMyActivities();
  Future<QuizDetailsModel> getQuiz(String id);
  Future<QuizScoreModel> attendExam(List<String> answerIds);
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  const QuizRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  /// `/exams/my` أعاد قائمة فارغة في 2026-10-13 حتى بعد حضور اختبار 6.
  @override
  Future<List<QuizModel>> getMyExams() {
    return _client.get(
      '/exams/my',
      parse: (data) => [
        for (final json in (data as List).cast<Map<String, dynamic>>()) QuizModel.fromJson(json, kind: QuizKind.test),
      ],
    );
  }

  @override
  Future<List<QuizModel>> getMyActivities() {
    return _client.get(
      '/daily-activities/my',
      parse: (data) => [
        for (final json in (data as List).cast<Map<String, dynamic>>())
          QuizModel.fromJson(json, kind: QuizKind.activity),
      ],
    );
  }

  @override
  Future<QuizDetailsModel> getQuiz(String id) {
    return _client.get(
      '/exams/result',
      query: {'id': id},
      parse: (data) => QuizDetailsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// الخادم لا يطلب معرّف الاختبار؛ يعرف الاختبار من معرّفات الإجابات.
  @override
  Future<QuizScoreModel> attendExam(List<String> answerIds) {
    return _client.post(
      '/exams/attend-exam',
      fields: {'answers_id[]': answerIds},
      parse: (data) => QuizScoreModel.fromJson(data as Map<String, dynamic>),
    );
  }
}

/// تنفيذ تجريبي من [MockCatalog]، يُستبدل في حقن الاعتماديات بالمصدر الحقيقي.
class QuizMockDataSource implements QuizRemoteDataSource {
  const QuizMockDataSource();

  QuizModel _card(Quiz quiz) => QuizModel(
        id: quiz.id,
        title: quiz.title,
        instructor: quiz.instructor,
        questionsCount: quiz.questionsCount,
        kind: quiz.kind,
      );

  @override
  Future<List<QuizModel>> getMyExams() async {
    await Future<void>.delayed(MockCatalog.latency);
    return [for (final quiz in MockCatalog.quizzes) if (quiz.kind == QuizKind.test) _card(quiz)];
  }

  @override
  Future<List<QuizModel>> getMyActivities() async {
    await Future<void>.delayed(MockCatalog.latency);
    return [for (final quiz in MockCatalog.quizzes) if (quiz.kind == QuizKind.activity) _card(quiz)];
  }

  @override
  Future<QuizDetailsModel> getQuiz(String id) async {
    await Future<void>.delayed(MockCatalog.latency);
    final details = MockCatalog.quizDetails[id];
    if (details == null) throw const ServerException('الاختبار غير موجود');
    return QuizDetailsModel(
      id: details.id,
      title: details.title,
      questionsCount: details.questionsCount,
      correctAnswers: details.correctAnswers,
      failedAnswers: details.failedAnswers,
      questions: [
        for (final q in details.questions)
          QuizQuestionModel(
            id: q.id,
            text: q.text,
            answers: [
              for (final a in q.answers)
                QuizAnswerModel(id: a.id, text: a.text, isCorrect: a.isCorrect, isSelected: a.isSelected),
            ],
          ),
      ],
    );
  }

  @override
  Future<QuizScoreModel> attendExam(List<String> answerIds) async {
    await Future<void>.delayed(MockCatalog.latency);
    return QuizScoreModel(questionsCount: answerIds.length, correctAnswers: 0, failedAnswers: answerIds.length);
  }
}
