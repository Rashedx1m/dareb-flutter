import '../../domain/entities/lookup_option.dart';

/// عنصر من قوائم التسجيل كما يعيده الخادم.
class LookupOptionModel extends LookupOption {
  const LookupOptionModel({required super.id, required super.name});

  /// المدارس والفروع بالشكل `{"id": 7, "name": "..."}`؛ بقية الحقول لا تلزم.
  factory LookupOptionModel.fromJson(Map<String, dynamic> json) {
    return LookupOptionModel(id: '${json['id']}', name: '${json['name']}');
  }

  /// المحافظات تصل كخريطة `{"damascus": "دمشق", ...}`، فكل مدخل فيها عنصر.
  factory LookupOptionModel.fromEntry(MapEntry<String, dynamic> entry) {
    return LookupOptionModel(id: entry.key, name: '${entry.value}');
  }
}
