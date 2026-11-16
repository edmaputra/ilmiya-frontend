import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';

void main() {
  group('IamService Extended Unit Tests', () {
    late IamService service;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      final client = ApiClient();
      client.isMockMode = true;
      service = IamService(apiClient: client, mockStorage: mockStorage);
    });

    test('login with principal email assigns SCHOOL_ADMIN role', () async {
      final token = await service.login(LoginRequest(
        email: 'principal@ilmiya.edu',
        password: 'password',
      ));
      expect(token.roles, contains('SCHOOL_ADMIN'));
      expect(service.cachedProfile?.roles, contains('SCHOOL_ADMIN'));
      expect(service.cachedProfile?.fullName, contains('Marcus Chen'));
    });

    test('login with teacher email assigns TEACHER role', () async {
      final token = await service.login(LoginRequest(
        email: 'teacher.science@ilmiya.edu',
        password: 'password',
      ));
      expect(token.roles, contains('TEACHER'));
      expect(service.cachedProfile?.roles, contains('TEACHER'));
    });

    test('login with student email assigns STUDENT role', () async {
      final token = await service.login(LoginRequest(
        email: 'student.john@ilmiya.edu',
        password: 'password',
      ));
      expect(token.roles, contains('STUDENT'));
      expect(service.cachedProfile?.roles, contains('STUDENT'));
    });

    test('login with parent email assigns PARENT role', () async {
      final token = await service.login(LoginRequest(
        email: 'parent.mary@ilmiya.edu',
        password: 'password',
      ));
      expect(token.roles, contains('PARENT'));
      expect(service.cachedProfile?.roles, contains('PARENT'));
    });

    test('login with custom user assigns USER role', () async {
      final token = await service.login(LoginRequest(
        email: 'guest@other.edu',
        password: 'password',
        tenantId: 'tenant-lincoln-high-001',
      ));
      expect(token.roles, contains('USER'));
    });

    test('getMe returns cached profile and handles logout', () async {
      await service.login(LoginRequest(
        email: 'admin.utama@ilmiya.edu',
        password: 'password',
      ));
      final me = await service.getMe();
      expect(me.roles, contains('SUPERADMIN'));

      service.logout();
      expect(service.cachedProfile, isNull);
    });

    test('switchTenant updates tenant and token', () async {
      await service.login(LoginRequest(
        email: 'admin.utama@ilmiya.edu',
        password: 'password',
      ));
      final token = await service.switchTenant('tenant-pinecrest-002');
      expect(token.tenantId, 'tenant-pinecrest-002');
      expect(service.cachedProfile?.tenantId, 'tenant-pinecrest-002');
    });

    test('user lifecycle: create, update, changeStatus, delete', () async {
      final created = await service.createUser(CreateUserRequest(
        email: 'temp.user@ilmiya.edu',
        fullName: 'Temporary User',
        password: 'Password123!',
      ));
      expect(created.id, isNotEmpty);

      final updated =
          await service.updateUser(created.id, 'Updated Temporary User');
      expect(updated.fullName, 'Updated Temporary User');

      final changedStatus =
          await service.changeUserStatus(created.id, 'SUSPENDED');
      expect(changedStatus.status, 'SUSPENDED');

      await service.deleteUser(created.id);
      final users = await service.listUsers();
      expect(users.any((u) => u.id == created.id), isFalse);
    });

    test('role assignments and revocation', () async {
      final users = await service.listUsers();
      final targetUser = users.first;
      final roles = await service.listRoles();
      final targetRole = roles.first;

      final assigned = await service.assignRole(
        userId: targetUser.id,
        roleId: targetRole.id,
        tenantId: 'tenant-lincoln-high-001',
      );
      expect(assigned.roleId, targetRole.id);

      final userRoles = await service.getUserRoles(targetUser.id);
      expect(userRoles.any((r) => r.id == assigned.id), isTrue);

      await service.revokeRole(targetUser.id, assigned.id);
      final afterRevoke = await service.getUserRoles(targetUser.id);
      expect(afterRevoke.any((r) => r.id == assigned.id), isFalse);
    });

    test('createRole and createGroup and createScope', () async {
      final newRole = await service.createRole(CreateRoleRequest(
        tenantId: 'tenant-lincoln-high-001',
        code: 'COUNSELOR',
        name: 'School Counselor',
        description: 'Counseling staff',
        permissions: ['student:read', 'counseling:write'],
      ));
      expect(newRole.code, 'COUNSELOR');

      final roles = await service.listRoles();
      expect(roles.any((r) => r.code == 'COUNSELOR'), isTrue);

      final newGroup = await service.createGroup(CreateGroupRequest(
        tenantId: 'tenant-lincoln-high-001',
        code: 'COUNSELORS',
        name: 'Counselor Group',
        description: 'All counselors',
      ));
      expect(newGroup.code, 'COUNSELORS');

      final groups = await service.listGroups();
      expect(groups.any((g) => g.code == 'COUNSELORS'), isTrue);

      final newScope = await service.createScope(CreateScopeRequest(
        tenantId: 'tenant-lincoln-high-001',
        code: 'WEST_WING',
        name: 'West Wing Campus',
      ));
      expect(newScope.code, 'WEST_WING');

      final tree = await service.getScopeTree();
      expect(tree.any((n) => n.code == 'WEST_WING'), isTrue);
    });
  });
}
