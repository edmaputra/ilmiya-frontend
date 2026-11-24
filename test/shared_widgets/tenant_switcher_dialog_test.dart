import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/services/tenant_service.dart';
import 'package:ilmiya_app/shared_widgets/navigation/app_shell_tenant_dialog.dart';
import 'package:ilmiya_app/shared_widgets/navigation/header_tenant_switcher_dialog.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

void main() {
  group('Tenant Switcher Dialog Tests', () {
    late ApiClient client;
    late MockStorageService storage;
    late IamService iam;
    late TenantService tenantService;
    late AuthNotifier authNotifier;

    setUp(() {
      client = apiClient;
      client.isMockMode = true;
      storage = MockStorageService();
      storage.reset();
      iam = IamService(apiClient: client, mockStorage: storage);
      tenantService = TenantService(apiClient: client, mockStorage: storage);
      authNotifier = AuthNotifier(
        iamService: iam,
        apiClient: client,
        tenantService: tenantService,
      );
    });

    Widget buildTestHost({required Widget child}) {
      return ChangeNotifierProvider<AuthNotifier>.value(
        value: authNotifier,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => child,
            ),
          ),
        ),
      );
    }

    testWidgets(
        'AppShellTenantDialog renders header, search field, and tenant list',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestHost(
          child: AppShellTenantDialog(
            auth: authNotifier,
            tenantService: tenantService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Switch Tenant'), findsWidgets);
      expect(find.byKey(const Key('tenant_search_field')), findsOneWidget);

      // Verify tenants loaded at tenant level from mock storage
      expect(find.text('Yayasan Pendidikan Lincoln Ilmiya'), findsOneWidget);
      expect(find.text('Yayasan Pesantren Islam Al-Azhar'), findsOneWidget);
      expect(find.text('CURRENT'), findsOneWidget);
    });

    testWidgets('AppShellTenantDialog filters tenants by name in real-time',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestHost(
          child: AppShellTenantDialog(
            auth: authNotifier,
            tenantService: tenantService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query "Azhar"
      await tester.enterText(
          find.byKey(const Key('tenant_search_field')), 'Azhar');
      await tester.pumpAndSettle();

      expect(find.text('Yayasan Pesantren Islam Al-Azhar'), findsOneWidget);
      expect(find.text('Yayasan Pendidikan Lincoln Ilmiya'), findsNothing);

      // Clear search
      final clearBtn = find.byIcon(LucideIcons.x).at(1);
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();

      expect(find.text('Yayasan Pendidikan Lincoln Ilmiya'), findsOneWidget);
      expect(find.text('Yayasan Pesantren Islam Al-Azhar'), findsOneWidget);
    });

    testWidgets('AppShellTenantDialog filters tenants by tenant ID',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestHost(
          child: AppShellTenantDialog(
            auth: authNotifier,
            tenantService: tenantService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('tenant_search_field')), 'tenant-horizon');
      await tester.pumpAndSettle();

      expect(find.text('Horizon STEM Education Trust'), findsOneWidget);
      expect(find.text('Yayasan Pesantren Islam Al-Azhar'), findsNothing);
    });

    testWidgets(
        'AppShellTenantDialog displays empty state and quick action for unknown query',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestHost(
          child: AppShellTenantDialog(
            auth: authNotifier,
            tenantService: tenantService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('tenant_search_field')), 'tenant-custom-999');
      await tester.pumpAndSettle();

      expect(find.text('No tenants match "tenant-custom-999"'), findsOneWidget);
      final useActionBtn = find.text('Use "tenant-custom-999" as Tenant ID');
      expect(useActionBtn, findsOneWidget);

      await tester.tap(useActionBtn);
      await tester.pumpAndSettle();

      // Custom tenant field receives the value
      final customField = tester
          .widget<TextField>(find.byKey(const Key('custom_tenant_field')));
      expect(customField.controller?.text, 'tenant-custom-999');
    });

    testWidgets('Selecting a tenant and tapping Switch Tenant switches tenant',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestHost(
          child: ElevatedButton(
            onPressed: () => AppShellTenantDialog.show(
              tester.element(find.byType(ElevatedButton)),
              authNotifier,
              tenantService: tenantService,
            ),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Yayasan Pesantren Islam Al-Azhar'), findsOneWidget);

      // Tap on Al-Azhar tenant
      await tester
          .tap(find.byKey(const ValueKey('tenant_tile_tenant-alazhar-003')));
      await tester.pumpAndSettle();

      // Tap Switch Tenant
      await tester.tap(find.byKey(const Key('switch_tenant_btn')));
      await tester.pumpAndSettle();

      // Dialog should be dismissed and tenant switched
      expect(find.byType(AppShellTenantDialog), findsNothing);
      expect(authNotifier.tenantId, 'tenant-alazhar-003');
    });

    testWidgets(
        'HeaderTenantSwitcherDialog.show opens the tenant switcher dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestHost(
          child: ElevatedButton(
            onPressed: () => HeaderTenantSwitcherDialog.show(
              tester.element(find.byType(ElevatedButton)),
              authNotifier,
              tenantService: tenantService,
            ),
            child: const Text('Open From Header'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open From Header'));
      await tester.pumpAndSettle();

      expect(find.byType(AppShellTenantDialog), findsOneWidget);
      expect(find.text('Switch Multi-Tenant Context'), findsOneWidget);
    });
  });
}
