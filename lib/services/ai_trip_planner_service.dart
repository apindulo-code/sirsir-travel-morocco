import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Secure client for the SirSir AI backend.
///
/// The Gemini API key must remain on the server. The mobile app only calls
/// this authenticated/configured backend endpoint.
class AiTripPlannerService {
  AiTripPlannerService({
    http.Client? client,
    String? endpoint,
    this.timeout = const Duration(seconds: 30),
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _endpoint = endpoint ?? const String.fromEnvironment('SIRSIR_AI_ENDPOINT');

  final http.Client _client;
  final bool _ownsClient;
  final String _endpoint;
  final Duration timeout;

  Future<String> ask({
    required String question,
    required String language,
  }) async {
    final normalizedQuestion = question.trim();
    if (normalizedQuestion.isEmpty) {
      throw const AiTripPlannerException('اكتب سؤالك أولاً.');
    }
    if (normalizedQuestion.length > 2000) {
      throw const AiTripPlannerException('يجب ألا يتجاوز السؤال 2000 حرف.');
    }

    final uri = Uri.tryParse(_endpoint);
    if (uri == null ||
        !uri.hasAuthority ||
        !(uri.scheme == 'https' ||
            (!kReleaseMode &&
                uri.scheme == 'http' &&
                (uri.host == 'localhost' || uri.host == '127.0.0.1')))) {
      throw const AiTripPlannerException(
        'خدمة المرشد الذكي غير مهيأة. يلزم إعداد عنوان الخادم الآمن.',
      );
    }

    try {
      final response = await _client
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode({
              'message': normalizedQuestion,
              'language': language,
            }),
          )
          .timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AiTripPlannerException(
          response.statusCode == 429
              ? 'الخدمة مشغولة حالياً. حاول بعد قليل.'
              : 'تعذر الحصول على إجابة من المرشد الذكي حالياً.',
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const AiTripPlannerException('استجابة الخادم غير صالحة.');
      }

      final reply = decoded['reply'];
      if (reply is! String || reply.trim().isEmpty) {
        throw const AiTripPlannerException('لم تصل إجابة صالحة من المرشد الذكي.');
      }
      return reply.trim();
    } on TimeoutException {
      throw const AiTripPlannerException(
        'انتهت مهلة الاتصال. تحقق من الإنترنت ثم حاول مجدداً.',
      );
    } on AiTripPlannerException {
      rethrow;
    } on FormatException {
      throw const AiTripPlannerException('تعذر قراءة استجابة الخادم.');
    } catch (_) {
      throw const AiTripPlannerException(
        'تعذر الاتصال بالمرشد الذكي. تحقق من الإنترنت وحاول مجدداً.',
      );
    }
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}

class AiTripPlannerException implements Exception {
  const AiTripPlannerException(this.message);

  final String message;

  @override
  String toString() => message;
}
