import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/subscription_package.dart';
import '../cubit/subscription_cubit.dart';
import '../package_format.dart';
import '../widgets/choice_radio.dart';
import '../widgets/package_subjects_dialog.dart';
import '../widgets/wide_button.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final _codes = {for (final option in CodeOption.values) option: TextEditingController()};

  @override
  void dispose() {
    for (final controller in _codes.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _subscribe(SubscriptionState state) async {
    final cubit = context.read<SubscriptionCubit>();
    final code = state.selectedCode;
    if (code != null) {
      cubit.activate(_codes[code]!.text);
      return;
    }
    // الدفع خارج التطبيق؛ صفحة الدفع تعود بـ true إن اختار المستخدم إدخال الكود.
    final enterCode = await context.push<bool>('/checkout?package=${state.selectedPackageId}');
    if (enterCode == true && mounted) cubit.selectCode(CodeOption.subjectOrCurriculum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: AppStrings.subscriptionsTitle,
            titleIcon: PhosphorIconsRegular.envelopeSimpleOpen,
            onBack: () => context.pop(),
            onNotifications: () => context.push('/notifications'),
          ),
          Expanded(
            child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
              listenWhen: (previous, current) => previous.activation != current.activation,
              listener: (context, state) {
                switch (state.activation) {
                  case ActivationStatus.done:
                    _showMessage(AppStrings.subscriptionActivated);
                    if (context.canPop()) context.pop();
                  case ActivationStatus.failure:
                    _showMessage(state.activationError ?? AppStrings.loadError);
                  case ActivationStatus.idle || ActivationStatus.sending:
                    break;
                }
              },
              builder: (context, state) {
                final cubit = context.read<SubscriptionCubit>();
                return switch (state.status) {
                  PackagesStatus.failure => ErrorView(message: state.error, onRetry: cubit.load),
                  PackagesStatus.success => ListView(
                      padding: const EdgeInsets.fromLTRB(15, 38, 15, 24),
                      children: [
                        for (final package in state.packages) ...[
                          _PackageCard(
                            package: package,
                            selected: state.selectedPackageId == package.id,
                            onTap: () => cubit.selectPackage(package.id),
                            onDetails: () => showPackageSubjects(context, package),
                          ),
                          const SizedBox(height: 25),
                        ],
                        for (final option in CodeOption.values) ...[
                          _CodeField(
                            hint: option == CodeOption.subjectOrCurriculum
                                ? AppStrings.codeForSubject
                                : AppStrings.codeForSubjects,
                            controller: _codes[option]!,
                            selected: state.selectedCode == option,
                            onSelect: () => cubit.selectCode(option),
                          ),
                          const SizedBox(height: 25),
                        ],
                        const SizedBox(height: 7),
                        WideButton(
                          label: AppStrings.subscribe,
                          loading: state.activation == ActivationStatus.sending,
                          onPressed: state.hasChoice ? () => _subscribe(state) : null,
                        ),
                      ],
                    ),
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

/// بطاقة باقة: المختارة زرقاء بنص فاتح، وغيرها بيضاء بإطار رمادي.
class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.selected,
    required this.onTap,
    required this.onDetails,
  });

  final SubscriptionPackage package;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final description = package.description;
    return Material(
      color: selected ? AppColors.accentBlue : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: selected ? BorderSide.none : const BorderSide(color: AppColors.hint),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            package.name,
                            style: TextStyle(
                              color: selected ? AppColors.onAccentBlue : AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _DetailsChip(light: selected, onTap: onDetails),
                      ],
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(color: selected ? AppColors.onAccentBlue : AppColors.closeIcon, fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _PriceLabel(package: package, color: selected ? AppColors.onAccentBlue : AppColors.blueStrong),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ChoiceRadio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

/// السعر كبير والمدة بعده أصغر، كما في التصميم.
class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.package, required this.color});

  final SubscriptionPackage package;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final period = packagePeriodLabel(package);
    return Text.rich(
      TextSpan(
        style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w500),
        children: [
          TextSpan(text: '${formatPrice(package.price)} ${AppStrings.currency}'),
          if (period != null) ...[
            const TextSpan(text: '/ '),
            TextSpan(text: period, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
          ],
        ],
      ),
    );
  }
}

class _DetailsChip extends StatelessWidget {
  const _DetailsChip({required this.light, required this.onTap});

  /// على البطاقة الزرقاء يصير النص فاتحاً.
  final bool light;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          AppStrings.packageDetails,
          style: TextStyle(color: light ? AppColors.onAccentBlue : AppColors.blueStrong, fontSize: 12),
        ),
      ),
    );
  }
}

/// خانة كود: الضغط عليها أو على دائرتها يختارها.
class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.hint,
    required this.controller,
    required this.selected,
    required this.onSelect,
  });

  final String hint;
  final TextEditingController controller;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 61,
      padding: const EdgeInsetsDirectional.only(start: 20, end: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? AppColors.primary : AppColors.hint),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onTap: onSelect,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: AppColors.sheetTitle, fontSize: 15),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.closeIcon, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(onTap: onSelect, child: ChoiceRadio(selected: selected)),
        ],
      ),
    );
  }
}
