import 'package:educational_app/core/widgets/refresh_on_return.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('يُستدعى عند كل ظهور بعد إخفاء، لا عند البناء الأول ولا عند الإخفاء', (tester) async {
    final visible = ValueNotifier(true);
    var returns = 0;
    await tester.pumpWidget(
      ValueListenableBuilder<bool>(
        valueListenable: visible,
        builder: (_, enabled, _) => TickerMode(
          enabled: enabled,
          child: RefreshOnReturn(onReturn: () => returns++, child: const SizedBox()),
        ),
      ),
    );
    expect(returns, 0);

    visible.value = false;
    await tester.pump();
    expect(returns, 0);

    visible.value = true;
    await tester.pump();
    expect(returns, 1);

    visible.value = false;
    await tester.pump();
    visible.value = true;
    await tester.pump();
    expect(returns, 2);
  });
}
