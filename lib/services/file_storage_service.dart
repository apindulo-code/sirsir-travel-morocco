import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Saves durable files in app documents and shares a cache copy.
/// share_plus supplies its own Android FileProvider via manifest merging.
class FileStorageService {
  FileStorageService._();

  static String sanitizeFileName(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final trimmed = cleaned.replaceAll(RegExp(r'^[_ .]+|[_ .]+$'), '');
    return trimmed.isEmpty ? 'sirsir-export.txt' : trimmed;
  }

  static Future<File> saveTextFile({
    required String fileName,
    required String contents,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Local file storage is available on mobile devices.');
    }
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${sanitizeFileName(fileName)}');
    await file.writeAsString(contents, flush: true);
    return file;
  }

  static Future<void> shareFile(
    File savedFile, {
    String? text,
    String? subject,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('File sharing is available on mobile devices.');
    }
    if (!await savedFile.exists()) {
      throw FileSystemException('The file to share does not exist', savedFile.path);
    }
    // share_plus FileProvider exposes cache paths; retain the durable original.
    final cache = await getTemporaryDirectory();
    final shareCopy = File('${cache.path}/${savedFile.uri.pathSegments.last}');
    await savedFile.copy(shareCopy.path);
    await Share.shareXFiles(
      [XFile(shareCopy.path, mimeType: 'text/plain')],
      text: text,
      subject: subject,
    );
  }

  static Future<File> saveAndShareText({
    required String fileName,
    required String contents,
    String? subject,
  }) async {
    final file = await saveTextFile(fileName: fileName, contents: contents);
    await shareFile(file, subject: subject);
    return file;
  }
}
