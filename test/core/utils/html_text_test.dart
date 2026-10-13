import 'package:educational_app/core/utils/html_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('فقرة وbr يصيران أسطرًا وتُحذف الوسوم', () {
    expect(
      HtmlText.plain('<p>ان ناتج العملية التالية هو :</p><p><br></p><p>77+33</p>'),
      'ان ناتج العملية التالية هو :\n\n77+33',
    );
  });

  test('يفك الكيانات الشائعة والرقمية', () {
    expect(HtmlText.plain('أ&nbsp;ب &amp; ج &lt;د&gt; &#39;ه&#x22;'), "أ ب & ج <د> 'ه\"");
  });

  test('نص بلا HTML يبقى كما هو', () {
    expect(HtmlText.plain('110'), '110');
  });
}
