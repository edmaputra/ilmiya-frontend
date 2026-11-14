import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/tenant.dart';

void main() {
  group('Tenant Models Tests', () {
    test('TenantResponse serialization and copyWith', () {
      final json = {
        'id': 'tenant-test-001',
        'tenantId': 'tenant-test-001',
        'name': 'Yayasan Pendidikan Lincoln Ilmiya',
        'legalEntityNumber': 'AHU-0012345.AH.01.04.2020',
        'registrationType': 'FOUNDATION',
        'address': '1240 Oakcrest Ave, Portland, OR 97201',
        'contactEmail': 'foundation@lincolnhigh.edu',
        'contactPhone': '+1 503 555 0192',
        'logoUrl': 'https://example.com/logo.png',
        'status': 'ACTIVE',
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-02T00:00:00Z',
      };

      final tenant = TenantResponse.fromJson(json);
      expect(tenant.id, 'tenant-test-001');
      expect(tenant.tenantId, 'tenant-test-001');
      expect(tenant.name, 'Yayasan Pendidikan Lincoln Ilmiya');
      expect(tenant.legalEntityNumber, 'AHU-0012345.AH.01.04.2020');
      expect(tenant.registrationType, 'FOUNDATION');
      expect(tenant.status, 'ACTIVE');

      final serialized = tenant.toJson();
      expect(serialized['id'], 'tenant-test-001');
      expect(serialized['name'], 'Yayasan Pendidikan Lincoln Ilmiya');
      expect(serialized['legalEntityNumber'], 'AHU-0012345.AH.01.04.2020');

      final copied = tenant.copyWith(
        name: 'Yayasan Al-Azhar Updated',
        status: 'SUSPENDED',
      );
      expect(copied.name, 'Yayasan Al-Azhar Updated');
      expect(copied.status, 'SUSPENDED');
      expect(copied.id, 'tenant-test-001');

      final fallback = TenantResponse.fromJson({});
      expect(fallback.id, isEmpty);
      expect(fallback.status, 'ACTIVE');
    });

    test('CreateTenantRequest and UpdateTenantRequest toJson', () {
      final createReq = CreateTenantRequest(
        tenantId: 'tenant-new-001',
        name: 'Yayasan Baru',
        legalEntityNumber: 'AHU-999',
        registrationType: 'FOUNDATION',
        address: 'Jl. Merdeka No. 1',
        contactEmail: 'admin@yayasanbaru.id',
        contactPhone: '+62 21 123456',
        logoUrl: 'https://logo.png',
      );

      final createJson = createReq.toJson();
      expect(createJson['tenantId'], 'tenant-new-001');
      expect(createJson['name'], 'Yayasan Baru');
      expect(createJson['legalEntityNumber'], 'AHU-999');

      final updateReq = UpdateTenantRequest(
        name: 'Yayasan Baru Updated',
        address: 'Jl. Merdeka No. 2',
        contactEmail: 'contact@yayasanbaru.id',
        contactPhone: '+62 21 654321',
        status: 'PENDING',
      );

      final updateJson = updateReq.toJson();
      expect(updateJson['name'], 'Yayasan Baru Updated');
      expect(updateJson['status'], 'PENDING');
      expect(updateJson.containsKey('logoUrl'), isFalse);
    });
  });
}
