import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:ilmiya_app/core/models/academic_year.dart';
import 'package:ilmiya_app/core/models/iam.dart';
import 'package:ilmiya_app/core/models/school.dart';
import 'package:ilmiya_app/core/services/academic_year_service.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/iam_service.dart';
import 'package:ilmiya_app/core/services/school_service.dart';

void main() {
  group('SchoolService Live Mode Tests', () {
    late ApiClient client;
    late SchoolService schoolService;

    setUp(() {
      client = ApiClient();
      client.isMockMode = false;
      client.baseUrl = 'https://api.ilmiya.edu';
      client.tenantId = '01940000-0000-7000-8000-000000000001';
      schoolService = SchoolService(apiClient: client);
    });

    test('listSchools queries endpoint with query and status parameters',
        () async {
      await http.runWithClient(() async {
        final schools = await schoolService.listSchools(
          query: 'Lincoln',
          status: 'ACTIVE',
        );
        expect(schools.length, equals(1));
        expect(schools.first.name, equals('Lincoln High School'));
      },
          () => http_testing.MockClient((request) async {
                expect(request.url.path, equals('/api/v1/schools'));
                expect(request.url.queryParameters['query'], equals('Lincoln'));
                expect(request.url.queryParameters['status'], equals('ACTIVE'));
                return http.Response(
                  jsonEncode([
                    {
                      'id': '01940000-0000-7000-8000-000000000001',
                      'tenantId': '01940000-0000-7000-8000-000000000001',
                      'name': 'Lincoln High School',
                      'institutionCode': 'LHS',
                      'status': 'ACTIVE',
                      'createdAt': '2026-01-01T00:00:00Z',
                      'updatedAt': '2026-01-01T00:00:00Z',
                    }
                  ]),
                  200,
                );
              }));
    });

    test('listSchools returns empty when response is not a list', () async {
      await http.runWithClient(() async {
        final schools = await schoolService.listSchools();
        expect(schools, isEmpty);
      },
          () => http_testing.MockClient((request) async {
                return http.Response(jsonEncode({'data': null}), 200);
              }));
    });

    test('getProfile with default and explicit tenantId', () async {
      await http.runWithClient(() async {
        final profileDefault = await schoolService.getProfile();
        expect(profileDefault.name, equals('Lincoln'));

        final profileExplicit =
            await schoolService.getProfile(tenantId: 'custom-tenant');
        expect(profileExplicit.tenantId, equals('custom-tenant'));
      },
          () => http_testing.MockClient((request) async {
                if (request.url.path == '/api/v1/schools/profile') {
                  return http.Response(
                    jsonEncode({
                      'id': '1',
                      'tenantId': '01940000-0000-7000-8000-000000000001',
                      'name': 'Lincoln',
                      'status': 'ACTIVE',
                      'institutionCode': 'LHS',
                      'createdAt': '2026-01-01T00:00:00Z',
                      'updatedAt': '2026-01-01T00:00:00Z',
                    }),
                    200,
                  );
                }
                if (request.url.path == '/api/v1/schools/custom-tenant') {
                  return http.Response(
                    jsonEncode({
                      'id': '2',
                      'tenantId': 'custom-tenant',
                      'name': 'Custom School',
                      'status': 'ACTIVE',
                      'institutionCode': 'CS',
                      'createdAt': '2026-01-01T00:00:00Z',
                      'updatedAt': '2026-01-01T00:00:00Z',
                    }),
                    200,
                  );
                }
                return http.Response('Not Found', 404);
              }));
    });

    test('updateProfile and configureSettings make PUT requests with JSON body',
        () async {
      await http.runWithClient(() async {
        final updated = await schoolService.updateProfile(
          UpdateSchoolRequest(
            name: 'New Lincoln Name',
            address: '123 Campus St',
            contactEmail: 'lincoln@school.edu',
            contactPhone: '+1-555-1234',
          ),
          tenantId: 'custom-tenant',
        );
        expect(updated.name, equals('New Lincoln Name'));

        final configured = await schoolService.configureSettings(
          ConfigureSchoolSettingsRequest(
            workingDays: ['MONDAY', 'TUESDAY'],
            gradingPreference: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
            termLayout: 'SEMESTER',
          ),
        );
        expect(configured.name, equals('Configured School'));
      },
          () => http_testing.MockClient((request) async {
                if (request.url.path == '/api/v1/schools/custom-tenant' &&
                    request.method == 'PUT') {
                  return http.Response(
                    jsonEncode({
                      'id': '1',
                      'tenantId': 'custom-tenant',
                      'name': 'New Lincoln Name',
                      'status': 'ACTIVE',
                      'institutionCode': 'LHS',
                      'createdAt': '2026-01-01T00:00:00Z',
                      'updatedAt': '2026-01-01T00:00:00Z',
                    }),
                    200,
                  );
                }
                if (request.url.path == '/api/v1/schools/settings' &&
                    request.method == 'PUT') {
                  return http.Response(
                    jsonEncode({
                      'id': '1',
                      'tenantId': '01940000-0000-7000-8000-000000000001',
                      'name': 'Configured School',
                      'status': 'ACTIVE',
                      'institutionCode': 'LHS',
                      'createdAt': '2026-01-01T00:00:00Z',
                      'updatedAt': '2026-01-01T00:00:00Z',
                    }),
                    200,
                  );
                }
                return http.Response('Not Found', 404);
              }));
    });

    test('registerSchool, updateSchoolStatus, and deleteSchool', () async {
      await http.runWithClient(() async {
        final reg = await schoolService.registerSchool(RegisterSchoolRequest(
          tenantId: 'brand-new-school',
          name: 'Brand New',
          institutionCode: 'BNS',
          address: '456 College Way',
          contactEmail: 'contact@bns.edu',
          contactPhone: '+1-555-5678',
        ));
        expect(reg.tenantId, equals('brand-new-school'));

        final patched = await schoolService.updateSchoolStatus(
            'brand-new-school', 'SUSPENDED');
        expect(patched.status, equals('SUSPENDED'));

        final deleted = await schoolService.deleteSchool('brand-new-school');
        expect(deleted, isTrue);
      },
          () => http_testing.MockClient((request) async {
                if (request.url.path == '/api/v1/schools/register') {
                  return http.Response(
                    jsonEncode({
                      'id': '3',
                      'tenantId': 'brand-new-school',
                      'name': 'Brand New',
                      'status': 'ACTIVE',
                      'institutionCode': 'BNS',
                      'createdAt': '2026-01-01T00:00:00Z',
                      'updatedAt': '2026-01-01T00:00:00Z',
                    }),
                    201,
                  );
                }
                if (request.url.path ==
                        '/api/v1/schools/brand-new-school/status' &&
                    request.method == 'PATCH') {
                  return http.Response(
                    jsonEncode({
                      'id': '3',
                      'tenantId': 'brand-new-school',
                      'name': 'Brand New',
                      'status': 'SUSPENDED',
                      'institutionCode': 'BNS',
                      'createdAt': '2026-01-01T00:00:00Z',
                      'updatedAt': '2026-01-01T00:00:00Z',
                    }),
                    200,
                  );
                }
                if (request.url.path == '/api/v1/schools/brand-new-school' &&
                    request.method == 'DELETE') {
                  return http.Response('', 204);
                }
                return http.Response('Not Found', 404);
              }));
    });
  });

  group('AcademicYearService Live Mode Tests', () {
    late ApiClient client;
    late AcademicYearService academicYearService;

    setUp(() {
      client = ApiClient();
      client.isMockMode = false;
      client.baseUrl = 'https://api.ilmiya.edu';
      academicYearService = AcademicYearService(apiClient: client);
    });

    test('Academic year operations live calls', () async {
      await http.runWithClient(() async {
        final years = await academicYearService.listAcademicYears();
        expect(years.length, equals(1));
        expect(years.first.name, equals('2026/2027'));

        final activeYear = await academicYearService.getActiveAcademicYear();
        expect(activeYear, isNotNull);
        expect(activeYear!.status, equals('ACTIVE'));

        final created = await academicYearService.createAcademicYear(
          CreateAcademicYearRequest(
            name: '2027/2028',
            startDate: '2027-08-01',
            endDate: '2028-06-01',
          ),
        );
        expect(created.name, equals('2027/2028'));

        final activated = await academicYearService.activateYear('year-01');
        expect(activated.status, equals('ACTIVE'));

        final withTerm = await academicYearService.addTerm(
          'year-01',
          AddAcademicTermRequest(
            name: 'Fall Term',
            displayName: 'Fall 2026',
            type: 'SEMESTER_1',
            startDate: '2026-08-01',
            endDate: '2026-12-15',
          ),
        );
        expect(withTerm.terms.isNotEmpty, isTrue);

        final activatedTerm =
            await academicYearService.activateTerm('year-01', 'term-01');
        expect(activatedTerm.id, equals('year-01'));
      },
          () => http_testing.MockClient((request) async {
                final path = request.url.path;
                if (path == '/api/v1/academic-years' &&
                    request.method == 'GET') {
                  return http.Response(
                    jsonEncode([
                      {
                        'id': 'year-01',
                        'tenantId': 't-1',
                        'name': '2026/2027',
                        'startDate': '2026-08-01',
                        'endDate': '2027-06-01',
                        'status': 'ACTIVE',
                        'terms': [],
                      }
                    ]),
                    200,
                  );
                }
                if (path == '/api/v1/academic-years/active') {
                  return http.Response(
                    jsonEncode({
                      'id': 'year-01',
                      'tenantId': 't-1',
                      'name': '2026/2027',
                      'startDate': '2026-08-01',
                      'endDate': '2027-06-01',
                      'status': 'ACTIVE',
                      'terms': [],
                    }),
                    200,
                  );
                }
                if (path == '/api/v1/academic-years' &&
                    request.method == 'POST') {
                  return http.Response(
                    jsonEncode({
                      'id': 'year-02',
                      'tenantId': 't-1',
                      'name': '2027/2028',
                      'startDate': '2027-08-01',
                      'endDate': '2028-06-01',
                      'status': 'PLANNED',
                      'terms': [],
                    }),
                    201,
                  );
                }
                if (path == '/api/v1/academic-years/year-01/activate') {
                  return http.Response(
                    jsonEncode({
                      'id': 'year-01',
                      'tenantId': 't-1',
                      'name': '2026/2027',
                      'startDate': '2026-08-01',
                      'endDate': '2027-06-01',
                      'status': 'ACTIVE',
                      'terms': [],
                    }),
                    200,
                  );
                }
                if (path == '/api/v1/academic-years/year-01/terms') {
                  return http.Response(
                    jsonEncode({
                      'id': 'year-01',
                      'tenantId': 't-1',
                      'name': '2026/2027',
                      'startDate': '2026-08-01',
                      'endDate': '2027-06-01',
                      'status': 'ACTIVE',
                      'terms': [
                        {
                          'id': 'term-01',
                          'academicYearId': 'year-01',
                          'name': 'Fall Term',
                          'displayName': 'Fall 2026',
                          'type': 'SEMESTER_1',
                          'startDate': '2026-08-01',
                          'endDate': '2026-12-15',
                          'status': 'ACTIVE',
                        }
                      ],
                    }),
                    201,
                  );
                }
                if (path ==
                    '/api/v1/academic-years/year-01/terms/term-01/activate') {
                  return http.Response(
                    jsonEncode({
                      'id': 'year-01',
                      'tenantId': 't-1',
                      'name': '2026/2027',
                      'startDate': '2026-08-01',
                      'endDate': '2027-06-01',
                      'status': 'ACTIVE',
                      'terms': [],
                    }),
                    200,
                  );
                }
                return http.Response('Not Found', 404);
              }));
    });
  });

  group('IamService Live Mode Tests', () {
    late ApiClient client;
    late IamService iamService;

    setUp(() {
      client = ApiClient();
      client.isMockMode = false;
      client.baseUrl = 'https://api.ilmiya.edu';
      client.token = 'valid-token';
      iamService = IamService(apiClient: client);
    });

    test('login, getMe, switchTenant, logout in Live Mode', () async {
      await http.runWithClient(() async {
        final tokenResp = await iamService.login(LoginRequest(
          email: 'admin@ilmiya.edu',
          password: 'Password123',
          tenantId: 'custom-tenant',
        ));
        expect(tokenResp.accessToken, equals('access-123'));
        expect(client.token, equals('access-123'));
        expect(client.refreshToken, equals('refresh-123'));

        final me = await iamService.getMe();
        expect(me.email, equals('admin@ilmiya.edu'));

        final switched = await iamService.switchTenant('new-tenant');
        expect(switched.accessToken, equals('switched-token'));
        expect(client.tenantId, equals('new-tenant'));

        iamService.logout();
        expect(client.token, isNull);
        expect(client.refreshToken, isNull);
      },
          () => http_testing.MockClient((request) async {
                if (request.url.path == '/api/v1/auth/login') {
                  return http.Response(
                    jsonEncode({
                      'accessToken': 'access-123',
                      'refreshToken': 'refresh-123',
                      'tokenType': 'Bearer',
                      'expiresIn': 3600,
                      'tenantId': 'custom-tenant',
                      'roles': ['SUPERADMIN'],
                      'permissions': ['*'],
                      'user': {
                        'id': 'u-1',
                        'email': 'admin@ilmiya.edu',
                        'fullName': 'Dr. Sarah Jenkins',
                        'tenantId': 'custom-tenant',
                        'roles': ['SUPERADMIN'],
                        'permissions': ['*'],
                      }
                    }),
                    200,
                  );
                }
                if (request.url.path == '/api/v1/auth/me') {
                  return http.Response(
                    jsonEncode({
                      'id': 'u-1',
                      'email': 'admin@ilmiya.edu',
                      'fullName': 'Dr. Sarah Jenkins',
                      'tenantId': 'custom-tenant',
                      'roles': ['SUPERADMIN'],
                      'permissions': ['*'],
                    }),
                    200,
                  );
                }
                if (request.url.path == '/api/v1/auth/switch-tenant') {
                  return http.Response(
                    jsonEncode({
                      'accessToken': 'switched-token',
                      'refreshToken': 'switched-refresh',
                      'tokenType': 'Bearer',
                      'expiresIn': 3600,
                      'tenantId': 'new-tenant',
                      'roles': ['SUPERADMIN'],
                      'permissions': ['*'],
                    }),
                    200,
                  );
                }
                return http.Response('Not Found', 404);
              }));
    });

    test('getMe throws 401 when token is null', () async {
      client.token = null;
      expect(() => iamService.getMe(), throwsA(isA<ApiException>()));
    });

    test('listUsers, createUser, updateUser, changeStatus, deleteUser live',
        () async {
      await http.runWithClient(() async {
        final users = await iamService.listUsers();
        expect(users.length, equals(1));
        expect(users.first.email, equals('user1@ilmiya.edu'));

        final created = await iamService.createUser(CreateUserRequest(
          email: 'user2@ilmiya.edu',
          fullName: 'User Two',
          password: 'Password123!',
        ));
        expect(created.email, equals('user2@ilmiya.edu'));

        final updated = await iamService.updateUser('u-2', 'User Two Updated');
        expect(updated.fullName, equals('User Two Updated'));

        final statusChanged =
            await iamService.changeUserStatus('u-2', 'SUSPENDED');
        expect(statusChanged.status, equals('SUSPENDED'));

        await iamService.deleteUser('u-2');
      },
          () => http_testing.MockClient((request) async {
                if (request.url.path == '/api/v1/users' &&
                    request.method == 'GET') {
                  return http.Response(
                    jsonEncode([
                      {
                        'id': 'u-1',
                        'email': 'user1@ilmiya.edu',
                        'fullName': 'User One',
                        'status': 'ACTIVE',
                        'createdAt': '2026-01-01T00:00:00Z',
                      }
                    ]),
                    200,
                  );
                }
                if (request.url.path == '/api/v1/users' &&
                    request.method == 'POST') {
                  return http.Response(
                    jsonEncode({
                      'id': 'u-2',
                      'email': 'user2@ilmiya.edu',
                      'fullName': 'User Two',
                      'status': 'ACTIVE',
                      'createdAt': '2026-01-01T00:00:00Z',
                    }),
                    201,
                  );
                }
                if (request.url.path == '/api/v1/users/u-2' &&
                    request.method == 'PUT') {
                  return http.Response(
                    jsonEncode({
                      'id': 'u-2',
                      'email': 'user2@ilmiya.edu',
                      'fullName': 'User Two Updated',
                      'status': 'ACTIVE',
                      'createdAt': '2026-01-01T00:00:00Z',
                    }),
                    200,
                  );
                }
                if (request.url.path == '/api/v1/users/u-2/status' &&
                    request.method == 'PATCH') {
                  return http.Response(
                    jsonEncode({
                      'id': 'u-2',
                      'email': 'user2@ilmiya.edu',
                      'fullName': 'User Two Updated',
                      'status': 'SUSPENDED',
                      'createdAt': '2026-01-01T00:00:00Z',
                    }),
                    200,
                  );
                }
                if (request.url.path == '/api/v1/users/u-2' &&
                    request.method == 'DELETE') {
                  return http.Response('', 204);
                }
                return http.Response('Not Found', 404);
              }));
    });

    test('User roles assign, list, and revoke live calls', () async {
      await http.runWithClient(() async {
        final assigned = await iamService.assignRole(
          userId: 'u-1',
          roleId: 'role-01',
          tenantId: 't-1',
          scopeNodeId: 'scope-1',
        );
        expect(assigned.roleId, equals('role-01'));

        final roles = await iamService.getUserRoles('u-1');
        expect(roles.length, equals(1));

        await iamService.revokeRole('u-1', 'assign-01');
      },
          () => http_testing.MockClient((request) async {
                if (request.url.path == '/api/v1/users/u-1/roles' &&
                    request.method == 'POST') {
                  return http.Response(
                    jsonEncode({
                      'id': 'assign-01',
                      'userId': 'u-1',
                      'roleId': 'role-01',
                      'tenantId': 't-1',
                      'scopeNodeId': 'scope-1',
                      'assignedAt': '2026-01-01T00:00:00Z',
                    }),
                    201,
                  );
                }
                if (request.url.path == '/api/v1/users/u-1/roles' &&
                    request.method == 'GET') {
                  return http.Response(
                    jsonEncode([
                      {
                        'id': 'assign-01',
                        'userId': 'u-1',
                        'roleId': 'role-01',
                        'tenantId': 't-1',
                        'scopeNodeId': 'scope-1',
                        'assignedAt': '2026-01-01T00:00:00Z',
                      }
                    ]),
                    200,
                  );
                }
                if (request.url.path == '/api/v1/users/u-1/roles/assign-01' &&
                    request.method == 'DELETE') {
                  return http.Response('', 204);
                }
                return http.Response('Not Found', 404);
              }));
    });

    test('Roles, Groups, Group Members, Group Roles live calls', () async {
      await http.runWithClient(() async {
        final roles = await iamService.listRoles();
        expect(roles.first.code, equals('ADMIN'));

        final createdRole = await iamService.createRole(CreateRoleRequest(
          tenantId: 't-1',
          code: 'EDITOR',
          name: 'Editor',
          permissions: ['edit:content'],
        ));
        expect(createdRole.code, equals('EDITOR'));

        final groups = await iamService.listGroups();
        expect(groups.first.code, equals('DEAN'));

        final createdGroup = await iamService.createGroup(CreateGroupRequest(
          tenantId: 't-1',
          code: 'STAFF',
          name: 'Staff Group',
        ));
        expect(createdGroup.code, equals('STAFF'));

        final updatedGroup = await iamService.updateGroup(
          'g-1',
          UpdateGroupRequest(name: 'Updated Dean Group'),
        );
        expect(updatedGroup.name, equals('Updated Dean Group'));

        final members = await iamService.getGroupMembers('g-1');
        expect(members.length, equals(1));

        await iamService.addUserToGroup('u-1', 'g-1');
        await iamService.removeUserFromGroup('u-1', 'g-1');

        final groupRoles = await iamService.getGroupRoles('g-1');
        expect(groupRoles.length, equals(1));

        final assignedGR = await iamService.assignGroupRole(
          groupId: 'g-1',
          roleId: 'role-01',
          tenantId: 't-1',
          scopeNodeId: 'scope-1',
        );
        expect(assignedGR.roleId, equals('role-01'));

        await iamService.revokeGroupRole(
          groupId: 'g-1',
          assignmentId: 'gr-01',
        );

        await iamService.deleteGroup('g-1');
      },
          () => http_testing.MockClient((request) async {
                final p = request.url.path;
                if (p == '/api/v1/roles' && request.method == 'GET') {
                  return http.Response(
                    jsonEncode([
                      {
                        'id': 'r-1',
                        'tenantId': 't-1',
                        'code': 'ADMIN',
                        'name': 'Admin',
                        'permissions': ['*'],
                      }
                    ]),
                    200,
                  );
                }
                if (p == '/api/v1/roles' && request.method == 'POST') {
                  return http.Response(
                    jsonEncode({
                      'id': 'r-2',
                      'tenantId': 't-1',
                      'code': 'EDITOR',
                      'name': 'Editor',
                      'permissions': ['edit:content'],
                    }),
                    201,
                  );
                }
                if (p == '/api/v1/groups' && request.method == 'GET') {
                  return http.Response(
                    jsonEncode([
                      {
                        'id': 'g-1',
                        'tenantId': 't-1',
                        'code': 'DEAN',
                        'name': 'Dean Group',
                      }
                    ]),
                    200,
                  );
                }
                if (p == '/api/v1/groups' && request.method == 'POST') {
                  return http.Response(
                    jsonEncode({
                      'id': 'g-2',
                      'tenantId': 't-1',
                      'code': 'STAFF',
                      'name': 'Staff Group',
                    }),
                    201,
                  );
                }
                if (p == '/api/v1/groups/g-1' && request.method == 'PUT') {
                  return http.Response(
                    jsonEncode({
                      'id': 'g-1',
                      'tenantId': 't-1',
                      'code': 'DEAN',
                      'name': 'Updated Dean Group',
                    }),
                    200,
                  );
                }
                if (p == '/api/v1/groups/g-1' && request.method == 'DELETE') {
                  return http.Response('', 204);
                }
                if (p == '/api/v1/groups/g-1/members' &&
                    request.method == 'GET') {
                  return http.Response(
                    jsonEncode([
                      {
                        'id': 'u-1',
                        'email': 'u1@ilmiya.edu',
                        'fullName': 'User One',
                        'status': 'ACTIVE',
                        'createdAt': '2026-01-01T00:00:00Z',
                      }
                    ]),
                    200,
                  );
                }
                if (p == '/api/v1/users/u-1/groups/g-1' &&
                    request.method == 'POST') {
                  return http.Response('', 204);
                }
                if (p == '/api/v1/users/u-1/groups/g-1' &&
                    request.method == 'DELETE') {
                  return http.Response('', 204);
                }
                if (p == '/api/v1/groups/g-1/roles' &&
                    request.method == 'GET') {
                  return http.Response(
                    jsonEncode([
                      {
                        'id': 'gr-01',
                        'groupId': 'g-1',
                        'roleId': 'r-1',
                        'tenantId': 't-1',
                      }
                    ]),
                    200,
                  );
                }
                if (p == '/api/v1/groups/g-1/roles' &&
                    request.method == 'POST') {
                  return http.Response(
                    jsonEncode({
                      'id': 'gr-02',
                      'groupId': 'g-1',
                      'roleId': 'role-01',
                      'tenantId': 't-1',
                      'scopeNodeId': 'scope-1',
                    }),
                    201,
                  );
                }
                if (p == '/api/v1/groups/g-1/roles/gr-01' &&
                    request.method == 'DELETE') {
                  return http.Response('', 204);
                }
                return http.Response('Not Found', 404);
              }));
    });

    test('Scopes tree and createScope live calls', () async {
      await http.runWithClient(() async {
        final tree = await iamService.getScopeTree();
        expect(tree.first.code, equals('CAMPUS_MAIN'));

        final createdScope = await iamService.createScope(CreateScopeRequest(
          tenantId: 't-1',
          code: 'ANNEX',
          name: 'Campus Annex',
        ));
        expect(createdScope.code, equals('ANNEX'));
      },
          () => http_testing.MockClient((request) async {
                if (request.url.path == '/api/v1/scopes/tree') {
                  return http.Response(
                    jsonEncode([
                      {
                        'id': 's-1',
                        'tenantId': 't-1',
                        'code': 'CAMPUS_MAIN',
                        'name': 'Main Campus',
                        'path': '/CAMPUS_MAIN',
                        'level': 0,
                        'children': [],
                      }
                    ]),
                    200,
                  );
                }
                if (request.url.path == '/api/v1/scopes' &&
                    request.method == 'POST') {
                  return http.Response(
                    jsonEncode({
                      'id': 's-2',
                      'tenantId': 't-1',
                      'code': 'ANNEX',
                      'name': 'Campus Annex',
                      'path': '/ANNEX',
                      'level': 0,
                      'children': [],
                    }),
                    201,
                  );
                }
                return http.Response('Not Found', 404);
              }));
    });
  });
}
