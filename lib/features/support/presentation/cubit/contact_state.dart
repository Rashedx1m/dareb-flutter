part of 'contact_cubit.dart';

enum ContactStatus { idle, sending, done, failure }

class ContactState extends Equatable {
  const ContactState({this.status = ContactStatus.idle, this.error});

  final ContactStatus status;
  final String? error;

  @override
  List<Object?> get props => [status, error];
}
