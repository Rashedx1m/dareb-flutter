import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/subscription_package.dart';
import '../package_format.dart';

/// تفاصيل الدفع بعد «إتمام الشراء». الخادم لا يبيع الباقات مباشرة: يُحوَّل المبلغ
/// إلى الوكيل (أو يُدفع نقداً للإدارة) ثم يصل كود يُفعَّل في صفحة الاشتراكات.
/// تعيد `true` إن اختار المستخدم إدخال الكود.
Future<bool> showPaymentInstructions(
  BuildContext context, {
  required SubscriptionPackage package,
  PaymentMethod? method,
}) async {
  final enterCode = await showAppSheet<bool>(
    context,
    (_) => PaymentInstructionsSheet(package: package, method: method),
  );
  return enterCode ?? false;
}

class PaymentInstructionsSheet extends StatelessWidget {
  const PaymentInstructionsSheet({super.key, required this.package, this.method});

  final SubscriptionPackage package;

  /// `null` للدفع نقداً مع الإدارة.
  final PaymentMethod? method;

  static const _body = TextStyle(color: AppColors.listText, fontSize: 15, height: 1.7);

  @override
  Widget build(BuildContext context) {
    final method = this.method;
    final amount = '${formatPrice(package.price)} ${AppStrings.currency}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetHeader(title: AppStrings.paymentDetails, icon: PhosphorIconsRegular.receipt),
        const SizedBox(height: 16),
        if (package.isFree)
          const Text(AppStrings.freePackageInstructions, style: _body)
        else if (method == null) ...[
          Text('ادفع مبلغ $amount نقداً للإدارة.', style: _body),
          const Text(AppStrings.cashInstructions, style: _body),
        ] else ...[
          Text('حوّل مبلغ $amount عبر ${method.method} إلى:', style: _body),
          const SizedBox(height: 8),
          _Detail(label: AppStrings.agentName, value: method.agentName),
          _Detail(label: AppStrings.agentPhone, value: method.phone),
          if (method.governorate case final governorate?)
            _Detail(label: AppStrings.governorateHint, value: governorate),
        ],
        const SizedBox(height: 12),
        const Text(AppStrings.codeAfterPayment, style: TextStyle(color: AppColors.primary, fontSize: 14, height: 1.6)),
        const SizedBox(height: 24),
        SheetActions(
          primaryLabel: AppStrings.enterCode,
          onPrimary: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.hint, fontSize: 15)),
          // الرقم قابل للنسخ لإرساله إلى تطبيق التحويل.
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(color: AppColors.sheetTitle, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
