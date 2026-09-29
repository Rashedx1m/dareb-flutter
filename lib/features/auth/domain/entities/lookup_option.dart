import 'package:equatable/equatable.dart';

/// عنصر من قوائم التسجيل التي يعيدها الخادم: محافظة أو مدرسة أو فرع.
class LookupOption extends Equatable {
  const LookupOption({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// نوع الجهة الدراسية، يُستخدم لتصفية قائمة المدارس.
enum SchoolKind { school, institute }
