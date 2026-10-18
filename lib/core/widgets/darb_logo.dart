import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_strings.dart';
import '../theme/app_assets.dart';

class DarbLogo extends StatelessWidget {
  const DarbLogo({
    super.key,
    this.size = 88,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.appName,
      child: SvgPicture.asset(
        AppAssets.logo,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
