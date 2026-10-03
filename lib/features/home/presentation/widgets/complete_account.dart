import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// نافذة التأكيد «أكمل حسابك الآن» التي تظهر عند الضغط على «تفقّد حسابك الآن».
/// عند الضغط على «أكمل» تُفتح ورقة إكمال البيانات.
Future<void> showCompleteAccountDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _CloseButton(onTap: () => Navigator.of(dialogContext).pop()),
                const Spacer(),
                const Expanded(
                  flex: 5,
                  child: Text(
                    AppStrings.completeAccountNow,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: AppStrings.continueWord,
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      showCompleteAccountSheet(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: AppStrings.back,
                    outlined: true,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// ورقة سفلية لإكمال بيانات الحساب (الاسم، الكنية، المدرسة، الجنس).
Future<void> showCompleteAccountSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
      child: const _CompleteAccountForm(),
    ),
  );
}

class _CompleteAccountForm extends StatefulWidget {
  const _CompleteAccountForm();

  @override
  State<_CompleteAccountForm> createState() => _CompleteAccountFormState();
}

class _CompleteAccountFormState extends State<_CompleteAccountForm> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  String? _school;
  String? _gender;

  static const _schools = [
    AppStrings.schoolGovernment,
    AppStrings.schoolPrivate,
    AppStrings.schoolInstitute,
    AppStrings.schoolOther,
  ];
  static const _genders = [AppStrings.male, AppStrings.female];

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(AppStrings.accountSaved)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(PhosphorIconsRegular.userCircle, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  AppStrings.completeAccountTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                _CloseButton(onTap: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    hint: AppStrings.firstNameHint,
                    controller: _firstName,
                    prefixIcon: PhosphorIconsRegular.userCircle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    hint: AppStrings.lastNameHint,
                    controller: _lastName,
                    prefixIcon: PhosphorIconsRegular.userCircle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Dropdown(
              hint: AppStrings.schoolHint,
              icon: PhosphorIconsRegular.graduationCap,
              value: _school,
              items: _schools,
              onChanged: (v) => setState(() => _school = v),
            ),
            const SizedBox(height: 12),
            _Dropdown(
              hint: AppStrings.genderHint,
              icon: PhosphorIconsRegular.genderMale,
              value: _gender,
              items: _genders,
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: AppButton(label: AppStrings.confirm, onPressed: _submit),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: AppStrings.exitWord,
                    outlined: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String hint;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(PhosphorIconsRegular.caretDown, size: 18, color: AppColors.textMuted),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: onChanged,
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).closeButtonTooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.cancel, color: AppColors.textMuted, size: 30),
        ),
      ),
    );
  }
}
