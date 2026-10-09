import '../../../../core/network/api_client.dart';
import '../models/payment_method_model.dart';
import '../models/subscription_package_model.dart';

/// واجهات الاشتراك على الخادم. ترمي استثناءات [ApiClient] عند الفشل.
abstract class SubscriptionRemoteDataSource {
  Future<List<SubscriptionPackageModel>> getPackages();
  Future<SubscriptionPackageModel> getPackage(String id);
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<void> subscribeWithCode(String code);
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  const SubscriptionRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<SubscriptionPackageModel>> getPackages() {
    return _client.get(
      '/packages/all',
      parse: (data) => [
        for (final json in (data as List).cast<Map<String, dynamic>>()) SubscriptionPackageModel.fromJson(json),
      ],
    );
  }

  @override
  Future<SubscriptionPackageModel> getPackage(String id) {
    return _client.get(
      '/packages/details',
      query: {'id': id},
      parse: (data) => SubscriptionPackageModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() {
    return _client.get(
      '/payment-methods/all',
      parse: (data) => [
        for (final json in (data as List).cast<Map<String, dynamic>>()) PaymentMethodModel.fromJson(json),
      ],
    );
  }

  @override
  Future<void> subscribeWithCode(String code) async {
    await _client.post('/subscriptions/add', fields: {'code': code});
  }
}
