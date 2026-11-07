import 'package:flutter_test/flutter_test.dart';
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
}
