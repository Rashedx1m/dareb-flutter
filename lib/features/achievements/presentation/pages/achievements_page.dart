import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/achievement.dart';
import '../cubit/achievements_cubit.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.achievements)),
      body: BlocBuilder<AchievementsCubit, AchievementsState>(
        builder: (context, state) {
          return switch (state.status) {
            AchievementsStatus.initial || AchievementsStatus.loading => const LoadingView(),
            AchievementsStatus.failure => ErrorView(
                message: state.error,
                onRetry: () => context.read<AchievementsCubit>().load(),
              ),
            AchievementsStatus.success => GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.95,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: state.items.length,
                itemBuilder: (context, i) => _AchievementTile(item: state.items[i]),
              ),
          };
        },
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.item});

  final Achievement item;

  @override
  Widget build(BuildContext context) {
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
  }
}
