import '../../../../core/network/api_client.dart';
import '../../domain/entities/lookup_option.dart';

/// قوائم التسجيل من الخادم. كلها تتطلب توكن الجلسة المحفوظ بعد التحقق من الرمز.
abstract class RegistrationOptionsRemoteDataSource {
  Future<List<LookupOption>> getGovernorates();
  Future<List<LookupOption>> getSchools({SchoolKind? kind, String? governorateId});
  Future<List<LookupOption>> getBranches();
}

class RegistrationOptionsRemoteDataSourceImpl implements RegistrationOptionsRemoteDataSource {
  const RegistrationOptionsRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  /// قيم `type` في `schools/all`.
  static const _schoolTypes = {SchoolKind.school: 1, SchoolKind.institute: 2};

  @override
  Future<List<LookupOption>> getGovernorates() {
    // المحافظات تصل كخريطة {"damascus": "دمشق", ...} لا كقائمة.
    return _client.get(
      '/governorates/all',
      parse: (data) => [
        for (final entry in (data as Map<String, dynamic>).entries)
          LookupOption(id: entry.key, name: '${entry.value}'),
      ],
    );
  }

  @override
  Future<List<LookupOption>> getSchools({SchoolKind? kind, String? governorateId}) {
    return _client.get(
      '/schools/all',
      query: {
        if (kind != null) 'type': _schoolTypes[kind],
        'governorate': ?governorateId,
      },
      parse: _options,
    );
  }

  @override
  Future<List<LookupOption>> getBranches() => _client.get('/branches/all', parse: _options);

  /// القوائم بالشكل [{"id": 7, "name": "..."}]؛ بقية الحقول لا تلزم التسجيل.
  /// كل عنصر يُحوَّل إلى Map أولاً: الوصول إلى `item['id']` على عنصر dynamic من
  /// نوع آخر يرمي NoSuchMethodError، وهذا لا يحوّله [ApiClient].
  static List<LookupOption> _options(dynamic data) => [
        for (final item in (data as List).cast<Map<String, dynamic>>())
          LookupOption(id: '${item['id']}', name: '${item['name']}'),
      ];
}
