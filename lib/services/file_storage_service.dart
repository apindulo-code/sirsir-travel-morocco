import 'file_storage_service_stub.dart'
    if (dart.library.io) 'file_storage_service_io.dart' as platform;

/// Cross-platform facade; the mobile implementation is isolated from web builds.
class FileStorageService {
  FileStorageService._();

  static String sanitizeFileName(String value) =>
      platform.FileStorageServicePlatform.sanitizeFileName(value);

  static Future<String> saveTextFile({
    required String fileName,
    required String contents,
  }) =>
      platform.FileStorageServicePlatform.saveTextFile(
        fileName: fileName,
        contents: contents,
      );

  static Future<void> shareFile(
    String savedPath, {
    String? text,
    String? subject,
  }) =>
      platform.FileStorageServicePlatform.shareFile(
        savedPath,
        text: text,
        subject: subject,
      );

  static Future<void> saveAndShareText({
    required String fileName,
    required String contents,
    String? subject,
  }) =>
      platform.FileStorageServicePlatform.saveAndShareText(
        fileName: fileName,
        contents: contents,
        subject: subject,
      );
}
