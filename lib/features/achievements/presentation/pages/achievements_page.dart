import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/mock_catalog.dart';
import '../../../../core/theme/app_colors.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.achievements)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.95,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: MockCatalog.achievements.length,
        itemBuilder: (context, i) {
          final item = MockCatalog.achievements[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: item.unlocked ? AppColors.primary : AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.unlocked ? Icons.emoji_events : Icons.lock_outline,
                  size: 36,
                  color: item.unlocked ? AppColors.warning : AppColors.textMuted,
                ),
                const SizedBox(height: 10),
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(item.subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}
