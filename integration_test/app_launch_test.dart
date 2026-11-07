import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sirsir_travel_morocco/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android launches SirSir and renders the home screen', (tester) async {
    await app.main();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    expect(find.text('اكتشف المغرب معنا'), findsOneWidget);
    expect(find.text('ابحث عن رحلتك'), findsOneWidget);
  });
}
