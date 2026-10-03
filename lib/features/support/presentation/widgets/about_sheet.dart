import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_sheet.dart';

Future<void> showAboutSheet(BuildContext context) {
  return showAppSheet<void>(context, (_) => const AboutSheet());
}

/// ورقة «حول التطبيق»: الشعار ووصف التطبيق وحسابات التواصل.
class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetHeader(title: AppStrings.about, icon: PhosphorIconsRegular.info),
        const SizedBox(height: 8),
        SvgPicture.asset(AppAssets.logoColor, width: 140, height: 80),
        const SizedBox(height: 6),
        const Text(
          'EDUCATION',
          style: TextStyle(
            fontFamily: 'Lato',
            color: AppColors.accentBlue,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          AppStrings.aboutDescription,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.primary, fontSize: 12, height: 1.6),
        ),
        const SizedBox(height: 20),
        // من اليمين: واتساب، تيليجرام، انستغرام، فيسبوك (كما في التصميم من اليسار معكوساً).
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialIcon(icon: PhosphorIconsFill.whatsappLogo, color: Color(0xFF25D366)),
            SizedBox(width: 12),
            _CircleSocialIcon(icon: PhosphorIconsFill.telegramLogo, color: Color(0xFF29A9EB)),
            SizedBox(width: 12),
            _InstagramIcon(),
            SizedBox(width: 12),
            _SocialIcon(icon: PhosphorIconsFill.facebookLogo, color: Color(0xFF1877F2)),
          ],
        ),
      ],
    );
  }
}

/// أيقونة علامة تجارية تملأ شكلها بلونها (فيسبوك وواتساب).
class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Icon(icon, color: color, size: 44);
}

/// دائرة ملوّنة بداخلها الأيقونة بيضاء (تيليجرام).
class _CircleSocialIcon extends StatelessWidget {
  const _CircleSocialIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

/// شعار انستغرام بتدرّجه المعروف.
class _InstagramIcon extends StatelessWidget {
  const _InstagramIcon();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xFFFEDA75), Color(0xFFFA7E1E), Color(0xFFD62976), Color(0xFF962FBF), Color(0xFF4F5BD5)],
      ).createShader(bounds),
      child: const Icon(PhosphorIconsFill.instagramLogo, size: 44),
    );
  }
}
