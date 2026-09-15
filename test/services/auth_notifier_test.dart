import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/state/auth_notifier.dart';

void main() {
  group('checkPermission Wildcard Evaluator', () {
    test('SUPERADMIN role bypasses any permission check', () {
      expect(checkPermission([], ['SUPERADMIN'], 'school:profile:write'), isTrue);
      expect(checkPermission([], ['superadmin'], 'iam:user:delete'), isTrue);
      expect(checkPermission([], ['ADMIN'], 'school:profile:write'), isFalse);
    });

    test('Star wildcard grants all permissions', () {
      expect(checkPermission(['*'], [], 'school:profile:write'), isTrue);
      expect(checkPermission(['*'], [], 'any:unknown:perm'), isTrue);
    });

    test('Context prefix wildcard matches child actions', () {
      expect(checkPermission(['school:*'], [], 'school:profile:write'), isTrue);
      expect(checkPermission(['school:*'], [], 'school:settings:manage'), isTrue);
      expect(checkPermission(['school:*'], [], 'academic:year:write'), isFalse);
    });

    test('Exact match works as expected', () {
      expect(checkPermission(['school:profile:read'], [], 'school:profile:read'), isTrue);
      expect(checkPermission(['school:profile:read'], [], 'school:profile:write'), isFalse);
    });
  });

  group('AuthNotifier Tests', () {
    test('Initial state loads default profile', () async {
      final auth = AuthNotifier();
      await auth.refreshProfile();
      expect(auth.tenantId, equals('tenant-lincoln-high-001'));
      expect(auth.user, isNotNull);
      expect(auth.isAuthenticated, isTrue);
    });

    test('1-Click persona switch to Teacher updates roles and permissions', () async {
      final auth = AuthNotifier();
      await auth.loginAsPersona(DemoPersonaKey.teacher);

      expect(auth.user?.email, equals('eleanor.vance@ilmiya.edu'));
      expect(auth.hasRole('TEACHER'), isTrue);
      expect(auth.hasPermission('academic:course:read'), isTrue);
    });

    test('1-Click persona switch to SuperAdmin grants all permissions', () async {
      final auth = AuthNotifier();
      await auth.loginAsPersona(DemoPersonaKey.superadmin);

      expect(auth.user?.email, equals('admin.utama@ilmiya.edu'));
      expect(auth.hasRole('SUPERADMIN'), isTrue);
      expect(auth.hasPermission('anything:under:the:sun'), isTrue);
    });

    test('Switch tenant updates active tenantId', () async {
      final auth = AuthNotifier();
      await auth.switchTenant('tenant-sma1-ilmiya-002');
      expect(auth.tenantId, equals('tenant-sma1-ilmiya-002'));

      // Reset
      await auth.switchTenant('tenant-lincoln-high-001');
      expect(auth.tenantId, equals('tenant-lincoln-high-001'));
    });

    test('Logout clears authenticated session', () {
      final auth = AuthNotifier();
      auth.logout();

      expect(auth.user, isNull);
      expect(auth.token, isNull);
      expect(auth.roles, isEmpty);
      expect(auth.permissions, isEmpty);
    });
  });
}
