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
import 'package:ilmiya_app/features/profile/presentation/user_profile_screen.dart';
import 'package:ilmiya_app/features/profile/widgets/profile_account_details_card.dart';
import 'package:ilmiya_app/features/profile/widgets/profile_admin_management_card.dart';
import 'package:ilmiya_app/features/profile/widgets/profile_header_card.dart';
import 'package:ilmiya_app/features/profile/widgets/profile_roles_scopes_card.dart';
import 'package:ilmiya_app/features/profile/widgets/profile_security_card.dart';
import 'package:ilmiya_app/state/app_state.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';

void main() {
  late ApiClient apiClient;
  late MockStorageService mockStorage;
  late IamService iamService;
  late AuthNotifier authNotifier;
  late AppState appState;

  setUp(() {
    apiClient = ApiClient()..isMockMode = true;
    mockStorage = MockStorageService();
    mockStorage.reset();
    SessionStorageService().resetForTesting();
    iamService = IamService(apiClient: apiClient, mockStorage: mockStorage);
    authNotifier = AuthNotifier(apiClient: apiClient, iamService: iamService);
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

  void setUpViewport(WidgetTester tester,
      {double width = 1280, double height = 900}) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('UserProfileScreen Tests', () {
    testWidgets('renders all profile cards when logged in as Superadmin',
        (WidgetTester tester) async {
      setUpViewport(tester);

      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);
      await tester.pumpWidget(buildTestHost(const UserProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('User Profile & Account Management'), findsOneWidget);
      expect(find.byType(ProfileHeaderCard), findsOneWidget);
      expect(find.byType(ProfileAccountDetailsCard), findsOneWidget);
      expect(find.byType(ProfileSecurityCard), findsOneWidget);
      expect(find.byType(ProfileRolesScopesCard), findsOneWidget);
      expect(find.byType(ProfileAdminManagementCard), findsOneWidget);
      expect(find.text('SUPERADMIN TOOLKIT'), findsOneWidget);
    });

    testWidgets(
        'user can self-manage their account name in account details card',
        (WidgetTester tester) async {
      setUpViewport(tester);

      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);
      await tester.pumpWidget(buildTestHost(const UserProfileScreen()));
      await tester.pumpAndSettle();

      final nameInputFinder = find.byKey(const Key('profile_fullname_input'));
      expect(nameInputFinder, findsOneWidget);

      await tester.enterText(nameInputFinder, 'Dr. Sarah Jenkins Updated');
      await tester.pumpAndSettle();

      final saveBtnFinder = find.byKey(const Key('profile_save_changes_btn'));
      await tester.tap(saveBtnFinder);
      await tester.pumpAndSettle();

      expect(
          find.text('Account details updated successfully.'), findsOneWidget);
      expect(authNotifier.user?.fullName, equals('Dr. Sarah Jenkins Updated'));
    });

    testWidgets(
        'user can self-manage password with validation in security card',
        (WidgetTester tester) async {
      setUpViewport(tester);

      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);
      await tester.pumpWidget(buildTestHost(const UserProfileScreen()));
      await tester.pumpAndSettle();

      final newPassFinder = find.byKey(const Key('profile_new_password_input'));
      final confirmPassFinder =
          find.byKey(const Key('profile_confirm_password_input'));
      final updateBtnFinder =
          find.byKey(const Key('profile_update_password_btn'));

      await tester.ensureVisible(updateBtnFinder);

      // Test validation: password mismatch
      await tester.enterText(newPassFinder, 'NewSecret123');
      await tester.enterText(confirmPassFinder, 'DifferentSecret');
      await tester.tap(updateBtnFinder);
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);

      // Test validation: password too short
      await tester.enterText(newPassFinder, '123');
      await tester.enterText(confirmPassFinder, '123');
      await tester.tap(updateBtnFinder);
      await tester.pumpAndSettle();
      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);

      // Valid update
      await tester.enterText(newPassFinder, 'NewSecret123!');
      await tester.enterText(confirmPassFinder, 'NewSecret123!');
      await tester.tap(updateBtnFinder);
      await tester.pumpAndSettle();
      expect(find.text('Password updated successfully.'), findsOneWidget);
    });

    testWidgets(
        'superadmin can manage other user accounts via ProfileAdminManagementCard',
        (WidgetTester tester) async {
      setUpViewport(tester);

      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);
      await tester.pumpWidget(buildTestHost(const UserProfileScreen()));
      await tester.pumpAndSettle();

      // Look for the user search in admin card
      final searchInput = find.byKey(const Key('admin_user_search_input'));
      await tester.ensureVisible(searchInput);
      expect(searchInput, findsOneWidget);

      // Switch to a target user
      final marcusChip = find.textContaining('Prof. Marcus Chen');
      if (marcusChip.evaluate().isNotEmpty) {
        await tester.tap(marcusChip.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Edit target user's full name
      final targetNameInput =
          find.byKey(const Key('admin_edit_user_name_input'));
      await tester.ensureVisible(targetNameInput);
      expect(targetNameInput, findsOneWidget);
      await tester.enterText(targetNameInput, 'Prof. Marcus Chen (Dean)');

      final saveNameBtn = find.byKey(const Key('admin_save_user_name_btn'));
      await tester.ensureVisible(saveNameBtn);
      await tester.tap(saveNameBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('updated to "Prof. Marcus Chen (Dean)"'),
          findsOneWidget);

      // Reset password for target user
      final resetPassInput =
          find.byKey(const Key('admin_reset_password_input'));
      await tester.ensureVisible(resetPassInput);
      await tester.enterText(resetPassInput, 'NewMarcusSecret99!');

      final resetBtn = find.byKey(const Key('admin_reset_password_btn'));
      await tester.ensureVisible(resetBtn);
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();
      expect(
          find.textContaining('Password for Prof. Marcus Chen (Dean) reset.'),
          findsOneWidget);

      // Change status to SUSPENDED
      final suspendBtn =
          find.byKey(const Key('admin_set_suspended_status_btn'));
      await tester.ensureVisible(suspendBtn);
      await tester.tap(suspendBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('Account status updated to SUSPENDED'),
          findsOneWidget);
    });

    testWidgets('non-superadmin user does not see admin management card',
        (WidgetTester tester) async {
      setUpViewport(tester);

      // Login as Teacher
      await authNotifier.loginAsPersona(DemoPersonaKey.teacher);
      await tester.pumpWidget(buildTestHost(const UserProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileHeaderCard), findsOneWidget);
      expect(find.byType(ProfileAccountDetailsCard), findsOneWidget);
      expect(find.byType(ProfileSecurityCard), findsOneWidget);
      expect(find.byType(ProfileRolesScopesCard), findsOneWidget);
      // Admin card should NOT be rendered
      expect(find.byType(ProfileAdminManagementCard), findsNothing);
      expect(find.text('SUPERADMIN TOOLKIT'), findsNothing);
    });

    testWidgets('renders properly on compact mobile viewport',
        (WidgetTester tester) async {
      setUpViewport(tester, width: 400, height: 800);

      await authNotifier.loginAsPersona(DemoPersonaKey.superadmin);
      await tester.pumpWidget(buildTestHost(const UserProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('User Profile & Account Management'), findsOneWidget);
      expect(find.byType(ProfileHeaderCard), findsOneWidget);
      expect(find.byType(ProfileAccountDetailsCard), findsOneWidget);
    });
  });
}
