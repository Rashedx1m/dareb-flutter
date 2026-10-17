import '../../../../core/data/mock_catalog.dart';
import '../../../../core/network/api_client.dart';
import '../models/home_feed_model.dart';

/// مصدر تجميعة الصفحة الرئيسية. يرمي استثناءات [ApiClient] عند الفشل.
abstract class HomeRemoteDataSource {
  Future<HomeFeedModel> getHome();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  /// `home-page/index` بتوكن: سلايدر ومواد وأخبار ودورات ونسبة الإنجاز في طلب واحد.
  @override
  Future<HomeFeedModel> getHome() {
    return _client.get(
      '/home-page/index',
      parse: (data) => HomeFeedModel.fromJson(data as Map<String, dynamic>),
    );
  }
}

/// تنفيذ تجريبي من [MockCatalog]، يُستبدل بتنفيذ الـ API في حقن الاعتماديات فقط.
class HomeMockDataSource implements HomeRemoteDataSource {
  const HomeMockDataSource();

  @override
  Future<HomeFeedModel> getHome() async {
    await Future<void>.delayed(MockCatalog.latency);
    return HomeFeedModel(
      sliders: const [],
      subjects: const [],
      news: MockCatalog.news,
      courses: const [],
      completionRate: 0.4,
      subjectCount: 22,
    );
  }
}
