import 'package:equatable/equatable.dart';

/// رسالة «تواصل معنا» كما يطلبها الخادم في `contact-us/add`، وكل حقولها مطلوبة.
class ContactMessage extends Equatable {
  const ContactMessage({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.text,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String text;

  @override
  List<Object?> get props => [firstName, lastName, phone, text];
}
