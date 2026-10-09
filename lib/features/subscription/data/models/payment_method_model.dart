import '../../domain/entities/payment_method.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.method,
    required super.agentName,
    required super.phone,
    super.governorate,
    super.imageUrl,
  });

  /// `{id, name, phone, governorate, method, image}`؛ `name` هو اسم الوكيل.
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: '${json['id']}',
      method: json['method'] as String,
      agentName: json['name'] as String,
      phone: json['phone'] as String,
      governorate: json['governorate'] as String?,
      imageUrl: json['image'] as String?,
    );
  }
}
