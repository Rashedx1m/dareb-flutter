import '../../../../core/data/mock_catalog.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/quiz.dart';

/// مصدر الاختبارات والنشاطات. يرمي [ServerException] عند الفشل.
abstract class QuizRemoteDataSource {
  Future<List<Quiz>> getQuizzes();
  Future<Quiz> getQuiz(String id);
}

/// تنفيذ تجريبي من [MockCatalog]، يُستبدل بتنفيذ الـ API في حقن الاعتماديات فقط.
class QuizMockDataSource implements QuizRemoteDataSource {
  const QuizMockDataSource();

  @override
  Future<List<Quiz>> getQuizzes() async {
    await Future<void>.delayed(MockCatalog.latency);
    return MockCatalog.quizzes;
  }

  @override
  Future<Quiz> getQuiz(String id) async {
    await Future<void>.delayed(MockCatalog.latency);
    for (final quiz in MockCatalog.quizzes) {
      if (quiz.id == id) return quiz;
    }
    throw const ServerException('الاختبار غير موجود');
  }
}
