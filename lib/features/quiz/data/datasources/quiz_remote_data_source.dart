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
