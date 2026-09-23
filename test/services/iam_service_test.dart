import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';

void main() {
  group('IamService Mock Tests', () {
    test('listUsers returns initial seeded users', () async {
      final users = await iamService.listUsers();
      expect(users.length, greaterThanOrEqualTo(5));
      expect(users.any((u) => u.email == 'admin.utama@ilmiya.edu'), isTrue);
    });

    test('createUser adds new user to tenant', () async {
      final newUser = await iamService.createUser(CreateUserRequest(
        email: 'new.staff@ilmiya.edu',
        fullName: 'New Staff Member',
      ));

      expect(newUser.email, equals('new.staff@ilmiya.edu'));
      expect(newUser.fullName, equals('New Staff Member'));

      final users = await iamService.listUsers();
      expect(users.any((u) => u.id == newUser.id), isTrue);
    });

    test('listRoles returns roles with permissions and scopes', () async {
      final roles = await iamService.listRoles();
      expect(roles, isNotEmpty);
      final superadminRole = roles.firstWhere((r) => r.code == 'SUPERADMIN');
      expect(superadminRole.permissions, contains('*'));
    });

    test('listGroups returns configured user groups', () async {
      final groups = await iamService.listGroups();
      expect(groups.length, greaterThanOrEqualTo(2));
      expect(groups.any((g) => g.name.contains('Faculty')), isTrue);
    });

    test('getScopeTree returns hierarchical scope definitions', () async {
      final tree = await iamService.getScopeTree();
      expect(tree, isNotEmpty);
      expect(tree.any((node) => node.code.contains('CAMPUS_MAIN')), isTrue);
    });

    test(
        'TokenResponse correctly parses live backend response with nested user',
        () {
      final liveJson = {
        'accessToken': 'jwt.mock.access',
        'refreshToken': 'jwt.mock.refresh',
        'tokenType': 'Bearer',
        'expiresIn': 3600,
        'user': {
          'id': '01a0b50c-d444-7c66-ad6a-0b7e94ab20ca',
          'email': 'admin@springfield.local',
          'fullName': 'Springfield Admin',
          'tenantId': '01940000-0000-7000-8000-000000000001',
          'roles': ['SCHOOL_ADMIN'],
          'permissions': ['school:*', 'attendance:*'],
          'accessibleScopePaths': ['/SPRINGFIELD'],
        },
      };

      final tokenResponse = TokenResponse.fromJson(liveJson);
      expect(tokenResponse.accessToken, equals('jwt.mock.access'));
      expect(tokenResponse.refreshToken, equals('jwt.mock.refresh'));
      expect(tokenResponse.tenantId,
          equals('01940000-0000-7000-8000-000000000001'));
      expect(tokenResponse.roles, contains('SCHOOL_ADMIN'));
      expect(tokenResponse.permissions, contains('school:*'));
      expect(tokenResponse.user, isNotNull);
      expect(tokenResponse.user!.fullName, equals('Springfield Admin'));
      expect(tokenResponse.user!.email, equals('admin@springfield.local'));
      expect(tokenResponse.user!.scopes, contains('/SPRINGFIELD'));
    });
  });
}
