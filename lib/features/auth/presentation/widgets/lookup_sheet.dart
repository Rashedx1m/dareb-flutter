import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/lookup_option.dart';
import '../cubit/registration_options_cubit.dart';

/// قائمة سفلية لاختيار عنصر من قوائم الخادم (محافظة أو مدرسة)، تُغلق بالعنصر
/// المختار. تعرض التحميل والخطأ بحسب [status] لأن القائمة قد تُفتح قبل وصولها.
class LookupSheet extends StatelessWidget {
  const LookupSheet({
    super.key,
    required this.title,
    required this.status,
    required this.items,
    required this.onRetry,
    this.error,
    this.emptyMessage,
  });

  final String title;
  final OptionsStatus status;
  final List<LookupOption> items;
  final VoidCallback onRetry;
  final String? error;

  /// يُعرض بدل القائمة إن وصلت فارغة.
  final String? emptyMessage;

  /// يعرض [sheet] ويعيد العنصر المختار، أو `null` إن أُغلقت دون اختيار.
  static Future<LookupOption?> show(BuildContext context, Widget sheet) {
    return showModalBottomSheet<LookupOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        // القوائم الطويلة (14 محافظة مثلاً) لا تتسع لكل الشاشات، فتُمرَّر ضمن 70% من الارتفاع.
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Flexible(child: _content(context)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final empty = emptyMessage;
    return switch (status) {
      OptionsStatus.failure => ErrorView(message: error, onRetry: onRetry),
      OptionsStatus.success when items.isEmpty && empty != null => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            empty,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),
        ),
      OptionsStatus.success => ListView(
          shrinkWrap: true,
          children: [
            for (final item in items)
              ListTile(
                title: Text(item.name, textAlign: TextAlign.center),
                onTap: () => Navigator.pop(context, item),
              ),
          ],
        ),
      _ => const SizedBox(height: 120, child: LoadingView()),
    };
  }
}
