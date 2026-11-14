import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/tenant.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/services/tenant_service.dart';

void main() {
  setUp(() {
    apiClient.isMockMode = true;
    MockStorageService().reset();
  });

  group('TenantService Mock CRUD Tests', () {
    test('listTenants returns seeded foundations', () async {
      final list = await tenantService.listTenants();
      expect(list, isNotEmpty);
      expect(list.any((t) => t.id == DEFAULT_TENANT_ID), isTrue);
      expect(
          list.any(
              (t) => t.name.contains('Lincoln') || t.name.contains('Yayasan')),
          isTrue);
    });

    test('getTenant returns specific tenant by ID', () async {
      final tenant = await tenantService.getTenant(DEFAULT_TENANT_ID);
      expect(tenant.id, equals(DEFAULT_TENANT_ID));
      expect(tenant.status, equals('ACTIVE'));
    });

    test('createTenant creates a new foundation', () async {
      final created = await tenantService.createTenant(CreateTenantRequest(
        tenantId: 'tenant-muhammadiyah-006',
        name: 'Yayasan Muhammadiyah Pusat',
        legalEntityNumber: 'AHU-1122334.AH.01.04.2022',
        registrationType: 'FOUNDATION',
        address: 'Jl. Menteng Raya No. 62, Jakarta Pusat',
        contactEmail: 'sekretariat@muhammadiyah.id',
        contactPhone: '+62 21 390 1234',
      ));
      expect(created.id, equals('tenant-muhammadiyah-006'));
      expect(created.name, equals('Yayasan Muhammadiyah Pusat'));
      expect(created.status, equals('ACTIVE'));

      final list = await tenantService.listTenants();
      expect(list.any((t) => t.id == 'tenant-muhammadiyah-006'), isTrue);
    });

    test('updateTenant modifies foundation details', () async {
      final updated = await tenantService.updateTenant(
        DEFAULT_TENANT_ID,
        UpdateTenantRequest(
          name: 'Yayasan Pendidikan Lincoln Ilmiya Updated',
          address: '999 New Address Blvd',
          contactEmail: 'updated@lincolnhigh.edu',
          contactPhone: '+1 503 555 9999',
          status: 'ACTIVE',
        ),
      );
      expect(updated.name, equals('Yayasan Pendidikan Lincoln Ilmiya Updated'));
      expect(updated.address, equals('999 New Address Blvd'));

      final reloaded = await tenantService.getTenant(DEFAULT_TENANT_ID);
      expect(
          reloaded.name, equals('Yayasan Pendidikan Lincoln Ilmiya Updated'));
    });

    test('updateTenantStatus modifies status', () async {
      final updated = await tenantService.updateTenantStatus(
          DEFAULT_TENANT_ID, 'SUSPENDED');
      expect(updated.status, equals('SUSPENDED'));

      final reloaded = await tenantService.getTenant(DEFAULT_TENANT_ID);
      expect(reloaded.status, equals('SUSPENDED'));
    });

    test('deleteTenant removes the tenant', () async {
      final deleted = await tenantService.deleteTenant('tenant-stjude-005');
      expect(deleted, isTrue);

      final list = await tenantService.listTenants();
      expect(list.any((t) => t.id == 'tenant-stjude-005'), isFalse);
    });
  });
}
