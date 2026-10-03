import 'package:equatable/equatable.dart';

/// روابط حسابات التطبيق على وسائل التواصل (`infos/all`). الرابط الفارغ `null`.
class ContactLinks extends Equatable {
  const ContactLinks({this.facebook, this.instagram, this.telegram, this.whatsapp});

  final String? facebook;
  final String? instagram;
  final String? telegram;
  final String? whatsapp;

  @override
  List<Object?> get props => [facebook, instagram, telegram, whatsapp];
}
