/// Web fallback. Local filesystem paths and native file sharing are unavailable.
class FileStorageServicePlatform {
  static String sanitizeFileName(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final trimmed = cleaned.replaceAll(RegExp(r'^[_ .]+|[_ .]+$'), '');
    return trimmed.isEmpty ? 'sirsir-export.txt' : trimmed;
  }

  static Future<String> saveTextFile({
    required String fileName,
    required String contents,
  }) =>
      Future<String>.error(
        UnsupportedError('Local file storage is available on Android and iOS.'),
      );

  static Future<void> shareFile(
    String savedPath, {
    String? text,
    String? subject,
  }) =>
      Future<void>.error(
        UnsupportedError('File sharing is available on Android and iOS.'),
      );

  static Future<void> saveAndShareText({
    required String fileName,
    required String contents,
    String? subject,
  }) =>
      Future<void>.error(
        UnsupportedError('File sharing is available on Android and iOS.'),
      );
}
