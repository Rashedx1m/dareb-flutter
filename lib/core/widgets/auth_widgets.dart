import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_strings.dart';
import '../theme/app_icons.dart';
import '../theme/app_colors.dart';
import 'darb_logo.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.onBack,
    this.height = 220,
  });

  final VoidCallback? onBack;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        height: height + MediaQuery.paddingOf(context).top,
        decoration: const BoxDecoration(
          color: AppColors.headerTeal,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
              child: const DarbLogo(size: 92),
            ),
            if (onBack != null)
              PositionedDirectional(
                top: MediaQuery.paddingOf(context).top + 8,
                end: 8,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(PhosphorIconsRegular.arrowRight, color: Colors.white, size: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.leading,
    this.onTap,
    this.readOnly = false,
    this.trailing,
  });

  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;

  /// أيقونة الحقل، تظهر في بدايته (يمين الحقل في الواجهة العربية).
  final Widget? leading;

  /// عنصر يظهر في نهاية الحقل، كسهم القائمة المنسدلة.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: leading,
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
        suffixIcon: trailing,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class AuthOutlinedButton extends StatelessWidget {
  const AuthOutlinedButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// تخطيط موحّد لخطوات التسجيل: يبقي العناصر السفلية (كالأزرار عبر `Spacer`)
/// في أسفل الشاشة حين تتوفّر مساحة كافية، ويحوّل المحتوى إلى قابل للتمرير حين
/// تقصر الشاشة، فلا يحدث فيضان (overflow) كالذي كان يظهر في الخطوات الطويلة.
class StepLayout extends StatelessWidget {
  const StepLayout({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(28, 16, 28, 24),
  });

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            // نضمن ملء الارتفاع المتاح ليعمل `Spacer`، مع السماح بتجاوزه والتمرير.
            constraints: BoxConstraints(minHeight: constraints.maxHeight - padding.vertical),
            child: IntrinsicHeight(
              child: Column(children: children),
            ),
          ),
        );
      },
    );
  }
}

class RegisterProgress extends StatelessWidget {
  const RegisterProgress({super.key, required this.current});

  /// 0 = تفاصيل الحساب، 1 = نوع المؤسسة، 2 = المعلومات الشخصية
  final int current;

  static const _labels = [
    AppStrings.stepAccount,
    AppStrings.stepSchoolType,
    AppStrings.stepPersonal,
  ];

