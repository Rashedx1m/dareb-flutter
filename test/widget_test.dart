import 'package:educational_app/app.dart';
import 'package:educational_app/core/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
  });

  testWidgets('shows splash brand', (tester) async {
    await tester.pumpWidget(DarbApp());
    expect(find.bySemanticsLabel('درب'), findsWidgets);
  });
}
