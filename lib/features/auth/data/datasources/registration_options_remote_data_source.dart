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
  Future<List<LookupOption>> getGovernorates() async {
    // المحافظات تصل كخريطة {"damascus": "دمشق", ...} لا كقائمة.
    final data = await _client.get('/governorates/all') as Map<String, dynamic>;
    return [
      for (final entry in data.entries) LookupOption(id: entry.key, name: '${entry.value}'),
    ];
  }

  @override
  Future<List<LookupOption>> getSchools({SchoolKind? kind, String? governorateId}) async {
    final data = await _client.get(
      '/schools/all',
      query: {
        if (kind != null) 'type': _schoolTypes[kind],
        'governorate': ?governorateId,
      },
    );
    return _options(data);
  }

  @override
  Future<List<LookupOption>> getBranches() async => _options(await _client.get('/branches/all'));

  /// القوائم بالشكل [{"id": 7, "name": "..."}]؛ بقية الحقول لا تلزم التسجيل.
  static List<LookupOption> _options(dynamic data) => [
        for (final item in data as List)
          LookupOption(id: '${item['id']}', name: '${item['name']}'),
      ];
}
