import 'package:flutter/widgets.dart';

/// أيقونات Phosphor مضمّنة كخط داخل المشروع (بدل حزمة phosphor_flutter التي
/// لا تتوافق مع فلاتر الحالي لأنها ترث IconData النهائية).
///
/// نفس رموز أيقونات Phosphor الرسمية، تُستخدم كأيقونة عادية:
///   Icon(PhosphorIconsRegular.phone, size: 20, color: ...)
///
/// الخطوط معرّفة في pubspec.yaml بعائلتي: Phosphor (Regular) و PhosphorFill.
abstract final class PhosphorIconsRegular {
  static const _family = 'Phosphor';

  static const arrowRight = IconData(0xe06c, fontFamily: _family);
  static const userCircle = IconData(0xe4c4, fontFamily: _family);
  static const envelopeSimple = IconData(0xe218, fontFamily: _family);
  static const phone = IconData(0xe3b8, fontFamily: _family);
  static const graduationCap = IconData(0xe62c, fontFamily: _family);
  static const caretDown = IconData(0xe136, fontFamily: _family);
  static const bank = IconData(0xe0b4, fontFamily: _family);
  static const genderMale = IconData(0xe6e2, fontFamily: _family);
  static const genderFemale = IconData(0xe6e0, fontFamily: _family);
  static const flask = IconData(0xe79e, fontFamily: _family);
  static const bookOpen = IconData(0xe0e6, fontFamily: _family);
  static const users = IconData(0xe4d6, fontFamily: _family);
  static const facebookLogo = IconData(0xe226, fontFamily: _family);
  static const instagramLogo = IconData(0xe2d0, fontFamily: _family);
  static const youtubeLogo = IconData(0xe4fc, fontFamily: _family);
  static const dotsThreeCircle = IconData(0xe200, fontFamily: _family);
  static const bell = IconData(0xe0ce, fontFamily: _family);
  static const magnifyingGlass = IconData(0xe30c, fontFamily: _family);
  static const medal = IconData(0xe320, fontFamily: _family);
  static const house = IconData(0xe2c2, fontFamily: _family);
  static const image = IconData(0xe2ca, fontFamily: _family);
  static const books = IconData(0xe758, fontFamily: _family);
  static const user = IconData(0xe4c2, fontFamily: _family);
  static const handWaving = IconData(0xe580, fontFamily: _family);
  static const trophy = IconData(0xe67e, fontFamily: _family);
}

abstract final class PhosphorIconsFill {
  static const sealCheck = IconData(0xe606, fontFamily: 'PhosphorFill');
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorFill');
  static const image = IconData(0xe2ca, fontFamily: 'PhosphorFill');
  static const books = IconData(0xe758, fontFamily: 'PhosphorFill');
  static const user = IconData(0xe4c2, fontFamily: 'PhosphorFill');
}
