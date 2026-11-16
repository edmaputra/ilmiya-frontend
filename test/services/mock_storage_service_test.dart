import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/academic_year.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/models/school.dart';
import 'package:ilmiya_app/core/services/mock_storage_service.dart';

void main() {
  group('MockStorageService Unit Tests', () {
    late MockStorageService storage;

    setUp(() {
      storage = MockStorageService();
      storage.reset();
    });

    test('School profile operations', () {
      final defaultProfile = storage.getSchoolProfile(DEFAULT_TENANT_ID);
      expect(defaultProfile.tenantId, DEFAULT_TENANT_ID);

      final otherProfile = storage.getSchoolProfile('other-tenant');
      expect(otherProfile.tenantId, 'other-tenant');

      final updated = storage.updateSchoolProfile(UpdateSchoolRequest(
        name: 'Updated School Name',
        address: 'New Address',
        contactEmail: 'new@school.edu',
        contactPhone: '+6281234567890',
        accreditationStatus: 'ACCREDITED_A',
      ));
      expect(updated.name, 'Updated School Name');
      expect(updated.address, 'New Address');

      final configured =
          storage.configureSchoolSettings(ConfigureSchoolSettingsRequest(
        workingDays: ['MONDAY', 'TUESDAY'],
        gradingPreference: 'NUMERIC_SCALE_100',
        termLayout: 'TRIMESTER',
      ));
      expect(configured.workingDays, ['MONDAY', 'TUESDAY']);
      expect(configured.termLayout, 'TRIMESTER');

      final registered = storage.registerSchool(RegisterSchoolRequest(
        tenantId: 'new-registered-tenant',
        name: 'Newly Registered School',
        institutionCode: 'NEW-SCH',
        address: 'Downtown',
        contactEmail: 'contact@new.edu',
        contactPhone: '+12345678',
      ));
      expect(registered.institutionCode, 'NEW-SCH');
    });

    test('Academic years and terms lifecycle', () {
      final years = storage.listAcademicYears(DEFAULT_TENANT_ID);
      expect(years, isNotEmpty);

      final activeYear = storage.getActiveAcademicYear(DEFAULT_TENANT_ID);
      expect(activeYear, isNotNull);
      expect(activeYear!.status, 'ACTIVE');

      final newYear = storage.createAcademicYear(
        DEFAULT_TENANT_ID,
        CreateAcademicYearRequest(
          name: 'Tahun Ajaran 2027/2028',
          startDate: '2027-07-15',
          endDate: '2028-06-20',
        ),
      );
      expect(newYear.name, 'Tahun Ajaran 2027/2028');
      expect(newYear.status, 'PLANNED');

      final activatedYear =
          storage.activateAcademicYear(DEFAULT_TENANT_ID, newYear.id);
      expect(activatedYear.status, 'ACTIVE');
      final previouslyActive = storage
          .listAcademicYears(DEFAULT_TENANT_ID)
          .firstWhere((ay) => ay.id == activeYear.id);
      expect(previouslyActive.status, 'ARCHIVED');

      final term = storage.addAcademicTerm(
        newYear.id,
        AddAcademicTermRequest(
          name: 'Semester 1',
          displayName: 'Ganjil 2027/2028',
          type: 'SEMESTER_1',
          startDate: '2027-07-15',
          endDate: '2027-12-20',
        ),
      );
      expect(term.terms.any((t) => t.name == 'Semester 1'), isTrue);

      final addedTermId =
          term.terms.firstWhere((t) => t.name == 'Semester 1').id;
      final activatedTerm =
          storage.activateAcademicTerm(newYear.id, addedTermId);
      expect(activatedTerm.terms.firstWhere((t) => t.id == addedTermId).status,
          'ACTIVE');
    });

    test('IAM User management and exceptions', () {
      final user = storage.getUserByEmail('admin.utama@ilmiya.edu');
      expect(user, isNotNull);
      expect(storage.getUserByEmail('nonexistent@ilmiya.edu'), isNull);

      final created = storage.createUser(CreateUserRequest(
        email: 'test.unique@ilmiya.edu',
        fullName: 'Test Unique',
        password: 'Password123!',
      ));
      expect(created.status, 'ACTIVE');

      final updated = storage.updateUser(created.id, 'Renamed User');
      expect(updated.fullName, 'Renamed User');

      expect(() => storage.updateUser('invalid-id', 'Name'), throwsException);

      final statusChanged = storage.changeUserStatus(created.id, 'LOCKED');
      expect(statusChanged.status, 'LOCKED');

      expect(() => storage.changeUserStatus('invalid-id', 'LOCKED'),
          throwsException);

      storage.deleteUser(created.id);
      expect(storage.getUserByEmail('test.unique@ilmiya.edu'), isNull);
    });

    test('Roles, Groups, Scopes management', () {
      final createdRole = storage.createRole(
        DEFAULT_TENANT_ID,
        CreateRoleRequest(
          tenantId: DEFAULT_TENANT_ID,
          code: 'LIBRARIAN',
          name: 'Librarian',
          permissions: ['books:read', 'books:issue'],
        ),
      );
      expect(createdRole.code, 'LIBRARIAN');
      expect(
          storage
              .listRoles(DEFAULT_TENANT_ID)
              .any((r) => r.id == createdRole.id),
          isTrue);

      final createdGroup = storage.createGroup(
        DEFAULT_TENANT_ID,
        CreateGroupRequest(
          tenantId: DEFAULT_TENANT_ID,
          code: 'DEBATE_CLUB',
          name: 'Debate Club',
        ),
      );
      expect(createdGroup.name, 'Debate Club');
      expect(
          storage
              .listGroups(DEFAULT_TENANT_ID)
              .any((g) => g.id == createdGroup.id),
          isTrue);

      final createdScope = storage.createScope(
        DEFAULT_TENANT_ID,
        CreateScopeRequest(
          tenantId: DEFAULT_TENANT_ID,
          code: 'LIBRARY_BUILDING',
          name: 'Library Building',
        ),
      );
      expect(createdScope.code, 'LIBRARY_BUILDING');

      // Test child scope creation to trigger _addChildToScopeNode
      final childScope = storage.createScope(
        DEFAULT_TENANT_ID,
        CreateScopeRequest(
          tenantId: DEFAULT_TENANT_ID,
          code: 'ROOM_201',
          name: 'Reading Room 201',
          parentId: createdScope.id,
        ),
      );
      expect(childScope.code, 'ROOM_201');

      final tree = storage.getScopeTree(DEFAULT_TENANT_ID);
      expect(tree.any((s) => s.id == createdScope.id), isTrue);

      // Group update, delete, member and role management
      final updatedGroup = storage.updateGroup(
        createdGroup.id,
        UpdateGroupRequest(name: 'Debate Club Elite', description: 'Honors'),
      );
      expect(updatedGroup.name, equals('Debate Club Elite'));
      expect(
          () => storage.updateGroup(
              'invalid-id', UpdateGroupRequest(name: 'Fail')),
          throwsException);

      final testUser = storage.createUser(CreateUserRequest(
        email: 'member@ilmiya.edu',
        fullName: 'Member User',
        password: 'Password123!',
      ));

      storage.addUserToGroup(testUser.id, createdGroup.id);
      final members = storage.getGroupMembers(createdGroup.id);
      expect(members.any((m) => m.id == testUser.id), isTrue);

      storage.removeUserFromGroup(testUser.id, createdGroup.id);
      final membersAfter = storage.getGroupMembers(createdGroup.id);
      expect(membersAfter.any((m) => m.id == testUser.id), isFalse);

      final groupRole = storage.assignGroupRole(
        groupId: createdGroup.id,
        roleId: createdRole.id,
        tenantId: DEFAULT_TENANT_ID,
        scopeNodeId: createdScope.id,
      );
      expect(groupRole.groupId, equals(createdGroup.id));

      final groupRoles = storage.getGroupRoles(createdGroup.id);
      expect(groupRoles.length, equals(1));

      storage.revokeGroupRole(groupRole.id);
      expect(storage.getGroupRoles(createdGroup.id), isEmpty);

      storage.deleteGroup(createdGroup.id);
      expect(
          storage
              .listGroups(DEFAULT_TENANT_ID)
              .any((g) => g.id == createdGroup.id),
          isFalse);
    });

    test('School listing, filtering, status update, and deletion', () {
      final allSchools = storage.listSchools();
      expect(allSchools, isNotEmpty);

      final activeSchools = storage.listSchools(status: 'ACTIVE');
      expect(activeSchools.every((s) => s.status == 'ACTIVE'), isTrue);

      final queriedSchools = storage.listSchools(query: 'Lincoln');
      expect(queriedSchools, isNotEmpty);

      final notFoundQuery = storage.listSchools(query: 'NonexistentXYZ123');
      expect(notFoundQuery, isEmpty);

      final registered = storage.registerSchool(RegisterSchoolRequest(
        tenantId: 'temp-tenant',
        name: 'Temporary School',
        institutionCode: 'TMP',
        address: 'Temp Street 1',
        contactEmail: 'temp@school.edu',
        contactPhone: '+62811111111',
      ));
      expect(registered.tenantId, equals('temp-tenant'));

      // Register again with same tenantId updates existing
      final reregistered = storage.registerSchool(RegisterSchoolRequest(
        tenantId: 'temp-tenant',
        name: 'Temporary School Updated',
        institutionCode: 'TMP-UPD',
        address: 'Temp Street 2',
        contactEmail: 'temp.updated@school.edu',
        contactPhone: '+62822222222',
      ));
      expect(reregistered.name, equals('Temporary School Updated'));

      final updatedStatus =
          storage.updateSchoolStatus('temp-tenant', 'SUSPENDED');
      expect(updatedStatus.status, equals('SUSPENDED'));

      expect(() => storage.updateSchoolStatus('invalid-school', 'SUSPENDED'),
          throwsException);

      final deleted = storage.deleteSchool('temp-tenant');
      expect(deleted, isTrue);

      final deleteAgain = storage.deleteSchool('temp-tenant');
      expect(deleteAgain, isFalse);
    });
  });
}
