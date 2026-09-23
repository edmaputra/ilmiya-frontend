import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:ilmiya_app/core/services/api_client.dart';

void main() {
  group('ApiClient Tests', () {
    test('Singleton retains defaults and properties', () {
      final client = ApiClient();
      expect(client.baseUrl, isNotEmpty);
      expect(client.tenantId, equals('tenant-lincoln-high-001'));
      expect(client.isMockMode, isTrue);

      client.tenantId = 'tenant-test-123';
      expect(client.tenantId, equals('tenant-test-123'));
      // Reset
      client.tenantId = 'tenant-lincoln-high-001';
    });

    test('BaseUrl setter strips trailing slashes', () {
      final client = ApiClient();
      client.baseUrl = 'https://api.ilmiya.edu///';
      expect(client.baseUrl, equals('https://api.ilmiya.edu'));
      // Reset
      client.baseUrl = 'http://localhost:8080';
    });

    test('triggerAuthExpired clears token and invokes registered listeners',
        () {
      final client = ApiClient();
      client.token = 'active-access-token';
      client.refreshToken = 'active-refresh-token';

      var expiredFired = false;
      final unsubscribe = client.onAuthExpired(() {
        expiredFired = true;
      });

      client.triggerAuthExpired();

      expect(expiredFired, isTrue);
      expect(client.token, isNull);
      expect(client.refreshToken, isNull);

      unsubscribe();
    });

    test('ApiException holds status, message, and RFC 9457 detail data', () {
      final ex = ApiException(
          403, 'Forbidden', {'detail': 'Requires school:profile:write'});
      expect(ex.statusCode, equals(403));
      expect(ex.message, equals('Forbidden'));
      expect(ex.data?['detail'], equals('Requires school:profile:write'));
      expect(ex.toString(), contains('ApiException(403): Forbidden'));
    });

    test('HTTP GET, POST, PUT, PATCH, DELETE and 204 response', () async {
      final client = ApiClient();
      client.baseUrl = 'https://api.ilmiya.edu';
      client.token = 'test-token';

      await http.runWithClient(() async {
        // GET
        final getRes = await client.request(endpoint: '/api/v1/users');
        expect(getRes, equals({'status': 'ok'}));

        // POST
        final postRes = await client.request(
          endpoint: 'api/v1/users',
          method: 'POST',
          body: {'name': 'Alice'},
        );
        expect(postRes, equals({'created': true}));

        // PUT
        final putRes = await client.request(
          endpoint: '/api/v1/users/1',
          method: 'PUT',
          body: 'raw-string-body',
        );
        expect(putRes, equals({'updated': true}));

        // PATCH
        final patchRes = await client.request(
          endpoint: '/api/v1/users/1',
          method: 'PATCH',
          body: {'status': 'active'},
        );
        expect(patchRes, equals({'patched': true}));

        // DELETE (204 No Content)
        final deleteRes = await client.request(
          endpoint: '/api/v1/users/1',
          method: 'DELETE',
        );
        expect(deleteRes, isNull);
      },
          () => http_testing.MockClient((request) async {
                if (request.method == 'GET') {
                  return http.Response(jsonEncode({'status': 'ok'}), 200);
                } else if (request.method == 'POST') {
                  return http.Response(jsonEncode({'created': true}), 201);
                } else if (request.method == 'PUT') {
                  return http.Response(jsonEncode({'updated': true}), 200);
                } else if (request.method == 'PATCH') {
                  return http.Response(jsonEncode({'patched': true}), 200);
                } else if (request.method == 'DELETE') {
                  return http.Response('', 204);
                }
                return http.Response('Not found', 404);
              }));
    });

    test('Automatic 401 refresh token flow retry', () async {
      final client = ApiClient();
      client.baseUrl = 'https://api.ilmiya.edu';
      client.token = 'expired-token';
      client.refreshToken = 'valid-refresh-token';

      var refreshCalled = false;
      var getAttempts = 0;

      await http.runWithClient(() async {
        final res = await client.request(endpoint: '/api/v1/data');
        expect(res, equals({'data': 'success'}));
        expect(refreshCalled, isTrue);
        expect(client.token, equals('new-token'));
        expect(client.refreshToken, equals('new-refresh-token'));
      },
          () => http_testing.MockClient((request) async {
                if (request.url.path.contains('/api/v1/auth/refresh')) {
                  refreshCalled = true;
                  return http.Response(
                    jsonEncode({
                      'accessToken': 'new-token',
                      'refreshToken': 'new-refresh-token'
                    }),
                    200,
                  );
                }
                if (request.url.path.contains('/api/v1/data')) {
                  getAttempts++;
                  if (getAttempts == 1) {
                    return http.Response('Unauthorized', 401);
                  }
                  return http.Response(jsonEncode({'data': 'success'}), 200);
                }
                return http.Response('Not Found', 404);
              }));
    });

    test('401 refresh failure triggers triggerAuthExpired and throws',
        () async {
      final client = ApiClient();
      client.baseUrl = 'https://api.ilmiya.edu';
      client.token = 'expired-token';
      client.refreshToken = 'invalid-refresh-token';

      var expiredCalled = false;
      final unsub = client.onAuthExpired(() => expiredCalled = true);

      await http.runWithClient(() async {
        await expectLater(
          client.request(endpoint: '/api/v1/data'),
          throwsA(isA<ApiException>()),
        );
      },
          () => http_testing.MockClient((request) async {
                if (request.url.path.contains('/api/v1/auth/refresh')) {
                  return http.Response('Refresh Failed', 403);
                }
                return http.Response('Unauthorized', 401);
              }));

      expect(expiredCalled, isTrue);
      unsub();
    });

    test('Parses RFC 9457 ProblemDetail errors and network exceptions',
        () async {
      final client = ApiClient();
      client.baseUrl = 'https://api.ilmiya.edu';
      client.refreshToken = null;

      // RFC 9457 detail
      await http.runWithClient(() async {
        try {
          await client.request(endpoint: '/api/v1/error');
          fail('Should throw');
        } on ApiException catch (e) {
          expect(e.statusCode, equals(400));
          expect(e.message, equals('Validation Failed'));
          expect(e.data?['detail'], equals('Validation Failed'));
        }
      },
          () => http_testing.MockClient((request) async {
                return http.Response(
                  jsonEncode({'detail': 'Validation Failed'}),
                  400,
                );
              }));

      // RFC 9457 title fallback
      await http.runWithClient(() async {
        try {
          await client.request(endpoint: '/api/v1/error-title');
          fail('Should throw');
        } on ApiException catch (e) {
          expect(e.statusCode, equals(500));
          expect(e.message, equals('Internal Server Error'));
        }
      },
          () => http_testing.MockClient((request) async {
                return http.Response(
                  jsonEncode({'title': 'Internal Server Error'}),
                  500,
                );
              }));

      // Network exception handling
      await http.runWithClient(() async {
        try {
          await client.request(endpoint: '/api/v1/crash');
          fail('Should throw');
        } on ApiException catch (e) {
          expect(e.statusCode, equals(0));
          expect(e.message, contains('Network connection error'));
        }
      },
          () => http_testing.MockClient((request) async {
                throw Exception('Socket timeout');
              }));
    });
  });
}
