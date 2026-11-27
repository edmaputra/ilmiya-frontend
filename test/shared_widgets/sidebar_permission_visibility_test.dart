import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/services/session_storage_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/shared_widgets/navigation/app_shell_sidebar.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';

class _ScopedIamService extends IamService {
  _ScopedIamService({
    required super.apiClient,
    required super.mockStorage,
    required List<String> permissions,
  }) : _permissions = permissions;

  final List<String> _permissions;

  @override
  Future<UserProfileResponse> getMe() async {
    return UserProfileResponse(
      id: 'u-scoped-test',
      email: 'scoped@ilmiya.edu',
      fullName: 'Scoped User',
      tenantId: 'tenant-lincoln-high-001',
      roles: const ['USER'],
      permissions: _permissions,
      scopes: const ['/CAMPUS_MAIN'],
    );
  }
}

void main() {
  late ApiClient apiClient;
  late MockStorageService mockStorage;
  late AppState appState;

  setUp(() {
    apiClient = ApiClient()..isMockMode = true;
    mockStorage = MockStorageService();
    appState = AppState();
    MockStorageService().reset();
    SessionStorageService().resetForTesting();
    apiClient.resetTenantId();
  });

  Widget buildHost(AuthNotifier auth) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthNotifier>.value(value: auth),
        ChangeNotifierProvider<AppState>.value(value: appState),
      ],
      child: ShadTheme(
        data: AppTheme.shadLightTheme,
        child: const MaterialApp(
          home: Scaffold(body: SizedBox(width: 1200, child: AppShellSidebar())),
        ),
      ),
    );
  }

  Future<AuthNotifier> scopedAuth(List<String> permissions) async {
    final auth = AuthNotifier(
      apiClient: apiClient,
      iamService: _ScopedIamService(
        apiClient: apiClient,
        mockStorage: mockStorage,
        permissions: permissions,
      ),
    );
    await auth.refreshProfile();
    return auth;
  }

  Future<void> pumpSidebar(WidgetTester tester, AuthNotifier auth) async {
    await tester.pumpWidget(buildHost(auth));
    await tester.pumpAndSettle();
  }

  testWidgets('a single IAM permission exposes the IAM Console',
      (tester) async {
    final auth = await scopedAuth(const ['iam:user:read']);
    await pumpSidebar(tester, auth);

    expect(find.text('IAM Console'), findsOneWidget);
    expect(find.text('School Profile'), findsNothing);
    expect(find.text('Academic Years'), findsNothing);
    expect(find.text('Tenant Console'), findsNothing);
  });

  testWidgets('Schools & Campuses is independent of School Profile',
      (tester) async {
    final auth = await scopedAuth(const ['school:campus:read']);
    await pumpSidebar(tester, auth);

    expect(find.text('Schools & Campuses'), findsOneWidget);
    expect(find.text('School Profile'), findsNothing);
  });

  testWidgets('canonical academic year code exposes Academic Years',
      (tester) async {
    final auth = await scopedAuth(const ['academic:year:write']);
    await pumpSidebar(tester, auth);

    expect(find.text('Academic Years'), findsOneWidget);

    final legacyAuth = await scopedAuth(const ['academic-year:read']);
    await pumpSidebar(tester, legacyAuth);
    expect(find.text('Academic Years'), findsNothing);
  });

  testWidgets('flag-gated menus remain hidden regardless of permissions',
      (tester) async {
    final auth = await scopedAuth(const [
      'academic:course:read',
      'school:profile:write',
      'school:settings:manage',
    ]);
    await pumpSidebar(tester, auth);

    expect(find.text('School Profile'), findsOneWidget);
    expect(find.text('Executive Dashboard'), findsNothing);
    expect(find.text('Courses & Grades'), findsNothing);
  });

  testWidgets('platform superadmin keeps only the Tenant Console',
      (tester) async {
    final auth = AuthNotifier();
    await auth.loginAsPersona(DemoPersonaKey.superadmin);
    await pumpSidebar(tester, auth);

    expect(find.text('Tenant Console'), findsOneWidget);
    expect(find.text('School Profile'), findsNothing);
    expect(find.text('IAM Console'), findsNothing);
  });
}
