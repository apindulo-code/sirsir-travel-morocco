import 'dart:convert';
import 'dart:io';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'widget_data_service.dart';

/// Refreshes the widget from the city actually selected and persisted by
/// TravelDashboard under the SharedPreferences key "travel_city".
class BackgroundService {
  BackgroundService._();

  static const String taskName = 'sirsir.weather.refresh';
  static const String uniqueTaskName = 'sirsir-weather-refresh';

  static const Map<String, List<double>> _cityCoordinates = {
    'طنجة': [35.7595, -5.8340], 'تطوان': [35.5889, -5.3626],
    'المضيق': [35.6850, -5.3250], 'مرتيل': [35.6167, -5.2750],
    'الرباط': [34.0209, -6.8416], 'الدار البيضاء': [33.5731, -7.5898],
    'المحمدية': [33.6866, -7.3830], 'الجديدة': [33.2316, -8.5007],
    'آسفي': [32.2994, -9.2372], 'الصويرة': [31.5085, -9.7595],
    'أكادير': [30.4278, -9.5981], 'مراكش': [31.6295, -7.9811],
    'فاس': [34.0331, -5.0003], 'مكناس': [33.8935, -5.5473],
    'وجدة': [34.6814, -1.9086], 'الناظور': [35.1681, -2.9335],
    'الحسيمة': [35.2517, -3.9372], 'شفشاون': [35.1688, -5.2636],
    'العرائش': [35.1932, -6.1561], 'القنيطرة': [34.2610, -6.5802],
    'بني ملال': [32.3373, -6.3498], 'خريبكة': [32.8811, -6.9063],
    'ورزازات': [30.9335, -6.9370], 'العيون': [27.1536, -13.2033],
    'الداخلة': [23.6848, -15.9570],
  };

  static Future<void> initialize() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    await Workmanager().registerPeriodicTask(
      uniqueTaskName,
      taskName,
      frequency: const Duration(hours: 3),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  static String conditionForCode(num? value) {
    final code = value?.toInt() ?? -1;
    if (code == 0) return 'صحو';
    if (code >= 1 && code <= 3) return 'غائم';
    if (code == 45 || code == 48) return 'ضباب';
    if (code >= 51 && code <= 67) return 'رذاذ أو أمطار';
    if (code >= 71 && code <= 86) return 'ثلوج';
    if (code >= 95) return 'عواصف رعدية';
    return 'متغير';
  }

  static Future<bool> refreshWeather() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedCity = preferences.getString('travel_city');
      final city = savedCity != null && _cityCoordinates.containsKey(savedCity)
          ? savedCity
          : 'الدار البيضاء';
      final coordinates = _cityCoordinates[city]!;
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': coordinates[0].toString(),
        'longitude': coordinates[1].toString(),
        'current': 'temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m',
        'timezone': 'auto',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) return false;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> ||
          decoded['current'] is! Map<String, dynamic>) {
        return false;
      }
      final current = decoded['current'] as Map<String, dynamic>;
      final temperature = current['temperature_2m'];
      final wind = current['wind_speed_10m'];
      if (temperature is! num || wind is! num) return false;

      await WidgetDataService.update(
        city: city,
        temperature: WidgetDataService.formatTemperature(temperature),
        condition: conditionForCode(current['weather_code'] as num?),
        wind: WidgetDataService.formatWindSpeed(wind),
        updatedAt: DateTime.now().toLocal().toString().substring(0, 16),
      );
      await preferences.setInt(
        'sirsir_weather_background_last_success',
        DateTime.now().millisecondsSinceEpoch,
      );
      return true;
    } catch (error, stack) {
      debugPrint('SirSir background weather refresh failed: $error');
      debugPrintStack(stackTrace: stack);
      return false;
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    DartPluginRegistrant.ensureInitialized();
    if (task != BackgroundService.taskName) return true;
    return BackgroundService.refreshWeather();
  });
}
