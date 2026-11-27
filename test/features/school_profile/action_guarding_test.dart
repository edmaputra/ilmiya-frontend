import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/school.dart';
import 'package:ilmiya_app/core/models/tenant.dart';
import 'package:ilmiya_app/core/theme/app_theme.dart';
import 'package:ilmiya_app/features/school_profile/widgets/foundation_card.dart';
import 'package:ilmiya_app/features/school_profile/widgets/tenant_directory_tab.dart';
import 'package:ilmiya_app/features/school_profile/widgets/tenant_operational_policies_card.dart';
import 'package:ilmiya_app/features/school_profile/widgets/tenant_school_card.dart';
import 'package:kite_ui/shadcn.dart';

final _school = SchoolResponse(
  id: 'sch-action-guard',
  tenantId: 'tenant-action-guard',
  name: 'Action Guard High School',
  institutionCode: 'AGHS',
  status: 'ACTIVE',
  address: '1 Guard Street',
  contactEmail: 'guard@ilmiya.edu',
  contactPhone: '08123456789',
  workingDays: const ['MONDAY'],
  gradingPreference: 'PERCENTAGE',
  termLayout: 'SEMESTER',
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
);

final _tenant = TenantResponse(
  id: 'tenant-action-guard',
  name: 'Action Guard Foundation',
  address: '1 Guard Street',
  contactEmail: 'guard@ilmiya.edu',
  contactPhone: '08123456789',
  status: 'ACTIVE',
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
);

Widget _host(Widget child) {
  return ShadTheme(
    data: AppTheme.shadLightTheme,
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 1000, height: 800, child: child),
      ),
    ),
  );
}

void main() {
  group('TenantSchoolCard action guarding', () {
    testWidgets('hides every action when no permissions are granted',
        (tester) async {
      await tester.pumpWidget(_host(TenantSchoolCard(
        school: _school,
        isCurrentTenant: false,
        onEditProfile: (_) {},
        onSettings: (_) {},
        onToggleStatus: (_) {},
        onAddCampus: (_) {},
        canAddCampus: false,
        canEditProfile: false,
        canManageSettings: false,
        canToggleStatus: false,
      )));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Add School Campus'), findsNothing);
      expect(find.byTooltip('Edit Profile'), findsNothing);
      expect(find.byTooltip('Operational Settings'), findsNothing);
      expect(find.byTooltip('Suspend Tenant'), findsNothing);
    });

    testWidgets('shows only the explicitly granted action', (tester) async {
      await tester.pumpWidget(_host(TenantSchoolCard(
        school: _school,
        isCurrentTenant: false,
        onEditProfile: (_) {},
        onSettings: (_) {},
        onToggleStatus: (_) {},
        onAddCampus: (_) {},
        canAddCampus: false,
        canEditProfile: true,
        canManageSettings: false,
        canToggleStatus: false,
      )));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Edit Profile'), findsOneWidget);
      expect(find.byTooltip('Add School Campus'), findsNothing);
      expect(find.byTooltip('Operational Settings'), findsNothing);
      expect(find.byTooltip('Suspend Tenant'), findsNothing);
    });
  });

  group('FoundationCard action guarding', () {
    testWidgets('hides all governance actions when no permissions are granted',
        (tester) async {
      await tester.pumpWidget(_host(FoundationCard(
        tenant: _tenant,
        affiliatedSchools: const [],
        isCurrentTenant: false,
        onSwitchTenant: (_) {},
        onEdit: (_) {},
        onToggleStatus: (_) {},
        onAddCampus: (_) {},
        canEdit: false,
        canToggleStatus: false,
        canSwitchTenant: false,
        canAddCampus: false,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Add School Campus'), findsNothing);
      expect(find.text('Edit Foundation'), findsNothing);
      expect(find.text('Suspend'), findsNothing);
      expect(find.text('Switch Session'), findsNothing);
    });
  });

  group('TenantOperationalPoliciesCard action guarding', () {
    testWidgets('hides Configure without school settings permission',
        (tester) async {
      await tester.pumpWidget(_host(TenantOperationalPoliciesCard(
        school: _school,
        onSettings: (_) {},
        canManageSettings: false,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Configure'), findsNothing);
    });
  });

  group('TenantDirectoryTab registration guarding', () {
    testWidgets('hides Register action without create permissions',
        (tester) async {
      await tester.pumpWidget(_host(TenantDirectoryTab(
        allSchools: const [],
        filteredSchools: const [],
        searchQuery: '',
        selectedStatusFilter: 'ALL',
        currentTenantId: '',
        onSearchChanged: (_) {},
        onStatusFilterChanged: (_) {},
        onRegisterTenant: () {},
        onSwitchTenant: (_) {},
        onEditProfile: (_) {},
        onSettings: (_) {},
        onToggleStatus: (_) {},
        canRegisterCampus: false,
        canRegisterFoundation: false,
        canEditProfile: false,
        canManageSettings: false,
        canToggleStatus: false,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Register School Campus'), findsNothing);
      expect(find.text('Register Foundation / Tenant'), findsNothing);
    });
  });
}