  @override
  Widget build(BuildContext context) {
    final fill = switch (current) {
      0 => 0.16,
      1 => 0.5,
      _ => 1.0,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          SizedBox(
            height: 16,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const knob = 16.0;
                final fillWidth = (width * fill).clamp(knob, width);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.stepTrack,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        width: fillWidth,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(-1 + 2 * (fillWidth / width), 0),
                      child: Container(
                        width: knob,
                        height: knob,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.stepKnob, width: 3.5),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_labels.length, (index) {
              final active = index == current;
              return Expanded(
                child: Text(
                  _labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.accentBlue : AppColors.stepLabel,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class SelectOption extends StatelessWidget {
  const SelectOption({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.fieldBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.iconBlue, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
            if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.fieldBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: AppColors.iconBlue, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.6),
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.check, size: 14, color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SuccessBadge extends StatelessWidget {
  const SuccessBadge({super.key, this.size = 112});

  final double size;

  @override
  Widget build(BuildContext context) {
    // أيقونة الختم (seal-check) المستخرجة من التصميم بلونها الأزرق #7CA4F2.
    return SvgPicture.asset(
      'assets/icons/seal_check_fill.svg',
      width: size,
      height: size,
    );
  }
}

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({super.key, required this.onKey, required this.onBackspace});

  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;

  static const _letters = {
    '2': 'ABC',
    '3': 'DEF',
    '4': 'GHI',
    '5': 'JKL',
    '6': 'MNO',
    '7': 'PQRS',
    '8': 'TUV',
    '9': 'WXYZ',
    '*': '+ * #',
  };

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', ''],
    ];
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: AppColors.keypadBg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 12),
          child: Column(
            children: keys.map((row) {
              return Row(
                children: row.map((key) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: key.isEmpty
                          ? Material(
                              color: AppColors.keypadKey,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: onBackspace,
                                child: const SizedBox(
                                  height: 52,
                                  child: Icon(Icons.close, color: AppColors.textSecondary),
                                ),
                              ),
                            )
                          : Material(
                              color: AppColors.keypadKey,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  if (key == '*') return;
                                  onKey(key);
                                },
                                child: SizedBox(
                                  height: 52,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(key, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 1)),
                                      if (_letters[key] != null)
                                        Text(
                                          _letters[key]!,
                                          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, letterSpacing: 1),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(21, 21, 21, 21),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class SourceChoice extends StatelessWidget {
  const SourceChoice({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.sourceSelected : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.sourceSelected : AppColors.border),
        ),
        child: selected
            ? const Center(
                child: Icon(Icons.check_rounded, color: Colors.white, size: 32),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.iconBlue, size: 22),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class TermsSheet extends StatelessWidget {
  const TermsSheet({super.key, required this.onAccept});

  /// يُستدعى عند الموافقة الصريحة فقط؛ إغلاق الورقة لا يُعدّ موافقة.
  final VoidCallback onAccept;

  static const _terms = <(String, String)>[
    (
      'قبول الشروط',
      'باستخدامك لهذا التطبيق، فإنك تقر بأنك قرأت هذه الشروط وفهمتها ووافقت على الالتزام بها بالكامل. إذا لم توافق على هذه الشروط، يُرجى عدم استخدام التطبيق. تحتفظ إدارة التطبيق بحق تعديل هذه الشروط في أي وقت، وسيتم إعلامك بالتحديثات عند الضرورة.',
    ),
    (
      'إنشاء الحساب واستخدامه',
      'يتطلب استخدام بعض ميزات التطبيق إنشاء حساب شخصي. باستخدامك بيانات صحيحة مثل الاسم والبريد الإلكتروني، يجب على المستخدم الحفاظ على سرية معلومات تسجيل الدخول وعدم مشاركتها مع الآخرين. أي استخدام غير مصرح به للحساب يُعد مخالفة قد تؤدي إلى إيقافه.',
    ),
    (
      'الاستخدام المقبول',
      'يُمنع استخدام التطبيق لأغراض تخالف القانون، أو انتهاك حقوق الغير، أو التسبب بضرر للتطبيق أو للمستخدمين الآخرين، ويشمل ذلك: نشر محتوى مسيء، نسخ الفيديوهات أو الملخصات بدون إذن، أو محاولة اختراق النظام الأمني للتطبيق.',
    ),
    (
      'حقوق الملكية الفكرية',
      'جميع المحتويات المتوفرة في التطبيق، بما في ذلك الفيديوهات، الملخصات، الاختبارات، والتصاميم، محمية بموجب قوانين حقوق النشر والعلامات التجارية. لا يجوز استخدام أو إعادة نشر أي من هذه المواد دون موافقة خطية مسبقة من إدارة التطبيق أو من صاحب المحتوى.',
    ),
    (
      'إيقاف الخدمة أو الحساب',
      'عند استخدامك للتطبيق، قد نقوم بإيقاف أو تعليق حسابك في حال مخالفة هذه الشروط، أو عند وجود نشاط يضر بالخدمة أو بالمستخدمين الآخرين.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        AppStrings.termsTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
                  children: [
                    for (final (index, term) in _terms.indexed)
                      _Term(index + 1, term.$1, term.$2),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                  child: AuthPrimaryButton(
                    label: AppStrings.termsAccept,
                    onPressed: onAccept,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Term extends StatelessWidget {
  const _Term(this.number, this.title, this.body);
  final int number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. $title',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textPrimary,
              height: 1.7,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}
