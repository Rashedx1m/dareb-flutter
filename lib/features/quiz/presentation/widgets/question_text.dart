import 'package:flutter/material.dart';

/// نص سؤال أو جواب قد يخلط العربية بالمعادلات. السطر الذي لا حرف عربياً فيه يُعرض
/// من اليسار إلى اليمين، وإلا قلبه اتجاه الصفحة فظهر «666÷222» بصورة «222÷666».
class QuestionText extends StatelessWidget {
  const QuestionText(this.text, {super.key, required this.style, this.center = false});

  final String text;
  final TextStyle style;

  /// يتوسط كل سطر، كما في خيارات الإجابة. والافتراضي بداية الصفحة.
  final bool center;

  static final _arabic = RegExp('[؀-ۿݐ-ݿࢠ-ࣿﭐ-﷿ﹰ-﻿]');

  /// عربي إن كان في السطر حرف عربي، وإلا من اليسار إلى اليمين.
  static TextDirection directionOf(String line) => _arabic.hasMatch(line) ? TextDirection.rtl : TextDirection.ltr;

  @override
  Widget build(BuildContext context) {
    // السطر اللاتيني يبقى ملاصقاً لبداية الصفحة مع الأسطر العربية حوله.
    final start = Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left;
    final align = center ? TextAlign.center : start;
    final lines = text.split('\n');
    if (lines.length == 1) return Text(text, textDirection: directionOf(text), textAlign: align, style: style);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
      children: [
        for (final line in lines) Text(line, textDirection: directionOf(line), textAlign: align, style: style),
      ],
    );
  }
}
