import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

/// رسالة فشل التحميل مع زر إعادة المحاولة، تستخدمها الصفحات التي تجلب
/// بياناتها من مستودع. بلا [message] تُعرض رسالة عامة.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(
            message ?? AppStrings.loadError,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}

/// مؤشر التحميل الموحّد بلون التطبيق.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }
}
