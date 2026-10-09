import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/contact_message.dart';
import '../../domain/usecases/send_contact_message.dart';

part 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  ContactCubit(this._sendContactMessage) : super(const ContactState());

  final SendContactMessage _sendContactMessage;

  Future<void> send(ContactMessage message) async {
    emit(const ContactState(status: ContactStatus.sending));
    final result = await _sendContactMessage(message);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => ContactState(status: ContactStatus.failure, error: failure.message),
        (_) => const ContactState(status: ContactStatus.done),
      ),
    );
  }
}
