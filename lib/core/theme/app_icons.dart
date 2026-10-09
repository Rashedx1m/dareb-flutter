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
  // صفحات الملف الشخصي والدعم.
  static const student = IconData(0xe73e, fontFamily: _family);
  static const question = IconData(0xe3e8, fontFamily: _family);
  static const headset = IconData(0xe584, fontFamily: _family);
  static const envelopeSimpleOpen = IconData(0xe21a, fontFamily: _family);
  static const info = IconData(0xe2ce, fontFamily: _family);
  static const fileText = IconData(0xe23a, fontFamily: _family);
  static const bookOpenUser = IconData(0xede0, fontFamily: _family);
  static const scroll = IconData(0xeb7a, fontFamily: _family);
  static const exam = IconData(0xe742, fontFamily: _family);
  static const notePencil = IconData(0xe34c, fontFamily: _family);
  static const signOut = IconData(0xe42a, fontFamily: _family);
  static const caretLeft = IconData(0xe138, fontFamily: _family);
  static const caretUp = IconData(0xe13c, fontFamily: _family);
  static const xCircle = IconData(0xe4f8, fontFamily: _family);
  static const listBullets = IconData(0xe2f2, fontFamily: _family);
  static const brain = IconData(0xe74e, fontFamily: _family);
  static const chalkboardTeacher = IconData(0xe600, fontFamily: _family);
  static const wrench = IconData(0xe5d4, fontFamily: _family);
  static const camera = IconData(0xe10e, fontFamily: _family);
  static const handCoins = IconData(0xea8c, fontFamily: _family);
  static const calculator = IconData(0xe538, fontFamily: _family);
  static const receipt = IconData(0xe3ec, fontFamily: _family);
}

abstract final class PhosphorIconsFill {
  static const sealCheck = IconData(0xe606, fontFamily: 'PhosphorFill');
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorFill');
  static const image = IconData(0xe2ca, fontFamily: 'PhosphorFill');
  static const books = IconData(0xe758, fontFamily: 'PhosphorFill');
  static const user = IconData(0xe4c2, fontFamily: 'PhosphorFill');
  static const bell = IconData(0xe0ce, fontFamily: 'PhosphorFill');
  static const playCircle = IconData(0xe3d2, fontFamily: 'PhosphorFill');
  static const bookOpen = IconData(0xe0e6, fontFamily: 'PhosphorFill');
  static const videoCamera = IconData(0xe4da, fontFamily: 'PhosphorFill');
  static const filePdf = IconData(0xe702, fontFamily: 'PhosphorFill');
  static const facebookLogo = IconData(0xe226, fontFamily: 'PhosphorFill');
  static const instagramLogo = IconData(0xe2d0, fontFamily: 'PhosphorFill');
  static const telegramLogo = IconData(0xe5bc, fontFamily: 'PhosphorFill');
  static const whatsappLogo = IconData(0xe5d0, fontFamily: 'PhosphorFill');
  static const camera = IconData(0xe10e, fontFamily: 'PhosphorFill');
  static const graduationCap = IconData(0xe62c, fontFamily: 'PhosphorFill');
}
