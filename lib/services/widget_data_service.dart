import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Sends the latest weather snapshot to the native Android home-screen widget.
/// This service deliberately does not fetch data: TravelDashboard remains the
/// single source of truth for weather, avoiding duplicate API requests.
class WidgetDataService {
  static const String _providerName = 'TravelWeatherWidgetProvider';

  static String formatTemperature(num? value) {
    if (value == null) return '--°C';
    return '${value.round()}°C';
  }

  static String formatWindSpeed(num? value) {
    if (value == null) return '--';
    return '${value.round()} km/h';
  }

  static Future<void> update({
    required String city,
    required String temperature,
    required String condition,
    required String wind,
    required String updatedAt,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await HomeWidget.saveWidgetData<String>('weather_city', city);
      await HomeWidget.saveWidgetData<String>(
        'weather_temperature',
        temperature,
      );
      await HomeWidget.saveWidgetData<String>(
        'weather_condition',
        condition,
      );
      await HomeWidget.saveWidgetData<String>('weather_wind', wind);
      await HomeWidget.saveWidgetData<String>(
        'weather_updated_at',
        updatedAt,
      );

      await HomeWidget.updateWidget(name: _providerName);
    } catch (error, stackTrace) {
      // Widget failures must never interrupt the main weather dashboard.
      debugPrint('SirSir widget update failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
