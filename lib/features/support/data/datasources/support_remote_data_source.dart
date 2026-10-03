import '../../../../core/network/api_client.dart';
import '../../domain/entities/contact_message.dart';

/// واجهات الدعم على الخادم. ترمي استثناءات [ApiClient] عند الفشل.
abstract class SupportRemoteDataSource {
  Future<void> sendContactMessage(ContactMessage message);
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  const SupportRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<void> sendContactMessage(ContactMessage message) async {
    await _client.post(
      '/contact-us/add',
      fields: {
        'f_name': message.firstName,
        'l_name': message.lastName,
        'phone': message.phone,
        'text': message.text,
      },
    );
  }
}
