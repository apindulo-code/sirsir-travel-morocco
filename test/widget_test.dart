import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/main.dart';

void main() {
  test('Arabic is the default application language', () {
    expect(appLanguage.value, 'ar');
    expect(tr('اكتشف المغرب معنا'), 'اكتشف المغرب معنا');
  });

  test('Moroccan city labels remain available in Arabic', () {
    expect(cityLabel('تطوان'), 'تطوان');
    expect(cityLabel('طنجة'), 'طنجة');
  });

  testWidgets('the home screen renders its first frame', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SirSirApp());
    expect(find.text('اكتشف المغرب معنا'), findsOneWidget);
    expect(find.text('ابحث عن رحلتك'), findsOneWidget);
  });
}
