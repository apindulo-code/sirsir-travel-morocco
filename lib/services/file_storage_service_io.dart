import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Android/iOS implementation. share_plus owns the merged FileProvider.
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
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${sanitizeFileName(fileName)}');
    await file.writeAsString(contents, flush: true);
    return file.path;
  }

  static Future<void> shareFile(
    String savedPath, {
    String? text,
    String? subject,
  }) async {
    final savedFile = File(savedPath);
    if (!await savedFile.exists()) {
      throw FileSystemException('The file to share does not exist', savedFile.path);
    }
    // share_plus exposes cache paths through its own FileProvider.
    final cache = await getTemporaryDirectory();
    final shareCopy = File('${cache.path}/${savedFile.uri.pathSegments.last}');
    await savedFile.copy(shareCopy.path);
    await Share.shareXFiles(
      [XFile(shareCopy.path, mimeType: 'text/plain')],
      text: text,
      subject: subject,
    );
  }

  static Future<void> saveAndShareText({
    required String fileName,
    required String contents,
    String? subject,
  }) async {
    final path = await saveTextFile(fileName: fileName, contents: contents);
    await shareFile(path, subject: subject);
  }
}
