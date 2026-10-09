import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/payment_method.dart';
import '../cubit/checkout_cubit.dart';
import '../package_format.dart';
import '../widgets/choice_radio.dart';
import '../widgets/payment_instructions_sheet.dart';
import '../widgets/wide_button.dart';

/// إتمام الشراء: اختيار وكيل التحويل ثم عرض تفاصيل الدفع. تعود بـ `true` إن
/// اختار المستخدم إدخال كود الاشتراك.
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  Future<void> _complete(BuildContext context, CheckoutState state) async {
    final enterCode = await showPaymentInstructions(
      context,
      package: state.package!,
      method: state.selectedMethod,
    );
    if (enterCode && context.mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: AppStrings.checkout,
            onBack: () => context.pop(),
            onNotifications: () => context.push('/notifications'),
          ),
          Expanded(
            child: BlocBuilder<CheckoutCubit, CheckoutState>(
              builder: (context, state) {
                final cubit = context.read<CheckoutCubit>();
                final package = state.package;
                return switch (state.status) {
                  CheckoutStatus.success when package != null => ListView(
                      padding: const EdgeInsets.fromLTRB(15, 30, 15, 24),
                      children: [
                        const _SectionTitle(AppStrings.choosePaymentMethod),
                        const SizedBox(height: 14),
                        for (final method in state.methods) ...[
                          _MethodCard(
                            selected: state.selectedMethodId == method.id,
                            onTap: () => cubit.selectMethod(method.id),
                            leading: _MethodLogo(method: method),
                            label: method.method,
                          ),
                          const SizedBox(height: 17),
                        ],
                        _MethodCard(
                          selected: state.selectedMethodId == CheckoutState.cashId,
                          onTap: () => cubit.selectMethod(CheckoutState.cashId),
                          leading: const Icon(PhosphorIconsRegular.handCoins, color: AppColors.iconMuted, size: 32),
                          label: AppStrings.cashWithAdmin,
                        ),
                        const SizedBox(height: 40),
                        const _SectionTitle(AppStrings.accountSection),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(PhosphorIconsRegular.calculator, color: AppColors.accentBlue, size: 24),
                            const SizedBox(width: 8),
                            const Text(AppStrings.finalTotal, style: TextStyle(color: AppColors.hint, fontSize: 16)),
                            const Spacer(),
                            Text(
                              '${formatPrice(package.price)} ${AppStrings.currency}',
                              style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        WideButton(label: AppStrings.checkout, onPressed: () => _complete(context, state)),
                      ],
                    ),
                  CheckoutStatus.failure || CheckoutStatus.success => ErrorView(message: state.error, onRetry: cubit.retry),
                  _ => const LoadingView(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w500));
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.label,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: selected ? AppColors.iconBlue : AppColors.border, width: selected ? 1.3 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                SizedBox(width: 66, child: Align(alignment: AlignmentDirectional.centerStart, child: leading)),
                const SizedBox(width: 10),
                Expanded(child: Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 15))),
                ChoiceRadio(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// شعار شركة التحويل من الخادم، وأيقونة بديلة إن لم يوجد أو تعذّر تحميله.
class _MethodLogo extends StatelessWidget {
  const _MethodLogo({required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(PhosphorIconsRegular.bank, color: AppColors.iconMuted, size: 28);
    final image = method.imageUrl;
    if (image == null) return fallback;
    return CachedNetworkImage(
      imageUrl: image,
      width: 66,
      height: 24,
      fit: BoxFit.contain,
      errorWidget: (_, _, _) => fallback,
    );
  }
}
