import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/contact_message.dart';
import '../cubit/contact_cubit.dart';

/// ورقة «تواصل معنا». الحقول تبدأ بالاسم والرقم من [user] إن وُجد.
Future<void> showContactSheet(BuildContext context, {User? user}) async {
  final sent = await showAppSheet<bool>(
    context,
    (_) => BlocProvider(
      create: (_) => sl<ContactCubit>(),
      child: ContactSheet(user: user),
    ),
  );
  if (sent != true || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text(AppStrings.messageSent)));
}

class ContactSheet extends StatefulWidget {
  const ContactSheet({super.key, this.user});

  final User? user;

  @override
  State<ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends State<ContactSheet> {
  late final _firstName = TextEditingController(text: widget.user?.firstName);
  late final _lastName = TextEditingController(text: widget.user?.lastName);
  late final _phone = TextEditingController(text: widget.user?.phone);
  final _text = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _text.dispose();
    super.dispose();
  }

  void _send() {
    context.read<ContactCubit>().send(
          ContactMessage(
            firstName: _firstName.text,
            lastName: _lastName.text,
            phone: _phone.text,
            text: _text.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactCubit, ContactState>(
      listener: (context, state) {
        if (state.status == ContactStatus.done) Navigator.of(context).pop(true);
      },
      builder: (context, state) {
        final error = state.error;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader(title: AppStrings.contact, icon: PhosphorIconsRegular.headset),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SheetField(
                    hint: AppStrings.firstNameHint,
                    icon: PhosphorIconsRegular.userCircle,
                    controller: _firstName,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SheetField(
                    hint: AppStrings.lastNameHint,
                    icon: PhosphorIconsRegular.userCircle,
                    controller: _lastName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SheetField(
              hint: AppStrings.numberHint,
              icon: PhosphorIconsRegular.phone,
              controller: _phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            SheetField(
              hint: AppStrings.descriptionHint,
              icon: PhosphorIconsRegular.listBullets,
              controller: _text,
              maxLines: 5,
            ),
            if (state.status == ContactStatus.failure && error != null) ...[
              const SizedBox(height: 12),
              Text(error, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            SheetActions(
              primaryLabel: AppStrings.confirm,
              onPrimary: _send,
              loading: state.status == ContactStatus.sending,
            ),
          ],
        );
      },
    );
  }
}
