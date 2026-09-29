import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/plan.dart';
import '../cubit/plans_cubit.dart';

/// صفحة الدفع للباقة المختارة. الباقة تُحدَّد في المسار (`/checkout?plan=`)
/// ويحمّلها [PlansCubit] مسبقاً.
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.checkout)),
      body: BlocBuilder<PlansCubit, PlansState>(
        builder: (context, state) {
          final plan = state.selected;
          return switch (state.status) {
            PlansStatus.initial || PlansStatus.loading => const LoadingView(),
            PlansStatus.success when plan != null => _CheckoutForm(plan: plan),
            _ => ErrorView(
                message: state.error,
                onRetry: () => context.read<PlansCubit>().load(preferredId: state.selectedId),
              ),
          };
        },
      ),
    );
  }
}

class _CheckoutForm extends StatelessWidget {
  const _CheckoutForm({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Text(plan.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const Spacer(),
              Text('${plan.price.toInt()} ر.س', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('بيانات الدفع', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 12),
        const AppTextField(hint: 'اسم حامل البطاقة', prefixIcon: Icons.person_outline),
        const SizedBox(height: 12),
        const AppTextField(hint: 'رقم البطاقة', keyboardType: TextInputType.number, prefixIcon: Icons.credit_card),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: AppTextField(hint: 'MM/YY')),
            SizedBox(width: 12),
            Expanded(child: AppTextField(hint: 'CVV', keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 24),
        AppButton(
          label: AppStrings.pay,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الاشتراك بنجاح')));
            context.go('/home');
          },
        ),
      ],
    );
  }
}
