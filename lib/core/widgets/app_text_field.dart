import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.maxLength,
  });

  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      textAlign: textAlign,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: AppColors.textMuted, size: 20),
      ),
    );
  }
}
