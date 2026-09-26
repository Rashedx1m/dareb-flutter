import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/mock_catalog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selected = 'yearly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.subscription)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('اختر باقتك', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('وصول كامل لكل الدورات والاختبارات', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ...MockCatalog.plans.map((plan) {
            final active = selected == plan.id;
            return GestureDetector(
              onTap: () => setState(() => selected = plan.id),
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
          }),
          const SizedBox(height: 12),
          AppButton(label: AppStrings.subscribe, onPressed: () => context.push('/checkout?plan=$selected')),
        ],
      ),
    );
  }
}
