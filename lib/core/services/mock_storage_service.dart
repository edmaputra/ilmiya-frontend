import '../models/school.dart';
import '../models/tenant.dart';
import '../models/academic_year.dart';
import '../models/iam.dart';

const String DEFAULT_TENANT_ID = 'tenant-lincoln-high-001';

class MockStorageService {
  static final MockStorageService _instance = MockStorageService._internal();
  factory MockStorageService() => _instance;

  late SchoolResponse _school;
  late List<TenantResponse> _tenants;
  late List<SchoolResponse> _schools;
  late List<AcademicYearResponse> _academicYears;
  late List<UserResponse> _users;
  late List<RoleResponse> _roles;
  late List<GroupResponse> _groups;
  late List<ScopeTreeNode> _scopes;
  late List<UserRoleAssignmentResponse> _userRoleAssignments;
  late Map<String, Set<String>> _groupMembers;
  late List<GroupRoleAssignmentResponse> _groupRoleAssignments;

  MockStorageService._internal() {
    reset();
  }

  void reset() {
    _groupMembers = {};
    _groupRoleAssignments = [];

    _tenants = [
      TenantResponse(
        id: DEFAULT_TENANT_ID,
        name: 'Yayasan Pendidikan Lincoln Ilmiya',
        legalEntityNumber: 'AHU-0012345.AH.01.04.2020',
        registrationType: 'FOUNDATION',
        address: '1240 Oakcrest Ave, Portland, OR 97201',
        contactEmail: 'foundation@lincolnhigh.edu',
        contactPhone: '+1 503 555 0192',
        status: 'ACTIVE',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      TenantResponse(
        id: 'tenant-sma1-ilmiya-002',
        name: 'Yayasan Pembina Generasi Ilmiya',
        legalEntityNumber: 'AHU-0098765.AH.01.04.2021',
        registrationType: 'FOUNDATION',
        address: 'Jl. Pendidikan No. 42, Kebayoran Baru, Jakarta Selatan',
        contactEmail: 'sekretariat@ilmiya-foundation.id',
        contactPhone: '+62 21 7890 1234',
        status: 'ACTIVE',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      TenantResponse(
        id: 'tenant-alazhar-003',
        name: 'Yayasan Pesantren Islam Al-Azhar',
        legalEntityNumber: 'AHU-0034567.AH.01.04.2018',
        registrationType: 'FOUNDATION',
        address: 'Jl. Sisingamangaraja No. 1, Kebayoran Baru, Jakarta Selatan',
        contactEmail: 'info@alazhar-foundation.sch.id',
        contactPhone: '+62 21 7278 8900',
        status: 'ACTIVE',
        createdAt: '2026-02-10T00:00:00Z',
        updatedAt: '2026-02-10T00:00:00Z',
      ),
      TenantResponse(
        id: 'tenant-horizon-004',
        name: 'Horizon STEM Education Trust',
        legalEntityNumber: 'WA-CORP-98721',
        registrationType: 'NON_PROFIT_ORGANIZATION',
        address: '770 Innovation Blvd, Silicon Forest, WA 98052',
        contactEmail: 'contact@horizon-trust.org',
        contactPhone: '+1 206 555 0148',
        status: 'PENDING',
        createdAt: '2026-03-01T00:00:00Z',
        updatedAt: '2026-03-01T00:00:00Z',
      ),
      TenantResponse(
        id: 'tenant-stjude-005',
        name: 'St. Jude Educational Association',
        legalEntityNumber: 'MA-NONPROFIT-4412',
        registrationType: 'RELIGIOUS_BODY',
        address: '500 Cathedral St, Boston, MA 02118',
        contactEmail: 'office@stjude-edu.org',
        contactPhone: '+1 617 555 0184',
        status: 'SUSPENDED',
        createdAt: '2026-01-15T00:00:00Z',
        updatedAt: '2026-01-15T00:00:00Z',
      ),
    ];

    _schools = [
      SchoolResponse(
        id: 'sch-001',
        tenantId: DEFAULT_TENANT_ID,
        name: 'SMA Negeri 1 Ilmiya (Lincoln High Campus)',
        institutionCode: 'SMAN1-ILM',
        address: '1240 Oakcrest Ave, Portland, OR 97201',
        contactEmail: 'office@lincolnhigh.edu',
        contactPhone: '+1 503 555 0192',
        logoUrl:
            'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=300&auto=format&fit=crop&q=80',
        status: 'ACTIVE',
        governmentRegistrationNumber: 'NPSN-10823401',
        registrationType: 'PUBLIC_DISTRICT',
        accreditationStatus: 'ACCREDITED_A',
        accreditationBody: 'Northwest Accreditation Commission',
        accreditationValidUntil: '2028-12-31',
        workingDays: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
        gradingPreference: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
        termLayout: 'SEMESTER',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      SchoolResponse(
        id: 'sch-002',
        tenantId: 'tenant-sma1-ilmiya-002',
        name: 'SMA Negeri 1 Ilmiya',
        institutionCode: 'SMAN1-JKT',
        address: 'Jl. Pendidikan No. 42, Kebayoran Baru, Jakarta Selatan',
        contactEmail: 'admin@ilmiya-school.edu',
        contactPhone: '+62 21 7890 1234',
        logoUrl:
            'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=300&auto=format&fit=crop&q=80',
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
      ),
      SchoolResponse(
        id: 'sch-003',
        tenantId: 'tenant-alazhar-003',
        name: 'Al-Azhar Islamic Academy',
        institutionCode: 'AZHAR-SMA-01',
        address: 'Jl. Sisingamangaraja No. 1, Kebayoran Baru, Jakarta Selatan',
        contactEmail: 'sma@alazhar.sch.id',
        contactPhone: '+62 21 7278 8900',
        status: 'ACTIVE',
        governmentRegistrationNumber: 'NPSN-20104432',
        registrationType: 'PRIVATE_FOUNDATION',
        accreditationStatus: 'ACCREDITED_A',
        accreditationBody: 'BAN-S/M Indonesia',
        accreditationValidUntil: '2029-06-30',
        workingDays: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
        gradingPreference: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
        termLayout: 'SEMESTER',
        createdAt: '2026-02-10T00:00:00Z',
        updatedAt: '2026-02-10T00:00:00Z',
      ),
      SchoolResponse(
        id: 'sch-004',
        tenantId: 'tenant-horizon-004',
        name: 'Horizon International STEM Academy',
        institutionCode: 'HORIZON-004',
        address: '770 Innovation Blvd, Silicon Forest, WA 98052',
        contactEmail: 'contact@horizon-stem.edu',
        contactPhone: '+1 206 555 0148',
        status: 'PENDING',
        governmentRegistrationNumber: 'NPSN-30910022',
        registrationType: 'CHARTER_REGIONAL',
        accreditationStatus: 'ACCREDITED_B',
        accreditationBody: 'STEM AdvancED Org',
        accreditationValidUntil: '2027-10-31',
        workingDays: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
        gradingPreference: 'STANDARD_LETTER_GRADE',
        termLayout: 'TRIMESTER',
        createdAt: '2026-03-01T00:00:00Z',
        updatedAt: '2026-03-01T00:00:00Z',
      ),
      SchoolResponse(
        id: 'sch-005',
        tenantId: 'tenant-stjude-005',
        name: 'St. Jude Preparatory School',
        institutionCode: 'STJUDE-005',
        address: '500 Cathedral St, Boston, MA 02118',
        contactEmail: 'admin@stjude-prep.org',
        contactPhone: '+1 617 555 0184',
        status: 'SUSPENDED',
        governmentRegistrationNumber: 'NPSN-10024955',
        registrationType: 'PRIVATE_PAROCHIAL',
        accreditationStatus: 'ACCREDITED_C',
        accreditationBody: 'New England Schools Commission',
        accreditationValidUntil: '2026-12-31',
        workingDays: [
          'MONDAY',
          'TUESDAY',
          'WEDNESDAY',
          'THURSDAY',
          'FRIDAY',
          'SATURDAY'
        ],
        gradingPreference: 'NUMERIC_100_POINT',
        termLayout: 'QUARTER',
        createdAt: '2026-01-15T00:00:00Z',
        updatedAt: '2026-01-15T00:00:00Z',
      ),
    ];
    _school = _schools.first;

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
        description:
            'Full institutional and multi-tenant rights across all bounded contexts.',
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
        description:
            'Institutional settings, user onboarding, and academic year rollover.',
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
        description:
            'Attendance entry, continuous grading, curriculum delivery, and report cards.',
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
        description:
            'Course schedules, grade reviews, assignment submissions, and attendance logs.',
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
        description:
            'Science, Technology, Engineering and Mathematics Instructors',
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

  // --- Tenant (Yayasan / Foundation) Management ---
  List<TenantResponse> listTenants({String? query, String? status}) {
    return _tenants.where((t) {
      if (status != null &&
          status.isNotEmpty &&
          status.toUpperCase() != 'ALL') {
        if (t.status.toUpperCase() != status.toUpperCase()) return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matches = t.name.toLowerCase().contains(q) ||
            t.id.toLowerCase().contains(q) ||
            (t.legalEntityNumber?.toLowerCase().contains(q) ?? false) ||
            t.contactEmail.toLowerCase().contains(q) ||
            t.address.toLowerCase().contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  TenantResponse getTenant(String tenantId) {
    return _tenants.firstWhere(
      (t) => t.id == tenantId,
      orElse: () => TenantResponse(
        id: tenantId,
        name: 'Yayasan $tenantId',
        address: 'Foundation Campus, District HQ',
        contactEmail: 'yayasan@ilmiya.edu',
        contactPhone: '+62 21 5555 0199',
        status: 'ACTIVE',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  TenantResponse createTenant(CreateTenantRequest req) {
    final newTenant = TenantResponse(
      id: req.tenantId.isNotEmpty
          ? req.tenantId
          : 'tenant-${DateTime.now().millisecondsSinceEpoch}',
      name: req.name,
      legalEntityNumber: req.legalEntityNumber,
      registrationType: req.registrationType ?? 'FOUNDATION',
      address: req.address,
      contactEmail: req.contactEmail,
      contactPhone: req.contactPhone,
      logoUrl: req.logoUrl,
      status: 'ACTIVE',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _tenants.add(newTenant);
    return newTenant;
  }

  TenantResponse updateTenant(String tenantId, UpdateTenantRequest req) {
    final index = _tenants.indexWhere((t) => t.id == tenantId);
    final target = index != -1
        ? _tenants[index]
        : TenantResponse(
            id: tenantId,
            name: req.name,
            address: req.address,
            contactEmail: req.contactEmail,
            contactPhone: req.contactPhone,
            status: req.status,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          );

    final updated = target.copyWith(
      name: req.name,
      address: req.address,
      contactEmail: req.contactEmail,
      contactPhone: req.contactPhone,
      logoUrl: req.logoUrl,
      legalEntityNumber: req.legalEntityNumber,
      registrationType: req.registrationType,
      status: req.status,
      updatedAt: DateTime.now().toIso8601String(),
    );

    if (index != -1) {
      _tenants[index] = updated;
    } else {
      _tenants.add(updated);
    }
    return updated;
  }

  TenantResponse updateTenantStatus(String tenantId, String newStatus) {
    final index = _tenants.indexWhere((t) => t.id == tenantId);
    if (index != -1) {
      final updated = _tenants[index].copyWith(
        status: newStatus.toUpperCase(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      _tenants[index] = updated;
      return updated;
    }
    throw Exception('Tenant not found: $tenantId');
  }

  bool deleteTenant(String tenantId) {
    final countBefore = _tenants.length;
    _tenants.removeWhere((t) => t.id == tenantId);
    return _tenants.length < countBefore;
  }

  // --- School Profile & Multi-Tenant Schools ---
  List<SchoolResponse> listSchools(
      {String? tenantId, String? query, String? status}) {
    return _schools.where((s) {
      if (tenantId != null && tenantId.isNotEmpty) {
        if (s.tenantId != tenantId) return false;
      }
      if (status != null &&
          status.isNotEmpty &&
          status.toUpperCase() != 'ALL') {
        if (s.status.toUpperCase() != status.toUpperCase()) return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matches = s.name.toLowerCase().contains(q) ||
            s.tenantId.toLowerCase().contains(q) ||
            s.institutionCode.toLowerCase().contains(q) ||
            (s.governmentRegistrationNumber?.toLowerCase().contains(q) ??
                false) ||
            s.contactEmail.toLowerCase().contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  SchoolResponse getSchoolProfile(String targetId) {
    final byId = _schools.where((s) => s.id == targetId);
    if (byId.isNotEmpty) {
      return byId.first;
    }
    final byTenant = _schools.where((s) => s.tenantId == targetId);
    if (byTenant.isNotEmpty) {
      return byTenant.first;
    }
    final branch = SchoolResponse(
      id: 'sch-$targetId',
      tenantId: targetId,
      name: 'Branch Campus ($targetId)',
      institutionCode: 'BRANCH-$targetId',
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
    _schools.add(branch);
    return branch;
  }

  SchoolResponse updateSchoolProfile(UpdateSchoolRequest req,
      {String? targetTenantId}) {
    final tId = targetTenantId ?? _school.tenantId;
    final index = _schools.indexWhere((s) => s.tenantId == tId || s.id == tId);
    final target = index != -1 ? _schools[index] : _school;

    final updated = target.copyWith(
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

    if (index != -1) {
      _schools[index] = updated;
    } else {
      _schools.add(updated);
    }
    if (tId == _school.tenantId || tId == _school.id) {
      _school = updated;
    }
    return updated;
  }

  SchoolResponse configureSchoolSettings(ConfigureSchoolSettingsRequest req,
      {String? targetTenantId}) {
    final tId = targetTenantId ?? _school.tenantId;
    final index = _schools.indexWhere((s) => s.tenantId == tId || s.id == tId);
    final target = index != -1 ? _schools[index] : _school;

    final updated = target.copyWith(
      workingDays: req.workingDays,
      gradingPreference: req.gradingPreference,
      termLayout: req.termLayout,
      updatedAt: DateTime.now().toIso8601String(),
    );

    if (index != -1) {
      _schools[index] = updated;
    } else {
      _schools.add(updated);
    }
    if (tId == _school.tenantId || tId == _school.id) {
      _school = updated;
    }
    return updated;
  }

  SchoolResponse registerSchool(RegisterSchoolRequest req) {
    final newSchool = SchoolResponse(
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
    final existingIdx = _schools.indexWhere((s) =>
        s.tenantId == req.tenantId && s.institutionCode == req.institutionCode);
    if (existingIdx != -1) {
      _schools[existingIdx] = newSchool;
    } else {
      _schools.add(newSchool);
    }
    return newSchool;
  }

  SchoolResponse updateSchoolStatus(String targetId, String newStatus) {
    var index = _schools.indexWhere((s) => s.id == targetId);
    if (index == -1) {
      index = _schools.indexWhere((s) => s.tenantId == targetId);
    }
    if (index != -1) {
      final updated = _schools[index].copyWith(
        status: newStatus.toUpperCase(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      _schools[index] = updated;
      if (targetId == _school.tenantId || targetId == _school.id) {
        _school = updated;
      }
      return updated;
    }
    throw Exception('School not found: $targetId');
  }

  bool deleteSchool(String targetId) {
    final countBefore = _schools.length;
    _schools.removeWhere((s) => s.id == targetId || s.tenantId == targetId);
    return _schools.length < countBefore;
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

  AcademicYearResponse createAcademicYear(
      String tenantId, CreateAcademicYearRequest req) {
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

  AcademicYearResponse addAcademicTerm(
      String yearId, AddAcademicTermRequest req) {
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

    final updatedTerms =
        List<AcademicTermResponse>.from(_academicYears[idx].terms)
          ..add(newTerm);
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
      return _users
          .firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
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
      isPlatformSuperAdmin: req.platformSuperAdmin ?? false,
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

  GroupResponse updateGroup(String id, UpdateGroupRequest req) {
    final idx = _groups.indexWhere((g) => g.id == id);
    if (idx == -1) throw Exception('Group $id not found');
    final updated = GroupResponse(
      id: _groups[idx].id,
      tenantId: _groups[idx].tenantId,
      code: _groups[idx].code,
      name: req.name,
      description: req.description,
      externalIdpGroupName: req.externalIdpGroupName,
      createdAt: _groups[idx].createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    _groups[idx] = updated;
    return updated;
  }

  void deleteGroup(String id) {
    _groups.removeWhere((g) => g.id == id);
    _groupMembers.remove(id);
    _groupRoleAssignments.removeWhere((a) => a.groupId == id);
  }

  List<UserResponse> getGroupMembers(String groupId) {
    final memberIds = _groupMembers[groupId] ?? {};
    return _users.where((u) => memberIds.contains(u.id)).toList();
  }

  void addUserToGroup(String userId, String groupId) {
    _groupMembers.putIfAbsent(groupId, () => <String>{}).add(userId);
  }

  void removeUserFromGroup(String userId, String groupId) {
    _groupMembers[groupId]?.remove(userId);
  }

  List<GroupRoleAssignmentResponse> getGroupRoles(String groupId) {
    return _groupRoleAssignments.where((a) => a.groupId == groupId).toList();
  }

  GroupRoleAssignmentResponse assignGroupRole({
    required String groupId,
    required String roleId,
    required String tenantId,
    String? scopeNodeId,
  }) {
    final assignment = GroupRoleAssignmentResponse(
      id: 'gra-${DateTime.now().millisecondsSinceEpoch}',
      groupId: groupId,
      roleId: roleId,
      tenantId: tenantId,
      scopeNodeId: scopeNodeId,
    );
    _groupRoleAssignments.add(assignment);
    return assignment;
  }

  void revokeGroupRole(String assignmentId) {
    _groupRoleAssignments.removeWhere((a) => a.id == assignmentId);
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
      final added = _addChildToScopeNode(_scopes, req.parentId!, newNode);
      if (!added) _scopes.add(newNode);
    }
    return newNode;
  }

  bool _addChildToScopeNode(
      List<ScopeTreeNode> nodes, String parentId, ScopeTreeNode child) {
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
