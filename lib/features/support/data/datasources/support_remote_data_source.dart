import '../../../../core/network/api_client.dart';
import '../../domain/entities/contact_links.dart';
import '../../domain/entities/contact_message.dart';

/// واجهات الدعم على الخادم. ترمي استثناءات [ApiClient] عند الفشل.
abstract class SupportRemoteDataSource {
  Future<void> sendContactMessage(ContactMessage message);
  Future<ContactLinks> getContactLinks();
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

  @override
  Future<ContactLinks> getContactLinks() {
    return _client.get(
      '/infos/all',
      parse: (data) {
        final json = data as Map<String, dynamic>;
        return ContactLinks(
          facebook: _link(json['facebook']),
          instagram: _link(json['instagram']),
          telegram: _link(json['telegram']),
          whatsapp: _link(json['whatsapp']),
        );
      },
    );
  }

  /// الرابط الفارغ أو غير النصي يعني أن الحساب غير موجود.
  static String? _link(Object? value) {
    if (value is! String) return null;
    final link = value.trim();
    return link.isEmpty ? null : link;
  }
}
