import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_header.dart';
import '../support_content.dart';

/// صفحة نص سياسة مقسّم إلى بنود مرقّمة (سياسة الخصوصية وسياسة الاستخدام).
class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key, required this.title, required this.sections});

  final String title;
  final List<PolicySection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: title,
            onBack: () => context.pop(),
            onNotifications: () => context.push('/notifications'),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              itemCount: sections.length,
              separatorBuilder: (_, _) => const Divider(height: 32, color: AppColors.divider),
              itemBuilder: (context, i) {
                final (heading, body) = sections[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: const TextStyle(color: AppColors.blueStrong, fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(color: AppColors.questionText, fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.55),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
