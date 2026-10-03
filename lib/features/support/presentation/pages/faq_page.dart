import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/page_header.dart';
import '../support_content.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  /// السؤال المفتوح (القسم، السؤال). يبدأ بأول سؤال مفتوحاً كما في التصميم.
  (int, int)? _open = (0, 0);

  void _toggle((int, int) key) => setState(() => _open = _open == key ? null : key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: AppStrings.faq,
            onBack: () => context.pop(),
            onNotifications: () => context.push('/notifications'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              children: [
                for (final (s, section) in faqSections.indexed) ...[
                  if (s > 0) const ColoredBox(color: AppColors.divider, child: SizedBox(height: 6, width: double.infinity)),
                  _SectionTitle(section: section),
                  for (final (q, item) in section.items.indexed)
                    _Question(
                      question: item.$1,
                      answer: item.$2,
                      open: _open == (s, q),
                      onTap: () => _toggle((s, q)),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.section});

  final FaqSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          Icon(section.icon, color: AppColors.accentBlue, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              section.title,
              style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.question,
    required this.answer,
    required this.open,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(color: AppColors.questionText, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  open ? PhosphorIconsRegular.caretUp : PhosphorIconsRegular.caretDown,
                  color: AppColors.iconBlue,
                  size: 18,
                ),
              ],
            ),
            if (open) ...[
              const SizedBox(height: 6),
              Text(answer, style: const TextStyle(color: AppColors.iconBlue, fontSize: 12, height: 1.6)),
            ],
          ],
        ),
      ),
    );
  }
}
