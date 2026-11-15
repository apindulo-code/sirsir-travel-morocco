import 'package:flutter_test/flutter_test.dart';
import '../lib/services/background_service.dart';
import '../lib/services/file_storage_service.dart';

void main() {
  group('BackgroundService', () {
    test('maps Open-Meteo codes to readable weather conditions', () {
      expect(BackgroundService.conditionForCode(0), 'صحو');
      expect(BackgroundService.conditionForCode(2), 'غائم');
      expect(BackgroundService.conditionForCode(61), 'رذاذ أو أمطار');
      expect(BackgroundService.conditionForCode(95), 'عواصف رعدية');
      expect(BackgroundService.conditionForCode(null), 'متغير');
    });
  });

  group('FileStorageService', () {
    test('removes unsafe path characters from export names', () {
      expect(FileStorageService.sanitizeFileName('../weather:report?.txt'),
          'weather_report_.txt');
    });

    test('uses a safe fallback for an empty filename', () {
      expect(FileStorageService.sanitizeFileName(' ../ '), 'sirsir-export.txt');
    });
  });
}
