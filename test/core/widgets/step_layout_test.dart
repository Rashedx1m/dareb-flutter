import 'package:educational_app/core/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({required double height, required List<Widget> children}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            height: height,
            width: 300,
            child: StepLayout(children: children),
          ),
        ),
      ),
    );
  }

  // محتوى أطول من أي شاشة قصيرة: كان يسبّب الفيضان في خطوات التسجيل.
  List<Widget> tallContent() => <Widget>[
        for (var i = 0; i < 8; i++)
          Container(height: 80, margin: const EdgeInsets.only(bottom: 8), color: Colors.blue),
        const Spacer(),
        const SizedBox(height: 50, child: Text('زر')),
      ];

  testWidgets('لا يفيض حين يتجاوز المحتوى الارتفاع المتاح ويصبح قابلاً للتمرير', (tester) async {
    await tester.pumpWidget(host(height: 300, children: tallContent()));
    await tester.pumpAndSettle();

    // لا استثناء فيضان (RenderFlex overflowed) في الإطار.
    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsOneWidget);

    // يمكن التمرير للوصول إلى الزر السفلي دون رمي استثناء.
    await tester.drag(find.byType(Scrollable), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('زر'), findsOneWidget);
  });

  testWidgets('يدفع العنصر السفلي إلى الأسفل عبر Spacer حين تتوفّر مساحة', (tester) async {
    await tester.pumpWidget(host(height: 500, children: const [
      SizedBox(height: 60, child: Text('أعلى')),
      Spacer(),
      SizedBox(height: 50, child: Text('زر')),
    ]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // الزر مدفوع نحو الأسفل (لا ملتصق بالأعلى)، ما يؤكّد أن Spacer ما زال يعمل.
    final buttonBottom = tester.getBottomLeft(find.text('زر')).dy;
    expect(buttonBottom, greaterThan(400));
  });
}
