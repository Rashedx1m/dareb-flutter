import '../../../../core/data/mock_catalog.dart';
import '../../domain/entities/achievement.dart';

/// مصدر إنجازات المستخدم. يرمي `ServerException` عند الفشل.
abstract class AchievementsRemoteDataSource {
  Future<List<Achievement>> getAchievements();
}

/// تنفيذ تجريبي من [MockCatalog]، يُستبدل بتنفيذ الـ API في حقن الاعتماديات فقط.
class AchievementsMockDataSource implements AchievementsRemoteDataSource {
  const AchievementsMockDataSource();

  @override
  Future<List<Achievement>> getAchievements() async {
    await Future<void>.delayed(MockCatalog.latency);
    return MockCatalog.achievements;
  }
}
