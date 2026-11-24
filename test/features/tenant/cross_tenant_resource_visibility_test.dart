import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/services/school_service.dart';
import 'package:ilmiya_app/core/services/session_storage_service.dart';
import 'package:ilmiya_app/core/services/tenant_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/academic_years/presentation/academic_years_screen.dart';
import 'package:ilmiya_app/features/iam_management/presentation/iam_management_screen.dart';
import 'package:ilmiya_app/features/school_profile/presentation/schools_campuses_screen.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';

void main() {
  late ApiClient apiClient;
  late MockStorageService mockStorage;
  late IamService iamService;
  late SchoolService schoolService;
  late TenantService tenantService;
  late AuthNotifier authNotifier;
  late AppState appState;

  setUp(() {
    apiClient = ApiClient()..isMockMode = true;
    apiClient.resetTenantId();
    mockStorage = MockStorageService();
    mockStorage.reset();
    SessionStorageService().resetForTesting();
    iamService = IamService(apiClient: apiClient, mockStorage: mockStorage);
    schoolService =
        SchoolService(apiClient: apiClient, mockStorage: mockStorage);
    tenantService =
        TenantService(apiClient: apiClient, mockStorage: mockStorage);
    authNotifier = AuthNotifier(
      apiClient: apiClient,
      iamService: iamService,
      schoolService: schoolService,
      tenantService: tenantService,
    );
    appState = AppState();
  });

  Widget buildTestHost(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthNotifier>.value(value: authNotifier),
        ChangeNotifierProvider<AppState>.value(value: appState),
      ],
      child: ShadTheme(
        data: AppTheme.shadLightTheme,
        child: MaterialApp(
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  void setUpViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('Cross-Tenant Resource Visibility Isolation Tests', () {
    testWidgets(
        'Superadmin switched to tenant-sma1-ilmiya-002 only sees resources of that tenant',
        (WidgetTester tester) async {
      setUpViewport(tester);

      // Login as Superadmin persona
      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);
      expect(authNotifier.isPlatformSession, isTrue);

      // Switch session to tenant-sma1-ilmiya-002
      await authNotifier.switchTenant('tenant-sma1-ilmiya-002');
      await tester.pumpAndSettle();

      // 1. IAM Management Screen
      await tester.pumpWidget(buildTestHost(const IamManagementScreen()));
      await tester.pumpAndSettle();

      // User List: Only Dra. Nurhayati should be visible
      expect(
          find.text('Dra. Nurhayati (Kepala SMAN 1 Ilmiya)'), findsOneWidget);
      expect(find.text('Prof. Marcus Chen (School Principal)'), findsNothing);
      expect(find.text('Dr. Eleanor Vance (Computer Science Faculty)'),
          findsNothing);
      expect(find.text('Alex Rivera (Class 10-A)'), findsNothing);

      // Switch to Groups tab (index 2)
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();

      // Lincoln High groups should NOT be visible
      expect(find.text('STEM Faculty Department'), findsNothing);
      expect(find.text('Class 10 Student Cohort'), findsNothing);

      // 2. Schools & Campuses Screen
      await tester.pumpWidget(buildTestHost(const SchoolsCampusesScreen()));
      await tester.pumpAndSettle();

      // SMAN 1 Ilmiya should be visible; Lincoln High should NOT
      expect(find.text('SMA Negeri 1 Ilmiya'), findsOneWidget);
      expect(find.text('Lincoln High School'), findsNothing);

      // 3. Academic Years Screen
      await tester.pumpWidget(buildTestHost(const AcademicYearsScreen()));
      await tester.pumpAndSettle();

      // SMAN 1 Ilmiya academic year should be visible; Lincoln High's 2025/2026 should not leak
      expect(find.byType(AcademicYearsScreen), findsOneWidget);
    });

    testWidgets(
        'Superadmin switched to tenant-lincoln-high-001 only sees Lincoln High resources',
        (WidgetTester tester) async {
      setUpViewport(tester);

      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);
      await authNotifier.switchTenant('tenant-lincoln-high-001');
      await tester.pumpAndSettle();

      // Render IAM Management Screen
      await tester.pumpWidget(buildTestHost(const IamManagementScreen()));
      await tester.pumpAndSettle();

      // User List: Lincoln High users visible, Dra. Nurhayati NOT visible
      expect(find.text('Prof. Marcus Chen (School Principal)'), findsOneWidget);
      expect(find.text('Dr. Eleanor Vance (Computer Science Faculty)'),
          findsOneWidget);
      expect(find.text('Dra. Nurhayati (Kepala SMAN 1 Ilmiya)'), findsNothing);

      // Switch to Groups tab
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();

      // Lincoln High groups should be visible
      expect(find.text('STEM Faculty Department'), findsOneWidget);
      expect(find.text('Class 10 Student Cohort'), findsOneWidget);

      // Render Schools & Campuses Screen
      await tester.pumpWidget(buildTestHost(const SchoolsCampusesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('SMA Negeri 1 Ilmiya (Lincoln High Campus)'),
          findsOneWidget);
      expect(find.text('Al-Azhar Islamic Academy'), findsNothing);
    });

    testWidgets(
        'Superadmin switched to empty tenant (tenant-alazhar-003) does not leak users from other tenants',
        (WidgetTester tester) async {
      setUpViewport(tester);

      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);
      await authNotifier.switchTenant('tenant-alazhar-003');
      await tester.pumpAndSettle();

      await tester.pumpWidget(buildTestHost(const IamManagementScreen()));
      await tester.pumpAndSettle();

      // No users from other tenants should leak
      expect(find.text('Prof. Marcus Chen (School Principal)'), findsNothing);
      expect(find.text('Dr. Eleanor Vance (Computer Science Faculty)'),
          findsNothing);
      expect(find.text('Alex Rivera (Class 10-A)'), findsNothing);
      expect(find.text('Dra. Nurhayati (Kepala SMAN 1 Ilmiya)'), findsNothing);
    });
  });
}
