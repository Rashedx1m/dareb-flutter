import '../../../../core/network/api_client.dart';
import '../../domain/entities/lookup_option.dart';
import '../models/lookup_option_model.dart';

/// قوائم التسجيل من الخادم. كلها تتطلب توكن الجلسة المحفوظ بعد التحقق من الرمز.
abstract class RegistrationOptionsRemoteDataSource {
  Future<List<LookupOptionModel>> getGovernorates();
  Future<List<LookupOptionModel>> getSchools({SchoolKind? kind, String? governorateId});
  Future<List<LookupOptionModel>> getBranches();
}

class RegistrationOptionsRemoteDataSourceImpl implements RegistrationOptionsRemoteDataSource {
  const RegistrationOptionsRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  /// قيم `type` في `schools/all`.
  static const _schoolTypes = {SchoolKind.school: 1, SchoolKind.institute: 2};

  @override
  Future<List<LookupOptionModel>> getGovernorates() {
    return _client.get(
      '/governorates/all',
      parse: (data) => [
        for (final entry in (data as Map<String, dynamic>).entries) LookupOptionModel.fromEntry(entry),
      ],
    );
  }

  @override
  Future<List<LookupOptionModel>> getSchools({SchoolKind? kind, String? governorateId}) {
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
  Future<List<LookupOptionModel>> getBranches() => _client.get('/branches/all', parse: _options);

  /// كل عنصر يُحوَّل إلى Map أولاً: الوصول إلى `item['id']` على عنصر dynamic من
  /// نوع آخر يرمي NoSuchMethodError، وهذا لا يحوّله [ApiClient].
  static List<LookupOptionModel> _options(dynamic data) => [
        for (final item in (data as List).cast<Map<String, dynamic>>()) LookupOptionModel.fromJson(item),
      ];
}
