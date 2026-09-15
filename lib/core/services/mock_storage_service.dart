import '../models/school.dart';
import '../models/academic_year.dart';
import '../models/iam.dart';

const String DEFAULT_TENANT_ID = 'tenant-lincoln-high-001';

class MockStorageService {
  static final MockStorageService _instance = MockStorageService._internal();
  factory MockStorageService() => _instance;

  late SchoolResponse _school;
  late List<AcademicYearResponse> _academicYears;
  late List<UserResponse> _users;
  late List<RoleResponse> _roles;
  late List<GroupResponse> _groups;
  late List<ScopeTreeNode> _scopes;
  late List<UserRoleAssignmentResponse> _userRoleAssignments;

  MockStorageService._internal() {
    reset();
  }

  void reset() {
    _school = SchoolResponse(
      id: 'sch-001',
      tenantId: DEFAULT_TENANT_ID,
      name: 'SMA Negeri 1 Ilmiya (Lincoln High Campus)',
      institutionCode: 'SMAN1-ILM',
      address: 'Jl. Pendidikan No. 42, Kebayoran Baru, Jakarta Selatan',
      contactEmail: 'admin@ilmiya-school.edu',
      contactPhone: '+62 21 7890 1234',
      logoUrl: 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=300&auto=format&fit=crop&q=80',
      status: 'ACTIVE',
      governmentRegistrationNumber: 'NPSN-20109988',
      registrationType: 'PUBLIC_PROVINCIAL',
      accreditationStatus: 'ACCREDITED_A',
      accreditationBody: 'BAN-S/M Indonesia',
      accreditationValidUntil: '2028-12-31',
      workingDays: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
      gradingPreference: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
      termLayout: 'SEMESTER',
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
    );

    _academicYears = [
      AcademicYearResponse(
        id: 'ay-2026-2027',
        tenantId: DEFAULT_TENANT_ID,
        name: 'Tahun Ajaran 2026/2027',
        startDate: '2026-07-15',
        endDate: '2027-06-25',
        status: 'ACTIVE',
        terms: [
          AcademicTermResponse(
            id: 'term-sem-1-2026',
            academicYearId: 'ay-2026-2027',
            name: 'Semester 1 (Ganjil)',
            displayName: 'Ganjil 2026/2027',
            type: 'SEMESTER_1',
            startDate: '2026-07-15',
            endDate: '2026-12-20',
            status: 'ACTIVE',
            createdAt: '2026-01-01T00:00:00Z',
            updatedAt: '2026-01-01T00:00:00Z',
          ),
          AcademicTermResponse(
            id: 'term-sem-2-2027',
            academicYearId: 'ay-2026-2027',
            name: 'Semester 2 (Genap)',
            displayName: 'Genap 2026/2027',
            type: 'SEMESTER_2',
            startDate: '2027-01-08',
            endDate: '2027-06-25',
            status: 'PLANNED',
            createdAt: '2026-01-01T00:00:00Z',
            updatedAt: '2026-01-01T00:00:00Z',
          ),
        ],
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      AcademicYearResponse(
        id: 'ay-2025-2026',
        tenantId: DEFAULT_TENANT_ID,
        name: 'Tahun Ajaran 2025/2026',
        startDate: '2025-07-15',
        endDate: '2026-06-20',
        status: 'ARCHIVED',
        terms: [
          AcademicTermResponse(
            id: 'term-sem-1-2025',
            academicYearId: 'ay-2025-2026',
            name: 'Semester 1 (Ganjil)',
            displayName: 'Ganjil 2025/2026',
            type: 'SEMESTER_1',
            startDate: '2025-07-15',
            endDate: '2025-12-20',
            status: 'CONCLUDED',
            createdAt: '2025-01-01T00:00:00Z',
            updatedAt: '2025-01-01T00:00:00Z',
          ),
        ],
        createdAt: '2025-01-01T00:00:00Z',
        updatedAt: '2025-01-01T00:00:00Z',
      ),
    ];

    _users = [
      UserResponse(
        id: 'u-11111111-1111-1111-1111-111111111111',
        email: 'admin.utama@ilmiya.edu',
        fullName: 'Dr. Sarah Jenkins (Head Administrator)',
        status: 'ACTIVE',
        isPlatformSuperAdmin: true,
        createdAt: '2026-01-01T08:00:00Z',
        updatedAt: '2026-01-01T08:00:00Z',
      ),
      UserResponse(
        id: 'u-22222222-2222-2222-2222-222222222222',
        email: 'principal@ilmiya.edu',
        fullName: 'Prof. Marcus Chen (School Principal)',
        status: 'ACTIVE',
        isPlatformSuperAdmin: false,
        createdAt: '2026-01-05T09:00:00Z',
        updatedAt: '2026-01-05T09:00:00Z',
      ),
      UserResponse(
        id: 'u-33333333-3333-3333-3333-333333333333',
        email: 'eleanor.vance@ilmiya.edu',
        fullName: 'Dr. Eleanor Vance (Computer Science Faculty)',
        status: 'ACTIVE',
        isPlatformSuperAdmin: false,
        createdAt: '2026-02-10T10:00:00Z',
        updatedAt: '2026-02-10T10:00:00Z',
      ),
      UserResponse(
        id: 'u-44444444-4444-4444-4444-444444444444',
        email: 'alex.rivera@student.ilmiya.edu',
        fullName: 'Alex Rivera (Class 10-A)',
        status: 'ACTIVE',
        isPlatformSuperAdmin: false,
        createdAt: '2026-07-10T11:00:00Z',
        updatedAt: '2026-07-10T11:00:00Z',
      ),
      UserResponse(
        id: 'u-55555555-5555-5555-5555-555555555555',
        email: 'elena.rivera@parent.ilmiya.edu',
        fullName: 'Elena Rivera (Parent / Guardian)',
        status: 'ACTIVE',
        isPlatformSuperAdmin: false,
        createdAt: '2026-07-10T11:30:00Z',
        updatedAt: '2026-07-10T11:30:00Z',
      ),
    ];

    _roles = [
      RoleResponse(
        id: 'role-superadmin',
        tenantId: DEFAULT_TENANT_ID,
        code: 'SUPERADMIN',
        name: 'Platform Super Administrator',
        description: 'Full institutional and multi-tenant rights across all bounded contexts.',
        permissions: ['*'],
        isSystemRole: true,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      RoleResponse(
        id: 'role-school-admin',
        tenantId: DEFAULT_TENANT_ID,
        code: 'SCHOOL_ADMIN',
        name: 'School Administrator',
        description: 'Institutional settings, user onboarding, and academic year rollover.',
        permissions: [
          'school:profile:read',
          'school:profile:write',
          'school:settings:manage',
          'academic:year:read',
          'academic:year:write',
          'academic:curriculum:read',
          'academic:curriculum:manage',
          'iam:user:create',
          'iam:user:read',
          'iam:user:update',
          'iam:user:assign-role',
          'iam:group:read',
        ],
        isSystemRole: true,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      RoleResponse(
        id: 'role-teacher',
        tenantId: DEFAULT_TENANT_ID,
        code: 'TEACHER',
        name: 'Educator & Subject Instructor',
        description: 'Attendance entry, continuous grading, curriculum delivery, and report cards.',
        permissions: [
          'school:profile:read',
          'academic:year:read',
          'academic:course:read',
          'academic:course:write',
          'student:profile:read',
          'attendance:record:read',
          'attendance:record:create',
          'attendance:record:update',
          'exam:grade:create',
          'exam:grade:update',
          'exam:report-card:publish',
        ],
        isSystemRole: true,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      RoleResponse(
        id: 'role-student',
        tenantId: DEFAULT_TENANT_ID,
        code: 'STUDENT',
        name: 'Student Learner',
        description: 'Course schedules, grade reviews, assignment submissions, and attendance logs.',
        permissions: [
          'school:profile:read',
          'academic:year:read',
          'academic:course:read',
          'student:profile:read',
          'attendance:record:read',
          'exam:grade:create',
        ],
        isSystemRole: true,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
    ];

    _groups = [
      GroupResponse(
        id: 'grp-stem-faculty',
        tenantId: DEFAULT_TENANT_ID,
        code: 'GRP_STEM_FACULTY',
        name: 'STEM Faculty Department',
        description: 'Science, Technology, Engineering and Mathematics Instructors',
        externalIdpGroupName: 'azure-ad-group-stem-teachers',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      GroupResponse(
        id: 'grp-grade-10',
        tenantId: DEFAULT_TENANT_ID,
        code: 'GRP_GRADE_10_STUDENTS',
        name: 'Class 10 Student Cohort',
        description: 'Enrolled Tenth Grade Secondary Learners',
        externalIdpGroupName: 'azure-ad-group-grade10',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
    ];

    _scopes = [
      ScopeTreeNode(
        id: 'scope-root',
        code: 'CAMPUS_MAIN',
        name: 'Lincoln High Main Campus',
        path: '/CAMPUS_MAIN',
        depth: 0,
        parentId: null,
        children: [
          ScopeTreeNode(
            id: 'scope-senior-high',
            code: 'DIV_SENIOR_HIGH',
            name: 'Senior High School (SMA)',
            path: '/CAMPUS_MAIN/DIV_SENIOR_HIGH',
            depth: 1,
            parentId: 'scope-root',
            children: [
              ScopeTreeNode(
                id: 'scope-dept-cs',
                code: 'DEPT_CS',
                name: 'Computer Science Department',
                path: '/CAMPUS_MAIN/DIV_SENIOR_HIGH/DEPT_CS',
                depth: 2,
                parentId: 'scope-senior-high',
                children: [],
              ),
              ScopeTreeNode(
                id: 'scope-class-10a',
                code: 'CLASS_10A',
                name: 'Class 10-A (Science Track)',
                path: '/CAMPUS_MAIN/DIV_SENIOR_HIGH/CLASS_10A',
                depth: 2,
                parentId: 'scope-senior-high',
                children: [],
              ),
            ],
          ),
          ScopeTreeNode(
            id: 'scope-junior-high',
            code: 'DIV_JUNIOR_HIGH',
            name: 'Junior High School (SMP)',
            path: '/CAMPUS_MAIN/DIV_JUNIOR_HIGH',
            depth: 1,
            parentId: 'scope-root',
            children: [],
          ),
        ],
      ),
    ];

    _userRoleAssignments = [
      UserRoleAssignmentResponse(
        id: 'ura-1',
        userId: 'u-11111111-1111-1111-1111-111111111111',
        roleId: 'role-superadmin',
        tenantId: DEFAULT_TENANT_ID,
        scopeNodeId: 'scope-root',
        assignedAt: '2026-01-01T08:00:00Z',
      ),
      UserRoleAssignmentResponse(
        id: 'ura-2',
        userId: 'u-22222222-2222-2222-2222-222222222222',
        roleId: 'role-school-admin',
        tenantId: DEFAULT_TENANT_ID,
        scopeNodeId: 'scope-root',
        assignedAt: '2026-01-05T09:00:00Z',
      ),
      UserRoleAssignmentResponse(
        id: 'ura-3',
        userId: 'u-33333333-3333-3333-3333-333333333333',
        roleId: 'role-teacher',
        tenantId: DEFAULT_TENANT_ID,
        scopeNodeId: 'scope-dept-cs',
        assignedAt: '2026-02-10T10:00:00Z',
      ),
      UserRoleAssignmentResponse(
        id: 'ura-4',
        userId: 'u-44444444-4444-4444-4444-444444444444',
        roleId: 'role-student',
        tenantId: DEFAULT_TENANT_ID,
        scopeNodeId: 'scope-class-10a',
        assignedAt: '2026-07-10T11:00:00Z',
      ),
    ];
  }

  // --- School Profile ---
  SchoolResponse getSchoolProfile(String tenantId) {
    if (_school.tenantId == tenantId) return _school;
    return SchoolResponse(
      id: 'sch-$tenantId',
      tenantId: tenantId,
      name: 'Branch Campus ($tenantId)',
      institutionCode: 'BRANCH-$tenantId',
      address: 'Main Avenue, District Branch',
      contactEmail: 'branch@ilmiya-school.edu',
      contactPhone: '+62 21 5555 0100',
      status: 'ACTIVE',
      workingDays: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
      gradingPreference: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
      termLayout: 'SEMESTER',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  SchoolResponse updateSchoolProfile(UpdateSchoolRequest req) {
    _school = _school.copyWith(
      name: req.name,
      address: req.address,
      contactEmail: req.contactEmail,
      contactPhone: req.contactPhone,
      logoUrl: req.logoUrl,
      governmentRegistrationNumber: req.governmentRegistrationNumber,
      registrationType: req.registrationType,
      accreditationStatus: req.accreditationStatus,
      accreditationBody: req.accreditationBody,
      accreditationValidUntil: req.accreditationValidUntil,
      updatedAt: DateTime.now().toIso8601String(),
    );
    return _school;
  }

  SchoolResponse configureSchoolSettings(ConfigureSchoolSettingsRequest req) {
    _school = _school.copyWith(
      workingDays: req.workingDays,
      gradingPreference: req.gradingPreference,
      termLayout: req.termLayout,
      updatedAt: DateTime.now().toIso8601String(),
    );
    return _school;
  }

  SchoolResponse registerSchool(RegisterSchoolRequest req) {
    _school = SchoolResponse(
      id: 'sch-${DateTime.now().millisecondsSinceEpoch}',
      tenantId: req.tenantId,
      name: req.name,
      institutionCode: req.institutionCode,
      address: req.address,
      contactEmail: req.contactEmail,
      contactPhone: req.contactPhone,
      status: 'ACTIVE',
      workingDays: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
      gradingPreference: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
      termLayout: 'SEMESTER',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    return _school;
  }

  // --- Academic Years ---
  List<AcademicYearResponse> listAcademicYears(String tenantId) {
    return _academicYears.where((ay) => ay.tenantId == tenantId).toList();
  }

  AcademicYearResponse? getActiveAcademicYear(String tenantId) {
    try {
      return _academicYears.firstWhere(
        (ay) => ay.tenantId == tenantId && ay.status == 'ACTIVE',
      );
    } catch (_) {
      return null;
    }
  }

  AcademicYearResponse createAcademicYear(String tenantId, CreateAcademicYearRequest req) {
    final newAy = AcademicYearResponse(
      id: 'ay-${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      name: req.name,
      startDate: req.startDate,
      endDate: req.endDate,
      status: 'PLANNED',
      terms: [],
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _academicYears.insert(0, newAy);
    return newAy;
  }

  AcademicYearResponse activateAcademicYear(String tenantId, String yearId) {
    for (int i = 0; i < _academicYears.length; i++) {
      if (_academicYears[i].tenantId == tenantId) {
        if (_academicYears[i].id == yearId) {
          _academicYears[i] = _academicYears[i].copyWith(
            status: 'ACTIVE',
            updatedAt: DateTime.now().toIso8601String(),
          );
        } else if (_academicYears[i].status == 'ACTIVE') {
          _academicYears[i] = _academicYears[i].copyWith(
            status: 'ARCHIVED',
            updatedAt: DateTime.now().toIso8601String(),
          );
        }
      }
    }
    return _academicYears.firstWhere((ay) => ay.id == yearId);
  }

  AcademicYearResponse addAcademicTerm(String yearId, AddAcademicTermRequest req) {
    final idx = _academicYears.indexWhere((ay) => ay.id == yearId);
    if (idx == -1) throw Exception('Academic year $yearId not found');

    final newTerm = AcademicTermResponse(
      id: 'term-${DateTime.now().millisecondsSinceEpoch}',
      academicYearId: yearId,
      name: req.name,
      displayName: req.displayName,
      type: req.type,
      startDate: req.startDate,
      endDate: req.endDate,
      status: 'PLANNED',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    final updatedTerms = List<AcademicTermResponse>.from(_academicYears[idx].terms)..add(newTerm);
    _academicYears[idx] = _academicYears[idx].copyWith(terms: updatedTerms);
    return _academicYears[idx];
  }

  AcademicYearResponse activateAcademicTerm(String yearId, String termId) {
    final idx = _academicYears.indexWhere((ay) => ay.id == yearId);
    if (idx == -1) throw Exception('Academic year $yearId not found');

    final updatedTerms = _academicYears[idx].terms.map((term) {
      if (term.id == termId) {
        return term.copyWith(status: 'ACTIVE');
      } else if (term.status == 'ACTIVE') {
        return term.copyWith(status: 'CONCLUDED');
      }
      return term;
    }).toList();

    _academicYears[idx] = _academicYears[idx].copyWith(terms: updatedTerms);
    return _academicYears[idx];
  }

  // --- IAM Users ---
  List<UserResponse> listUsers() => List.unmodifiable(_users);

  UserResponse? getUserByEmail(String email) {
    try {
      return _users.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  UserResponse createUser(CreateUserRequest req) {
    final newUser = UserResponse(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      email: req.email,
      fullName: req.fullName,
      status: 'ACTIVE',
      isPlatformSuperAdmin: req.isPlatformSuperAdmin ?? false,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _users.add(newUser);
    return newUser;
  }

  UserResponse updateUser(String id, String fullName) {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx == -1) throw Exception('User $id not found');
    _users[idx] = _users[idx].copyWith(
      fullName: fullName,
      updatedAt: DateTime.now().toIso8601String(),
    );
    return _users[idx];
  }

  UserResponse changeUserStatus(String id, String status) {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx == -1) throw Exception('User $id not found');
    _users[idx] = _users[idx].copyWith(
      status: status,
      updatedAt: DateTime.now().toIso8601String(),
    );
    return _users[idx];
  }

  void deleteUser(String id) {
    _users.removeWhere((u) => u.id == id);
    _userRoleAssignments.removeWhere((a) => a.userId == id);
  }

  // --- IAM Roles & Assignments ---
  List<RoleResponse> listRoles(String tenantId) => List.unmodifiable(_roles);

  RoleResponse createRole(String tenantId, CreateRoleRequest req) {
    final newRole = RoleResponse(
      id: 'role-${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      code: req.code,
      name: req.name,
      description: req.description,
      permissions: req.permissions,
      isSystemRole: false,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _roles.add(newRole);
    return newRole;
  }

  UserRoleAssignmentResponse assignUserRole({
    required String userId,
    required String roleId,
    required String tenantId,
    String? scopeNodeId,
  }) {
    final assignment = UserRoleAssignmentResponse(
      id: 'ura-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      roleId: roleId,
      tenantId: tenantId,
      scopeNodeId: scopeNodeId,
      assignedAt: DateTime.now().toIso8601String(),
    );
    _userRoleAssignments.add(assignment);
    return assignment;
  }

  List<UserRoleAssignmentResponse> getUserRoles(String userId) {
    return _userRoleAssignments.where((a) => a.userId == userId).toList();
  }

  void revokeUserRole(String assignmentId) {
    _userRoleAssignments.removeWhere((a) => a.id == assignmentId);
  }

  // --- IAM Groups ---
  List<GroupResponse> listGroups(String tenantId) => List.unmodifiable(_groups);

  GroupResponse createGroup(String tenantId, CreateGroupRequest req) {
    final newGroup = GroupResponse(
      id: 'grp-${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      code: req.code,
      name: req.name,
      description: req.description,
      externalIdpGroupName: req.externalIdpGroupName,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _groups.add(newGroup);
    return newGroup;
  }

  // --- IAM Scopes ---
  List<ScopeTreeNode> getScopeTree(String tenantId) => _scopes;

  ScopeTreeNode createScope(String tenantId, CreateScopeRequest req) {
    final newNode = ScopeTreeNode(
      id: 'scope-${DateTime.now().millisecondsSinceEpoch}',
      code: req.code,
      name: req.name,
      path: '/${req.code}',
      depth: 0,
      parentId: req.parentId,
      children: [],
    );

    if (req.parentId == null) {
      _scopes.add(newNode);
    } else {
      bool added = _addChildToScopeNode(_scopes, req.parentId!, newNode);
      if (!added) _scopes.add(newNode);
    }
    return newNode;
  }

  bool _addChildToScopeNode(List<ScopeTreeNode> nodes, String parentId, ScopeTreeNode child) {
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].id == parentId) {
        final updated = List<ScopeTreeNode>.from(nodes[i].children)..add(child);
        nodes[i] = ScopeTreeNode(
          id: nodes[i].id,
          code: nodes[i].code,
          name: nodes[i].name,
          path: nodes[i].path,
          depth: nodes[i].depth,
          parentId: nodes[i].parentId,
          children: updated,
        );
        return true;
      }
      if (_addChildToScopeNode(nodes[i].children, parentId, child)) {
        return true;
      }
    }
    return false;
  }
}

final mockStorageService = MockStorageService();
