import '../../domain/entities/contact_links.dart';

/// رد `infos/all`. الرابط الفارغ أو غير النصي يعني أن الحساب غير موجود.
class ContactLinksModel extends ContactLinks {
  const ContactLinksModel({super.facebook, super.instagram, super.telegram, super.whatsapp});

  factory ContactLinksModel.fromJson(Map<String, dynamic> json) {
    return ContactLinksModel(
      facebook: _link(json['facebook']),
      instagram: _link(json['instagram']),
      telegram: _link(json['telegram']),
      whatsapp: _link(json['whatsapp']),
    );
  }

  static String? _link(Object? value) {
    if (value is! String) return null;
    final link = value.trim();
    return link.isEmpty ? null : link;
  }
}
