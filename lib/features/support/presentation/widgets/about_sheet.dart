import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/utils/external_link.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../cubit/about_cubit.dart';

/// الروابط تُجلب مع فتح الورقة (`infos/all`).
Future<void> showAboutSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    (_) => BlocProvider(
      create: (_) => sl<AboutCubit>()..load(),
      child: const AboutSheet(),
    ),
  );
}

/// ورقة «حول التطبيق»: الشعار ووصف التطبيق وحسابات التواصل.
class AboutSheet extends StatefulWidget {
  const AboutSheet({super.key, this.openLink = openExternalLink});

  /// يُستبدل في الاختبارات حتى لا يُفتح رابط حقيقي.
  final LinkOpener openLink;

  @override
  State<AboutSheet> createState() => _AboutSheetState();
}

class _AboutSheetState extends State<AboutSheet> {
  bool _openFailed = false;

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    final opened = uri != null && await widget.openLink(uri);
    if (!mounted) return;
    // رسالة داخل الورقة، لأن SnackBar يظهر خلفها.
    setState(() => _openFailed = !opened);
  }

  @override
  Widget build(BuildContext context) {
    final links = context.watch<AboutCubit>().state.links;
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
        // من اليمين: واتساب، تيليغرام، إنستغرام، فيسبوك (كما في التصميم من اليسار معكوساً).
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LinkButton(
              label: AppStrings.whatsapp,
              url: links.whatsapp,
              onOpen: _open,
              child: const Icon(PhosphorIconsFill.whatsappLogo, color: AppColors.whatsapp, size: 44),
            ),
            const SizedBox(width: 12),
            _LinkButton(
              label: AppStrings.telegram,
              url: links.telegram,
              onOpen: _open,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: AppColors.telegram, shape: BoxShape.circle),
                child: const Icon(PhosphorIconsFill.telegramLogo, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            _LinkButton(
              label: AppStrings.instagram,
              url: links.instagram,
              onOpen: _open,
              child: const _InstagramIcon(),
            ),
            const SizedBox(width: 12),
            _LinkButton(
              label: AppStrings.facebook,
              url: links.facebook,
              onOpen: _open,
              child: const Icon(PhosphorIconsFill.facebookLogo, color: AppColors.facebook, size: 44),
            ),
          ],
        ),
        if (_openFailed) ...[
          const SizedBox(height: 12),
          const Text(AppStrings.linkOpenError, style: TextStyle(color: AppColors.danger, fontSize: 13)),
        ],
      ],
    );
  }
}

/// أيقونة حساب تفتح رابطه، وتبقى باهتة معطّلة إلى أن يصل الرابط.
class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.label, required this.url, required this.onOpen, required this.child});

  final String label;
  final String? url;
  final ValueChanged<String> onOpen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    return Semantics(
      button: true,
      enabled: url != null,
      label: label,
      child: Opacity(
        opacity: url == null ? 0.4 : 1,
        child: InkWell(
          onTap: url == null ? null : () => onOpen(url),
          customBorder: const CircleBorder(),
          child: Padding(padding: const EdgeInsets.all(2), child: child),
        ),
      ),
    );
  }
}

/// شعار إنستغرام بتدرّجه المعروف.
class _InstagramIcon extends StatelessWidget {
  const _InstagramIcon();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: AppColors.instagramGradient,
      ).createShader(bounds),
      child: const Icon(PhosphorIconsFill.instagramLogo, size: 44),
    );
  }
}
