import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/darb_logo.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.about)),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              child: DarbLogo(size: 56),
            ),
            SizedBox(height: 16),
            Text(
              'درب منصة تعليمية عربية تجمع الدورات والاختبارات والإنجازات في تجربة واحدة واضحة.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.6, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.public, color: AppColors.navy),
                SizedBox(width: 16),
                Icon(Icons.send, color: AppColors.navy),
                SizedBox(width: 16),
                Icon(Icons.chat, color: AppColors.navy),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.contact)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AppTextField(hint: 'الاسم', prefixIcon: Icons.person_outline),
          const SizedBox(height: 12),
          const AppTextField(hint: 'رسالتك', prefixIcon: Icons.message_outlined),
          const SizedBox(height: 20),
          AppButton(
            label: 'إرسال',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال رسالتك')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('كيف أشترك؟', 'اختر الباقة المناسبة من صفحة الاشتراك ثم أكمل الدفع.'),
      ('هل أستطيع إلغاء الاشتراك؟', 'نعم، يمكنك إلغاء التجديد من إعدادات الحساب.'),
      ('هل الشهادات معتمدة؟', 'تحصل على شهادة إتمام بعد إنهاء الدورة والاختبار.'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.faq)),
      body: ListView(
        children: items
            .map(
              (e) => ExpansionTile(
                title: Text(e.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                children: [Padding(padding: const EdgeInsets.all(16), child: Text(e.$2))],
              ),
            )
            .toList(),
      ),
    );
  }
}
