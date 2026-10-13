import '../../../../core/data/mock_catalog.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/quiz.dart';

/// مصدر الاختبارات والنشاطات. يرمي [ServerException] عند الفشل.
abstract class QuizRemoteDataSource {
  Future<List<Quiz>> getMyExams();
  Future<List<Quiz>> getMyActivities();
  Future<QuizDetails> getQuiz(String id);
  Future<QuizScore> attendExam(List<String> answerIds);
}

/// تنفيذ تجريبي من [MockCatalog]، يُستبدل بتنفيذ الـ API في حقن الاعتماديات فقط.
class QuizMockDataSource implements QuizRemoteDataSource {
  const QuizMockDataSource();

  @override
  Future<List<Quiz>> getMyExams() async {
    await Future<void>.delayed(MockCatalog.latency);
    return [for (final quiz in MockCatalog.quizzes) if (quiz.kind == QuizKind.test) quiz];
  }

  @override
  Future<List<Quiz>> getMyActivities() async {
    await Future<void>.delayed(MockCatalog.latency);
    return [for (final quiz in MockCatalog.quizzes) if (quiz.kind == QuizKind.activity) quiz];
  }

  @override
  Future<QuizDetails> getQuiz(String id) async {
    await Future<void>.delayed(MockCatalog.latency);
    final details = MockCatalog.quizDetails[id];
    if (details != null) return details;
    throw const ServerException('الاختبار غير موجود');
  }

  @override
  Future<QuizScore> attendExam(List<String> answerIds) async {
    await Future<void>.delayed(MockCatalog.latency);
    return QuizScore(questionsCount: answerIds.length, correctAnswers: 0, failedAnswers: answerIds.length);
  }
}
