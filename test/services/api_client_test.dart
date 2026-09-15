import 'package:flutter_test/flutter_test.dart';
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

    test('triggerAuthExpired clears token and invokes registered listeners', () {
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
      final ex = ApiException(403, 'Forbidden', {'detail': 'Requires school:profile:write'});
      expect(ex.statusCode, equals(403));
      expect(ex.message, equals('Forbidden'));
      expect(ex.data?['detail'], equals('Requires school:profile:write'));
      expect(ex.toString(), contains('ApiException(403): Forbidden'));
    });
  });
}
