import 'package:flutter_test/flutter_test.dart';
import '../lib/services/widget_data_service.dart';

void main() {
  group('WidgetDataService formatting', () {
    test('formats temperatures as whole Celsius degrees', () {
      expect(WidgetDataService.formatTemperature(21.6), '22°C');
      expect(WidgetDataService.formatTemperature(-2.2), '-2°C');
    });

    test('uses a safe placeholder when temperature is unavailable', () {
      expect(WidgetDataService.formatTemperature(null), '--°C');
    });

    test('formats wind speed in kilometres per hour', () {
      expect(WidgetDataService.formatWindSpeed(14.7), '15 km/h');
      expect(WidgetDataService.formatWindSpeed(null), '--');
    });
  });
}
