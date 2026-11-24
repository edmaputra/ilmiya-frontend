import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/constants/app_version.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/services/school_service.dart';
import 'package:ilmiya_app/core/services/session_storage_service.dart';
import 'package:ilmiya_app/core/services/tenant_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/profile/presentation/user_profile_screen.dart';
import 'package:ilmiya_app/shared_widgets/navigation/app_shell_sidebar.dart';
import 'package:ilmiya_app/shared_widgets/navigation/app_shell_sidebar_footer.dart';
import 'package:ilmiya_app/shared_widgets/navigation/app_shell_user_menu.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

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

  group('AppVersion UI Rendering Tests', () {
    testWidgets('AppShellSidebar displays version badge in brand header',
        (WidgetTester tester) async {
      setUpViewport(tester);
      await authNotifier.loginAsPersona(DemoPersonaKey.teacher);

      await tester.pumpWidget(buildTestHost(const AppShellSidebar()));
      await tester.pumpAndSettle();

      final headerBadge = find.byKey(const Key('sidebar_header_version_badge'));
      expect(headerBadge, findsOneWidget);
      expect(
          find.descendant(of: headerBadge, matching: find.text(AppVersion.tag)),
          findsOneWidget);
    });

    testWidgets(
        'AppShellSidebarFooter displays version tag next to backend pill',
        (WidgetTester tester) async {
      setUpViewport(tester);
      await authNotifier.loginAsPersona(DemoPersonaKey.teacher);

      await tester.pumpWidget(buildTestHost(AppShellSidebarFooter(
        state: appState,
        auth: authNotifier,
      )));
      await tester.pumpAndSettle();

      final footerTag = find.byKey(const Key('sidebar_footer_version_tag'));
      expect(footerTag, findsOneWidget);
      expect(
          find.descendant(of: footerTag, matching: find.text(AppVersion.tag)),
          findsOneWidget);
    });

    testWidgets('UserProfileScreen displays version tag in security card',
        (WidgetTester tester) async {
      setUpViewport(tester);
      await authNotifier.loginAsPersona(DemoPersonaKey.student);

      await tester.pumpWidget(buildTestHost(const UserProfileScreen()));
      await tester.pumpAndSettle();

      final systemVersionTag =
          find.byKey(const Key('profile_system_version_tag'));
      await tester.ensureVisible(systemVersionTag);
      expect(systemVersionTag, findsOneWidget);
      expect(find.text('Version ${AppVersion.tag}'), findsOneWidget);
    });

    testWidgets('AppShellUserMenu displays app version label in menu',
        (WidgetTester tester) async {
      setUpViewport(tester);
      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);

      await tester
          .pumpWidget(buildTestHost(AppShellUserMenu(auth: authNotifier)));
      await tester.pumpAndSettle();

      // Open the popup menu
      await tester.tap(find.byType(AppShellUserMenu));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('user_menu_version_label')), findsOneWidget);
      expect(find.text(AppVersion.display), findsOneWidget);
    });
  });
}
