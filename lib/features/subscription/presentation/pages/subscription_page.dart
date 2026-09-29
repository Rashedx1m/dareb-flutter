import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/plan.dart';
import '../cubit/plans_cubit.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.subscription)),
      body: BlocBuilder<PlansCubit, PlansState>(
        builder: (context, state) {
          return switch (state.status) {
            PlansStatus.initial || PlansStatus.loading => const LoadingView(),
            PlansStatus.failure => ErrorView(
                message: state.error,
                onRetry: () => context.read<PlansCubit>().load(),
              ),
            PlansStatus.success => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('اختر باقتك', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('وصول كامل لكل الدورات والاختبارات', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  for (final plan in state.plans)
                    _PlanCard(
                      plan: plan,
                      active: plan.id == state.selectedId,
                      onTap: () => context.read<PlansCubit>().select(plan.id),
                    ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: AppStrings.subscribe,
                    onPressed: state.selectedId == null
                        ? null
                        : () => context.push('/checkout?plan=${state.selectedId}'),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.active, required this.onTap});

  final Plan plan;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(plan.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const Spacer(),
                Text('${plan.price.toInt()} ر.س', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
                Text(' / ${plan.period}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            ...plan.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(f),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
