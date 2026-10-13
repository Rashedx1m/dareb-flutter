/// يحوّل HTML بسيطاً كما يرد في أسئلة الاختبار إلى نص متعدد الأسطر.
abstract final class HtmlText {
  /// `<p>` و`<br>` يصيران أسطرًا، وبقية الوسوم تُحذف، وكيانات مثل `&nbsp;` تُفك.
  static String plain(String html) {
    var text = html.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    text = text.replaceAllMapped(RegExp(r'&(#x[0-9a-fA-F]+|#\d+|[a-zA-Z]+);'), _entity);
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }

  static String _entity(Match match) {
    final body = match.group(1)!;
    if (body.startsWith('#x') || body.startsWith('#X')) {
      return String.fromCharCode(int.parse(body.substring(2), radix: 16));
    }
    if (body.startsWith('#')) {
      return String.fromCharCode(int.parse(body.substring(1)));
    }
    return switch (body) {
      'nbsp' => ' ',
      'amp' => '&',
      'lt' => '<',
      'gt' => '>',
      'quot' => '"',
      'apos' => "'",
      _ => match.group(0)!,
    };
  }
}
