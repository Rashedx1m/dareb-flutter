import 'package:equatable/equatable.dart';

/// وكيل تحويل من `payment-methods/all`: يُحوَّل إليه ثمن الباقة، ثم يصل كود التفعيل.
class PaymentMethod extends Equatable {
  const PaymentMethod({
    required this.id,
    required this.method,
    required this.agentName,
    required this.phone,
    this.governorate,
    this.imageUrl,
  });

  final String id;

  /// شركة التحويل، مثل «الهرم» أو «الفؤاد».
  final String method;

  /// اسم الوكيل الذي يستلم التحويل.
  final String agentName;
  final String phone;
  final String? governorate;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, method, agentName, phone, governorate, imageUrl];
}
