import '../../../../core/data/mock_catalog.dart';
import '../../domain/entities/news_item.dart';

/// مصدر أخبار الصفحة الرئيسية. يرمي `ServerException` عند الفشل.
abstract class NewsRemoteDataSource {
  Future<List<NewsItem>> getNews();
}

/// تنفيذ تجريبي من [MockCatalog]، يُستبدل بتنفيذ الـ API في حقن الاعتماديات فقط.
class NewsMockDataSource implements NewsRemoteDataSource {
  const NewsMockDataSource();

  @override
  Future<List<NewsItem>> getNews() async {
    await Future<void>.delayed(MockCatalog.latency);
    return MockCatalog.news;
  }
}
