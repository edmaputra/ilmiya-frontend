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
  });
}
