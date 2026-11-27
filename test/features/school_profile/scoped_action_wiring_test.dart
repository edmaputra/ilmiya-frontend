import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/constants/app_permissions.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/school_profile/presentation/schools_campuses_screen.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';
import 'package:kite_ui/shadcn.dart';
import 'package:provider/provider.dart';

/// Viewer with only the listed codes; all other checks resolve to false.
class _ScopedAuth extends AuthNotifier {
  final Set<String> granted;

  _ScopedAuth(this.granted);

  @override
  bool get isSuperAdmin => false;

  @override
  bool hasPermission(String permission) => granted.contains(permission);

  @override
  bool hasAnyPermission(List<String> permissions) =>
      permissions.any(hasPermission);

  @override
  bool hasRole(String role) => false;
}

void main() {
  setUp(() {
    ApiClient().tenantId = 'tenant-lincoln-high-001';
    MockStorageService().reset();
  });

  testWidgets('read-only viewer sees no mutation actions on Schools & Campuses',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = _ScopedAuth({AppPermissions.schoolProfileRead});
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthNotifier>(
        create: (_) => auth,
        child: ShadTheme(
          data: AppTheme.shadLightTheme,
          child: const MaterialApp(
            home: Scaffold(body: SchoolsCampusesScreen()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Edit Profile'), findsNothing);
    expect(find.byTooltip('Operational Settings'), findsNothing);
    expect(find.byTooltip('Suspend Tenant'), findsNothing);
    expect(find.text('Register School Campus'), findsNothing);
    expect(find.text('Register Foundation / Tenant'), findsNothing);
  });
}
