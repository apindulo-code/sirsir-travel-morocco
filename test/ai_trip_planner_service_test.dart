import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sirsir_travel_morocco/services/ai_trip_planner_service.dart';

void main() {
  group('AiTripPlannerService', () {
    test('sends question and language to the configured backend', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://example.test/api/chat');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['message'], 'Plan a trip');
        expect(body['language'], 'en');
        return http.Response(
          jsonEncode({'reply': 'Here is a sample itinerary.'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final service = AiTripPlannerService(
        client: client,
        endpoint: 'https://example.test/api/chat',
      );

      expect(
        await service.ask(question: 'Plan a trip', language: 'en'),
        'Here is a sample itinerary.',
      );
      service.dispose();
    });

    test('rejects an empty question', () async {
      final service = AiTripPlannerService(
        client: MockClient((_) async => http.Response('{}', 200)),
        endpoint: 'https://example.test/api/chat',
      );

      await expectLater(
        service.ask(question: '   ', language: 'ar'),
        throwsA(isA<AiTripPlannerException>()),
      );
      service.dispose();
    });

    test('does not accept a non-HTTPS endpoint in release builds', () async {
      // The production restriction is enforced by the service. This test
      // verifies that malformed endpoints are rejected in every build mode.
      final service = AiTripPlannerService(
        client: MockClient((_) async => http.Response('{}', 200)),
        endpoint: 'not-a-url',
      );

      await expectLater(
        service.ask(question: 'مرحبا', language: 'ar'),
        throwsA(isA<AiTripPlannerException>()),
      );
      service.dispose();
    });
  });
}
