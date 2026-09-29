import '../../../../core/data/mock_catalog.dart';
import '../../domain/entities/plan.dart';

/// مصدر باقات الاشتراك. يرمي `ServerException` عند الفشل.
abstract class SubscriptionRemoteDataSource {
  Future<List<Plan>> getPlans();
}

/// تنفيذ تجريبي من [MockCatalog]، يُستبدل بتنفيذ الـ API في حقن الاعتماديات فقط.
class SubscriptionMockDataSource implements SubscriptionRemoteDataSource {
  const SubscriptionMockDataSource();

  @override
  Future<List<Plan>> getPlans() async {
    await Future<void>.delayed(MockCatalog.latency);
    return MockCatalog.plans;
  }
}
