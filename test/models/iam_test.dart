import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/iam.dart';

void main() {
  group('IAM Models Tests', () {
    test('UserResponse serialization and copyWith', () {
      final json = {
        'id': 'usr-1',
        'email': 'test@ilmiya.edu',
        'fullName': 'Test User',
        'status': 'ACTIVE',
        'isPlatformSuperAdmin': true,
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-02T00:00:00Z',
      };

      final user = UserResponse.fromJson(json);
      expect(user.id, 'usr-1');
      expect(user.email, 'test@ilmiya.edu');
      expect(user.fullName, 'Test User');
      expect(user.status, 'ACTIVE');
      expect(user.isPlatformSuperAdmin, isTrue);

      final userMap = user.toJson();
      expect(userMap['id'], 'usr-1');
      expect(userMap['isPlatformSuperAdmin'], isTrue);

      final copied =
          user.copyWith(fullName: 'Updated Name', status: 'INACTIVE');
      expect(copied.fullName, 'Updated Name');
      expect(copied.status, 'INACTIVE');
      expect(copied.id, 'usr-1');

      // Test fallback defaults
      final emptyUser = UserResponse.fromJson({});
      expect(emptyUser.id, isEmpty);
      expect(emptyUser.status, 'ACTIVE');
      expect(emptyUser.isPlatformSuperAdmin, isFalse);
    });

    test('CreateUserRequest toJson', () {
      final req = CreateUserRequest(
        email: 'new@ilmiya.edu',
        fullName: 'New User',
        password: 'secretPassword',
        isPlatformSuperAdmin: false,
      );
      final json = req.toJson();
      expect(json['email'], 'new@ilmiya.edu');
      expect(json['password'], 'secretPassword');
      expect(json['isPlatformSuperAdmin'], isFalse);

      final minimalReq = CreateUserRequest(
        email: 'min@ilmiya.edu',
        fullName: 'Min User',
      );
      expect(minimalReq.toJson().containsKey('password'), isFalse);
    });

    test('UserRoleAssignmentResponse serialization', () {
      final json = {
        'id': 'ura-1',
        'userId': 'usr-1',
        'roleId': 'role-1',
        'tenantId': 'tenant-1',
        'scopeNodeId': 'scope-root',
        'assignedAt': '2026-01-01T00:00:00Z',
      };
      final ura = UserRoleAssignmentResponse.fromJson(json);
      expect(ura.id, 'ura-1');
      expect(ura.scopeNodeId, 'scope-root');

      final serialized = ura.toJson();
      expect(serialized['scopeNodeId'], 'scope-root');

      final uraNoScope = UserRoleAssignmentResponse.fromJson({'id': 'ura-2'});
      expect(uraNoScope.scopeNodeId, isNull);
      expect(uraNoScope.toJson().containsKey('scopeNodeId'), isFalse);
    });

    test('RoleResponse and CreateRoleRequest serialization', () {
      final json = {
        'id': 'role-admin',
        'tenantId': 'tenant-main',
        'code': 'ADMIN',
        'name': 'Administrator',
        'description': 'Admin role description',
        'permissions': ['read', 'write'],
        'isSystemRole': true,
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-02T00:00:00Z',
      };
      final role = RoleResponse.fromJson(json);
      expect(role.id, 'role-admin');
      expect(role.permissions, containsAll(['read', 'write']));
      expect(role.isSystemRole, isTrue);

      final roleMap = role.toJson();
      expect(roleMap['description'], 'Admin role description');

      final createRoleReq = CreateRoleRequest(
        code: 'TEACHER',
        name: 'Teacher Role',
        description: 'For teachers',
        permissions: ['grades:write'],
      );
      final createMap = createRoleReq.toJson();
      expect(createMap['code'], 'TEACHER');
      expect(createMap['permissions'], ['grades:write']);

      final emptyRole = RoleResponse.fromJson({});
      expect(emptyRole.permissions, isEmpty);
      expect(emptyRole.isSystemRole, isFalse);
    });

    test('GroupResponse and CreateGroupRequest serialization', () {
      final json = {
        'id': 'grp-1',
        'tenantId': 'tenant-main',
        'code': 'FACULTY',
        'name': 'Faculty Group',
        'description': 'All faculty members',
        'externalIdpGroupName': 'idp-faculty',
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-02T00:00:00Z',
      };
      final group = GroupResponse.fromJson(json);
      expect(group.name, 'Faculty Group');
      expect(group.externalIdpGroupName, 'idp-faculty');

      final groupMap = group.toJson();
      expect(groupMap['externalIdpGroupName'], 'idp-faculty');

      final createReq = CreateGroupRequest(
        code: 'STUDENTS',
        name: 'Students Group',
        description: 'Enrolled students',
        externalIdpGroupName: 'idp-students',
      );
      final createMap = createReq.toJson();
      expect(createMap['code'], 'STUDENTS');
      expect(createMap['externalIdpGroupName'], 'idp-students');
    });

    test('ScopeTreeNode and CreateScopeRequest serialization', () {
      final json = {
        'id': 'node-1',
        'code': 'ROOT',
        'name': 'Root Campus',
        'path': '/root',
        'depth': 0,
        'parentId': null,
        'children': [
          {
            'id': 'node-2',
            'code': 'HIGH_SCHOOL',
            'name': 'High School',
            'path': '/root/high_school',
            'depth': 1,
            'parentId': 'node-1',
            'children': [],
          }
        ],
      };
      final tree = ScopeTreeNode.fromJson(json);
      expect(tree.code, 'ROOT');
      expect(tree.children.length, 1);
      expect(tree.children.first.code, 'HIGH_SCHOOL');

      final treeMap = tree.toJson();
      expect(treeMap['children'], isA<List>());

      final createScopeReq = CreateScopeRequest(
        code: 'MIDDLE_SCHOOL',
        name: 'Middle School',
        parentId: 'node-1',
      );
      final createScopeMap = createScopeReq.toJson();
      expect(createScopeMap['parentId'], 'node-1');
    });

    test('TokenResponse serialization', () {
      final json = {
        'accessToken': 'jwt-access-token',
        'refreshToken': 'jwt-refresh-token',
        'tokenType': 'Bearer',
        'expiresIn': 7200,
        'tenantId': 'tenant-test',
        'roles': ['STUDENT'],
        'permissions': ['view:grades'],
      };
      final token = TokenResponse.fromJson(json);
      expect(token.accessToken, 'jwt-access-token');
      expect(token.expiresIn, 7200);

      final tokenMap = token.toJson();
      expect(tokenMap['tokenType'], 'Bearer');

      final defaultToken = TokenResponse.fromJson({});
      expect(defaultToken.expiresIn, 3600);
      expect(defaultToken.tokenType, 'Bearer');
    });

    test('UserProfileResponse and copyWith', () {
      final json = {
        'id': 'prof-1',
        'email': 'prof@ilmiya.edu',
        'fullName': 'Professor Test',
        'tenantId': 'tenant-main',
        'roles': ['TEACHER'],
        'permissions': ['teach'],
        'scopes': ['/campus/a'],
      };
      final profile = UserProfileResponse.fromJson(json);
      expect(profile.fullName, 'Professor Test');

      final copy = profile.copyWith(fullName: 'New Professor');
      expect(copy.fullName, 'New Professor');
      expect(copy.roles, ['TEACHER']);

      final profileMap = profile.toJson();
      expect(profileMap['scopes'], contains('/campus/a'));
    });

    test('LoginRequest serialization', () {
      final req = LoginRequest(
        email: 'user@ilmiya.edu',
        password: 'password123',
        tenantId: 'tenant-123',
      );
      final map = req.toJson();
      expect(map['email'], 'user@ilmiya.edu');
      expect(map['tenantId'], 'tenant-123');
    });

    test('DemoPersonas map contains expected keys', () {
      expect(DEMO_PERSONAS.containsKey(DemoPersonaKey.superadmin), isTrue);
      expect(DEMO_PERSONAS.containsKey(DemoPersonaKey.principal), isTrue);
      expect(DEMO_PERSONAS.containsKey(DemoPersonaKey.teacher), isTrue);
      expect(DEMO_PERSONAS.containsKey(DemoPersonaKey.student), isTrue);
      expect(DEMO_PERSONAS.containsKey(DemoPersonaKey.parent), isTrue);

      final superadmin = DEMO_PERSONAS[DemoPersonaKey.superadmin]!;
      expect(superadmin.roleLabel, 'Platform SuperAdmin');
      expect(superadmin.email, 'admin.utama@ilmiya.edu');
    });
  });
}
