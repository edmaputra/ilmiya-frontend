import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/constants/app_permissions.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';

void main() {
  group('AppPermissions catalog', () {
    test('screen visibility sets use canonical permission codes', () {
      expect(AppPermissions.schoolProfileView, contains('school:profile:read'));
      expect(
        AppPermissions.schoolProfileView,
        contains('school:profile:write'),
      );
      expect(
        AppPermissions.schoolProfileView,
        contains('school:settings:manage'),
      );

      expect(AppPermissions.academicYearsView, contains('academic:year:read'));
      expect(AppPermissions.academicYearsView, contains('academic:year:write'));
      expect(
        AppPermissions.academicYearsView,
        isNot(contains('academic-year:read')),
      );

      expect(
        AppPermissions.schoolsCampusesView,
        contains('school:campus:read'),
      );
      expect(AppPermissions.schoolsCampusesView, contains('tenant:read'));

      expect(AppPermissions.iamView, contains('iam:user:read'));
      expect(AppPermissions.iamView, contains('tenant:password-policy:read'));
      expect(AppPermissions.iamView, contains('tenant:password-policy:write'));
    });

    test('IAM sub-tab visibility sets cover their domain only', () {
      expect(AppPermissions.iamUsersTabView, contains('iam:user:create'));
      expect(AppPermissions.iamUsersTabView, isNot(contains('iam:role:read')));
      expect(AppPermissions.iamRolesTabView, contains('iam:role:update'));
      expect(
        AppPermissions.iamGroupsTabView,
        contains('iam:group:assign-role'),
      );
      expect(AppPermissions.iamScopesTabView, contains('iam:scope:move'));
      expect(
        AppPermissions.iamPasswordPolicyTabView,
        contains('tenant:password-policy:write'),
      );
      expect(
        AppPermissions.iamPasswordPolicyTabView,
        isNot(contains('iam:user:read')),
      );
    });
  });

  group('AuthNotifier.hasAnyPermission', () {
    test('empty list grants no access', () async {
      final auth = AuthNotifier();
      await auth.loginAsPersona(DemoPersonaKey.superadmin);
      expect(auth.hasAnyPermission(const []), isFalse);
    });

    test('a single matching permission grants access', () async {
      final auth = AuthNotifier();
      await auth.loginAsPersona(DemoPersonaKey.teacher);
      expect(auth.hasAnyPermission(const ['academic:course:read']), isTrue);
      expect(
        auth.hasAnyPermission(AppPermissions.coursesAndGradesView),
        isTrue,
      );
      expect(auth.hasAnyPermission(AppPermissions.iamView), isFalse);
    });

    test('wildcard permissions satisfy a domain visibility set', () async {
      final auth = AuthNotifier();
      await auth.loginAsPersona(DemoPersonaKey.tenantAdmin);
      expect(auth.hasAnyPermission(AppPermissions.iamView), isTrue);
      expect(auth.hasAnyPermission(AppPermissions.schoolProfileView), isTrue);
      expect(
        auth.hasAnyPermission(AppPermissions.iamPasswordPolicyTabView),
        isFalse,
      );
    });

    test('SUPERADMIN satisfies every visibility set', () async {
      final auth = AuthNotifier();
      await auth.loginAsPersona(DemoPersonaKey.superadmin);
      expect(auth.hasAnyPermission(AppPermissions.schoolProfileView), isTrue);
      expect(auth.hasAnyPermission(AppPermissions.schoolsCampusesView), isTrue);
      expect(auth.hasAnyPermission(AppPermissions.academicYearsView), isTrue);
      expect(auth.hasAnyPermission(AppPermissions.iamView), isTrue);
      expect(
        auth.hasAnyPermission(AppPermissions.iamPasswordPolicyTabView),
        isTrue,
      );
    });

    test('logged out user has no permissions', () {
      final auth = AuthNotifier();
      auth.logout();
      expect(auth.hasAnyPermission(AppPermissions.iamView), isFalse);
      expect(auth.hasAnyPermission(AppPermissions.academicYearsView), isFalse);
    });
  });
}
