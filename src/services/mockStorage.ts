/**
 * Stateful Mock Engine for Ilmiya & ed-iam Backend APIs.
 * Simulates persistence and business rules in-browser with localStorage fallback.
 */

import { SchoolResponse, AcademicYearResponse, AcademicTermResponse } from '../types/ilmiya';
import { UserResponse, RoleResponse, GroupResponse, ScopeTreeNode, ScopeNodeResponse, UserRoleAssignmentResponse } from '../types/iam';

const DEFAULT_TENANT_ID = 'tenant-lincoln-high-001';

const INITIAL_SCHOOL: SchoolResponse = {
  id: 'school-7a912f91-1b20-4e32-9c12-817a0220e981',
  tenantId: DEFAULT_TENANT_ID,
  name: 'SMA Negeri 1 Ilmiya (Lincoln High Campus)',
  institutionCode: 'NPSN-20109921',
  governmentRegistrationNumber: 'SK-DIKNAS-2024/9912',
  registrationType: 'STATE_SENIOR_HIGH',
  address: 'Jl. Pendidikan Nusantara No. 42, Kebayoran Baru, Jakarta Selatan',
  contactEmail: 'admin@ilmiya-school.edu',
  contactPhone: '+62 21 7890 1234',
  logoUrl: 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=150&auto=format&fit=crop&q=80',
  accreditationStatus: 'ACCREDITED_A',
  accreditationBody: 'BAN-S/M National Accreditation Board',
  accreditationValidUntil: '2029-12-31',
  workingDays: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
  gradingPreference: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
  termLayout: 'SEMESTER',
  status: 'ACTIVE',
  createdAt: '2026-01-10T08:00:00Z',
  updatedAt: '2026-09-01T10:30:00Z'
};

const INITIAL_ACADEMIC_YEARS: AcademicYearResponse[] = [
  {
    id: 'ay-2026-2027',
    tenantId: DEFAULT_TENANT_ID,
    name: 'Academic Year 2026/2027',
    startDate: '2026-07-15',
    endDate: '2027-06-20',
    status: 'ACTIVE',
    terms: [
      {
        id: 'term-sem-1-2026',
        name: 'Semester 1 (Ganjil)',
        type: 'SEMESTER_1',
        displayName: 'Semester Ganjil 2026/2027',
        startDate: '2026-07-15',
        endDate: '2026-12-18',
        status: 'ACTIVE'
      },
      {
        id: 'term-sem-2-2027',
        name: 'Semester 2 (Genap)',
        type: 'SEMESTER_2',
        displayName: 'Semester Genap 2026/2027',
        startDate: '2027-01-08',
        endDate: '2027-06-20',
        status: 'PENDING'
      }
    ],
    createdAt: '2026-06-01T09:00:00Z',
    updatedAt: '2026-07-15T08:00:00Z'
  },
  {
    id: 'ay-2025-2026',
    tenantId: DEFAULT_TENANT_ID,
    name: 'Academic Year 2025/2026',
    startDate: '2025-07-15',
    endDate: '2026-06-25',
    status: 'ARCHIVED',
    terms: [
      {
        id: 'term-sem-1-2025',
        name: 'Semester 1 (Ganjil)',
        type: 'SEMESTER_1',
        displayName: 'Semester Ganjil 2025/2026',
        startDate: '2025-07-15',
        endDate: '2025-12-19',
        status: 'CONCLUDED'
      },
      {
        id: 'term-sem-2-2026',
        name: 'Semester 2 (Genap)',
        type: 'SEMESTER_2',
        displayName: 'Semester Genap 2025/2026',
        startDate: '2026-01-06',
        endDate: '2026-06-25',
        status: 'CONCLUDED'
      }
    ],
    createdAt: '2025-06-01T09:00:00Z',
    updatedAt: '2026-06-25T17:00:00Z'
  }
];

const INITIAL_USERS: UserResponse[] = [
  {
    id: 'u-11111111-1111-1111-1111-111111111111',
    email: 'admin.utama@ilmiya.edu',
    fullName: 'Dr. Sarah Jenkins (Head Administrator)',
    status: 'ACTIVE',
    isPlatformSuperAdmin: true,
    createdAt: '2026-01-01T08:00:00Z',
    updatedAt: '2026-01-01T08:00:00Z'
  },
  {
    id: 'u-22222222-2222-2222-2222-222222222222',
    email: 'principal@ilmiya.edu',
    fullName: 'Prof. Marcus Chen (School Principal)',
    status: 'ACTIVE',
    isPlatformSuperAdmin: false,
    createdAt: '2026-01-05T09:00:00Z',
    updatedAt: '2026-01-05T09:00:00Z'
  },
  {
    id: 'u-33333333-3333-3333-3333-333333333333',
    email: 'eleanor.vance@ilmiya.edu',
    fullName: 'Dr. Eleanor Vance (Computer Science Faculty)',
    status: 'ACTIVE',
    isPlatformSuperAdmin: false,
    createdAt: '2026-02-10T10:00:00Z',
    updatedAt: '2026-02-10T10:00:00Z'
  },
  {
    id: 'u-44444444-4444-4444-4444-444444444444',
    email: 'alex.rivera@student.ilmiya.edu',
    fullName: 'Alex Rivera (Class 10-A)',
    status: 'ACTIVE',
    isPlatformSuperAdmin: false,
    createdAt: '2026-07-10T11:00:00Z',
    updatedAt: '2026-07-10T11:00:00Z'
  },
  {
    id: 'u-55555555-5555-5555-5555-555555555555',
    email: 'elena.rivera@parent.ilmiya.edu',
    fullName: 'Elena Rivera (Parent / Guardian)',
    status: 'ACTIVE',
    isPlatformSuperAdmin: false,
    createdAt: '2026-07-10T11:30:00Z',
    updatedAt: '2026-07-10T11:30:00Z'
  }
];

const INITIAL_ROLES: RoleResponse[] = [
  {
    id: 'role-superadmin',
    tenantId: DEFAULT_TENANT_ID,
    code: 'SUPERADMIN',
    name: 'Platform Super Administrator',
    description: 'Full institutional and multi-tenant operational rights across all bounded contexts.',
    permissions: [
      'school:profile:read', 'school:profile:write', 'school:settings:manage',
      'academic:year:read', 'academic:year:write', 'academic:curriculum:read', 'academic:curriculum:manage',
      'academic:course:read', 'academic:course:write', 'student:profile:read', 'student:profile:write',
      'student:enrollment:manage', 'student:guardian:manage', 'attendance:record:read', 'attendance:record:create',
      'attendance:record:update', 'attendance:record:approve', 'exam:schedule:read', 'exam:schedule:manage',
      'exam:grade:create', 'exam:grade:update', 'exam:report-card:publish', 'finance:fee:manage',
      'finance:invoice:create', 'finance:payment:create', 'finance:report:read',
      'iam:user:create', 'iam:user:read', 'iam:user:update', 'iam:user:status', 'iam:user:delete',
      'iam:user:assign-role', 'iam:user:manage-membership', 'iam:role:create', 'iam:role:read',
      'iam:role:update', 'iam:role:delete', 'iam:group:create', 'iam:group:read', 'iam:group:update',
      'iam:group:delete', 'iam:scope:create', 'iam:scope:read', 'iam:scope:update', 'iam:scope:move', 'iam:scope:delete'
    ],
    isSystemRole: true,
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z'
  },
  {
    id: 'role-school-admin',
    tenantId: DEFAULT_TENANT_ID,
    code: 'SCHOOL_ADMIN',
    name: 'School Administrator',
    description: 'Institutional settings, user onboarding, and academic year rollover.',
    permissions: [
      'school:profile:read', 'school:profile:write', 'school:settings:manage',
      'academic:year:read', 'academic:year:write', 'academic:curriculum:read', 'academic:curriculum:manage',
      'iam:user:create', 'iam:user:read', 'iam:user:update', 'iam:user:assign-role', 'iam:group:read'
    ],
    isSystemRole: true,
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z'
  },
  {
    id: 'role-teacher',
    tenantId: DEFAULT_TENANT_ID,
    code: 'TEACHER',
    name: 'Educator & Subject Instructor',
    description: 'Attendance entry, continuous grading, curriculum delivery, and report cards.',
    permissions: [
      'school:profile:read', 'academic:year:read', 'academic:course:read', 'academic:course:write',
      'student:profile:read', 'attendance:record:read', 'attendance:record:create', 'attendance:record:update',
      'exam:grade:create', 'exam:grade:update', 'exam:report-card:publish'
    ],
    isSystemRole: true,
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z'
  },
  {
    id: 'role-student',
    tenantId: DEFAULT_TENANT_ID,
    code: 'STUDENT',
    name: 'Student Learner',
    description: 'Course schedules, grade reviews, assignment submissions, and attendance logs.',
    permissions: [
      'school:profile:read', 'academic:year:read', 'academic:course:read', 'student:profile:read',
      'attendance:record:read', 'exam:grade:create'
    ],
    isSystemRole: true,
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z'
  }
];

const INITIAL_GROUPS: GroupResponse[] = [
  {
    id: 'grp-teachers-stem',
    tenantId: DEFAULT_TENANT_ID,
    code: 'GRP_STEM_FACULTY',
    name: 'STEM Faculty Department',
    description: 'Science, Technology, Engineering and Mathematics Instructors',
    externalIdpGroupName: 'idp_stem_teachers',
    createdAt: '2026-01-15T08:00:00Z',
    updatedAt: '2026-01-15T08:00:00Z'
  },
  {
    id: 'grp-grade-10',
    tenantId: DEFAULT_TENANT_ID,
    code: 'GRP_COHORT_2026',
    name: 'Cohort 2026 / Grade 10 Batch',
    description: 'All enrolled 10th grade students across classes 10-A, 10-B, and 10-C',
    externalIdpGroupName: 'idp_students_grade10',
    createdAt: '2026-07-01T08:00:00Z',
    updatedAt: '2026-07-01T08:00:00Z'
  }
];

const INITIAL_SCOPES: ScopeTreeNode[] = [
  {
    id: 'scope-root',
    code: 'CAMPUS_MAIN',
    name: 'Lincoln High Main Campus',
    path: '/CAMPUS_MAIN',
    depth: 0,
    parentId: null,
    children: [
      {
        id: 'scope-senior-high',
        code: 'DIV_SENIOR_HIGH',
        name: 'Senior High School (SMA)',
        path: '/CAMPUS_MAIN/DIV_SENIOR_HIGH',
        depth: 1,
        parentId: 'scope-root',
        children: [
          {
            id: 'scope-dept-cs',
            code: 'DEPT_CS',
            name: 'Computer Science Department',
            path: '/CAMPUS_MAIN/DIV_SENIOR_HIGH/DEPT_CS',
            depth: 2,
            parentId: 'scope-senior-high',
            children: []
          },
          {
            id: 'scope-class-10a',
            code: 'CLASS_10A',
            name: 'Class 10-A (Science Track)',
            path: '/CAMPUS_MAIN/DIV_SENIOR_HIGH/CLASS_10A',
            depth: 2,
            parentId: 'scope-senior-high',
            children: []
          }
        ]
      },
      {
        id: 'scope-junior-high',
        code: 'DIV_JUNIOR_HIGH',
        name: 'Junior High School (SMP)',
        path: '/CAMPUS_MAIN/DIV_JUNIOR_HIGH',
        depth: 1,
        parentId: 'scope-root',
        children: []
      }
    ]
  }
];

class MockStorageEngine {
  private school: SchoolResponse;
  private academicYears: AcademicYearResponse[];
  private users: UserResponse[];
  private roles: RoleResponse[];
  private groups: GroupResponse[];
  private scopes: ScopeTreeNode[];
  private userRoleAssignments: UserRoleAssignmentResponse[];
  private userGroupMemberships: { userId: string; groupId: string }[];

  constructor() {
    this.school = JSON.parse(JSON.stringify(INITIAL_SCHOOL));
    this.academicYears = JSON.parse(JSON.stringify(INITIAL_ACADEMIC_YEARS));
    this.users = JSON.parse(JSON.stringify(INITIAL_USERS));
    this.roles = JSON.parse(JSON.stringify(INITIAL_ROLES));
    this.groups = JSON.parse(JSON.stringify(INITIAL_GROUPS));
    this.scopes = JSON.parse(JSON.stringify(INITIAL_SCOPES));
    this.userRoleAssignments = [
      {
        id: 'ura-1',
        userId: 'u-11111111-1111-1111-1111-111111111111',
        roleId: 'role-superadmin',
        tenantId: DEFAULT_TENANT_ID,
        scopeNodeId: 'scope-root',
        assignedAt: '2026-01-01T08:00:00Z'
      },
      {
        id: 'ura-2',
        userId: 'u-33333333-3333-3333-3333-333333333333',
        roleId: 'role-teacher',
        tenantId: DEFAULT_TENANT_ID,
        scopeNodeId: 'scope-dept-cs',
        assignedAt: '2026-02-10T10:00:00Z'
      },
      {
        id: 'ura-3',
        userId: 'u-44444444-4444-4444-4444-444444444444',
        roleId: 'role-student',
        tenantId: DEFAULT_TENANT_ID,
        scopeNodeId: 'scope-class-10a',
        assignedAt: '2026-07-10T11:00:00Z'
      },
      {
        id: 'ura-4',
        userId: 'u-22222222-2222-2222-2222-222222222222',
        roleId: 'role-school-admin',
        tenantId: DEFAULT_TENANT_ID,
        scopeNodeId: 'scope-root',
        assignedAt: '2026-01-05T09:00:00Z'
      }
    ];
    this.userGroupMemberships = [
      { userId: 'u-33333333-3333-3333-3333-333333333333', groupId: 'grp-teachers-stem' },
      { userId: 'u-44444444-4444-4444-4444-444444444444', groupId: 'grp-grade-10' }
    ];
  }

  // --- School & Profile ---
  public getSchoolProfile(tenantId: string): SchoolResponse {
    if (this.school.tenantId === tenantId) {
      return this.school;
    }
    return {
      ...this.school,
      tenantId,
      name: `School Institutional Entity (${tenantId})`
    };
  }

  public registerSchool(data: Partial<SchoolResponse>): SchoolResponse {
    const id = `school-${Date.now()}`;
    const newSchool: SchoolResponse = {
      id,
      tenantId: data.tenantId || `tenant-${Date.now()}`,
      name: data.name || 'New Institution',
      institutionCode: data.institutionCode || 'NPSN-PENDING',
      governmentRegistrationNumber: data.governmentRegistrationNumber || null,
      registrationType: data.registrationType || 'REGULAR',
      address: data.address || '',
      contactEmail: data.contactEmail || '',
      contactPhone: data.contactPhone || '',
      logoUrl: data.logoUrl || null,
      accreditationStatus: data.accreditationStatus || 'UNACCREDITED',
      accreditationBody: data.accreditationBody || null,
      accreditationValidUntil: data.accreditationValidUntil || null,
      workingDays: data.workingDays || ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
      gradingPreference: data.gradingPreference || 'NUMERIC_0_100',
      termLayout: data.termLayout || 'SEMESTER',
      status: 'ACTIVE',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    this.school = newSchool;
    return newSchool;
  }

  public updateSchoolProfile(data: Partial<SchoolResponse>): SchoolResponse {
    this.school = {
      ...this.school,
      ...data,
      updatedAt: new Date().toISOString()
    };
    return this.school;
  }

  public configureSettings(data: { workingDays?: string[]; gradingPreference?: any; termLayout?: any }): SchoolResponse {
    this.school = {
      ...this.school,
      workingDays: data.workingDays || this.school.workingDays,
      gradingPreference: data.gradingPreference || this.school.gradingPreference,
      termLayout: data.termLayout || this.school.termLayout,
      updatedAt: new Date().toISOString()
    };
    return this.school;
  }

  // --- Academic Years ---
  public listAcademicYears(tenantId: string): AcademicYearResponse[] {
    return this.academicYears;
  }

  public getActiveAcademicYear(tenantId: string): AcademicYearResponse | null {
    return this.academicYears.find(ay => ay.status === 'ACTIVE') || null;
  }

  public getAcademicYearById(id: string): AcademicYearResponse {
    const ay = this.academicYears.find(y => y.id === id);
    if (!ay) throw new Error(`Academic year with ID ${id} not found.`);
    return ay;
  }

  public createAcademicYear(data: { name: string; startDate: string; endDate: string }, tenantId: string): AcademicYearResponse {
    const id = `ay-${Date.now()}`;
    const newAy: AcademicYearResponse = {
      id,
      tenantId,
      name: data.name,
      startDate: data.startDate,
      endDate: data.endDate,
      status: 'UPCOMING',
      terms: [],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    this.academicYears = [newAy, ...this.academicYears];
    return newAy;
  }

  public activateAcademicYear(id: string): AcademicYearResponse {
    this.academicYears = this.academicYears.map(ay => {
      if (ay.id === id) {
        return { ...ay, status: 'ACTIVE', updatedAt: new Date().toISOString() };
      }
      if (ay.status === 'ACTIVE') {
        return { ...ay, status: 'ARCHIVED', updatedAt: new Date().toISOString() };
      }
      return ay;
    });
    return this.getAcademicYearById(id);
  }

  public addAcademicTerm(yearId: string, data: { name: string; type: any; displayName: string; startDate: string; endDate: string }): AcademicTermResponse {
    const ay = this.getAcademicYearById(yearId);
    const newTerm: AcademicTermResponse = {
      id: `term-${Date.now()}`,
      name: data.name,
      type: data.type,
      displayName: data.displayName,
      startDate: data.startDate,
      endDate: data.endDate,
      status: ay.terms.length === 0 ? 'ACTIVE' : 'PENDING'
    };
    ay.terms.push(newTerm);
    ay.updatedAt = new Date().toISOString();
    return newTerm;
  }

  public activateAcademicTerm(yearId: string, termId: string): AcademicTermResponse {
    const ay = this.getAcademicYearById(yearId);
    let activatedTerm: AcademicTermResponse | undefined;
    ay.terms = ay.terms.map(t => {
      if (t.id === termId) {
        activatedTerm = { ...t, status: 'ACTIVE' };
        return activatedTerm;
      }
      if (t.status === 'ACTIVE') {
        return { ...t, status: 'CONCLUDED' };
      }
      return t;
    });
    if (!activatedTerm) throw new Error(`Term ${termId} not found in academic year ${yearId}`);
    return activatedTerm;
  }

  // --- IAM: Users ---
  public listUsers(): UserResponse[] {
    return this.users;
  }

  public getUserById(id: string): UserResponse {
    const user = this.users.find(u => u.id === id);
    if (!user) throw new Error(`User with ID ${id} not found.`);
    return user;
  }

  public getUserByEmail(email: string): UserResponse | null {
    return this.users.find(u => u.email.toLowerCase() === email.toLowerCase()) || null;
  }

  public createUser(data: { email: string; fullName: string; isPlatformSuperAdmin?: boolean }): UserResponse {
    const id = `u-${Date.now()}`;
    const newUser: UserResponse = {
      id,
      email: data.email,
      fullName: data.fullName,
      status: 'ACTIVE',
      isPlatformSuperAdmin: data.isPlatformSuperAdmin ?? false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    this.users = [newUser, ...this.users];
    return newUser;
  }

  public updateUser(id: string, fullName: string): UserResponse {
    const user = this.getUserById(id);
    user.fullName = fullName;
    user.updatedAt = new Date().toISOString();
    return user;
  }

  public changeUserStatus(id: string, status: any): UserResponse {
    const user = this.getUserById(id);
    user.status = status;
    user.updatedAt = new Date().toISOString();
    return user;
  }

  public deleteUser(id: string): void {
    this.users = this.users.filter(u => u.id !== id);
    this.userRoleAssignments = this.userRoleAssignments.filter(a => a.userId !== id);
    this.userGroupMemberships = this.userGroupMemberships.filter(m => m.userId !== id);
  }

  public assignUserRole(userId: string, roleId: string, tenantId: string, scopeNodeId?: string | null): UserRoleAssignmentResponse {
    const assignment: UserRoleAssignmentResponse = {
      id: `ura-${Date.now()}`,
      userId,
      roleId,
      tenantId,
      scopeNodeId: scopeNodeId || null,
      assignedAt: new Date().toISOString()
    };
    this.userRoleAssignments.push(assignment);
    return assignment;
  }

  public revokeUserRole(assignmentId: string): void {
    this.userRoleAssignments = this.userRoleAssignments.filter(a => a.id !== assignmentId);
  }

  public getUserRoleAssignments(userId: string): UserRoleAssignmentResponse[] {
    return this.userRoleAssignments.filter(a => a.userId === userId);
  }

  public addUserToGroup(userId: string, groupId: string): void {
    if (!this.userGroupMemberships.some(m => m.userId === userId && m.groupId === groupId)) {
      this.userGroupMemberships.push({ userId, groupId });
    }
  }

  public removeUserFromGroup(userId: string, groupId: string): void {
    this.userGroupMemberships = this.userGroupMemberships.filter(m => !(m.userId === userId && m.groupId === groupId));
  }

  public getUserGroups(userId: string): GroupResponse[] {
    const groupIds = this.userGroupMemberships.filter(m => m.userId === userId).map(m => m.groupId);
    return this.groups.filter(g => groupIds.includes(g.id));
  }

  // --- IAM: Roles ---
  public listRoles(tenantId: string): RoleResponse[] {
    return this.roles;
  }

  public getRoleById(id: string): RoleResponse {
    const role = this.roles.find(r => r.id === id);
    if (!role) throw new Error(`Role with ID ${id} not found.`);
    return role;
  }

  public createRole(data: { code: string; name: string; description?: string | null; permissions: string[]; tenantId?: string }): RoleResponse {
    const id = `role-${Date.now()}`;
    const newRole: RoleResponse = {
      id,
      tenantId: data.tenantId || DEFAULT_TENANT_ID,
      code: data.code.toUpperCase(),
      name: data.name,
      description: data.description || null,
      permissions: data.permissions,
      isSystemRole: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    this.roles.push(newRole);
    return newRole;
  }

  public updateRole(id: string, data: { name: string; description?: string | null; permissions: string[] }): RoleResponse {
    const role = this.getRoleById(id);
    role.name = data.name;
    role.description = data.description ?? role.description;
    role.permissions = data.permissions;
    role.updatedAt = new Date().toISOString();
    return role;
  }

  public deleteRole(id: string): void {
    this.roles = this.roles.filter(r => r.id !== id);
    this.userRoleAssignments = this.userRoleAssignments.filter(a => a.roleId !== id);
  }

  // --- IAM: Groups ---
  public listGroups(tenantId: string): GroupResponse[] {
    return this.groups;
  }

  public getGroupById(id: string): GroupResponse {
    const group = this.groups.find(g => g.id === id);
    if (!group) throw new Error(`Group with ID ${id} not found.`);
    return group;
  }

  public createGroup(data: { code: string; name: string; description?: string | null; externalIdpGroupName?: string | null; tenantId?: string }): GroupResponse {
    const id = `grp-${Date.now()}`;
    const newGroup: GroupResponse = {
      id,
      tenantId: data.tenantId || DEFAULT_TENANT_ID,
      code: data.code.toUpperCase(),
      name: data.name,
      description: data.description || null,
      externalIdpGroupName: data.externalIdpGroupName || null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    this.groups.push(newGroup);
    return newGroup;
  }

  public updateGroup(id: string, data: { name: string; description?: string | null; externalIdpGroupName?: string | null }): GroupResponse {
    const group = this.getGroupById(id);
    group.name = data.name;
    group.description = data.description ?? group.description;
    group.externalIdpGroupName = data.externalIdpGroupName ?? group.externalIdpGroupName;
    group.updatedAt = new Date().toISOString();
    return group;
  }

  public deleteGroup(id: string): void {
    this.groups = this.groups.filter(g => g.id !== id);
    this.userGroupMemberships = this.userGroupMemberships.filter(m => m.groupId !== id);
  }

  public getGroupMembers(groupId: string): UserResponse[] {
    const userIds = this.userGroupMemberships.filter(m => m.groupId === groupId).map(m => m.userId);
    return this.users.filter(u => userIds.includes(u.id));
  }

  // --- IAM: Scope Tree ---
  public getScopeTree(): ScopeTreeNode[] {
    return this.scopes;
  }

  public getFlatScopes(): ScopeNodeResponse[] {
    const list: ScopeNodeResponse[] = [];
    const traverse = (node: ScopeTreeNode, tenantId: string) => {
      list.push({
        id: node.id,
        tenantId,
        parentId: node.parentId || null,
        code: node.code,
        name: node.name,
        path: node.path,
        depth: node.depth,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z'
      });
      node.children.forEach(c => traverse(c, tenantId));
    };
    this.scopes.forEach(s => traverse(s, DEFAULT_TENANT_ID));
    return list;
  }

  public createScope(data: { code: string; name: string; parentId?: string | null }): ScopeNodeResponse {
    const id = `scope-${Date.now()}`;
    const parent = data.parentId ? this.findScopeNode(this.scopes, data.parentId) : null;
    const path = parent ? `${parent.path}/${data.code}` : `/${data.code}`;
    const depth = parent ? parent.depth + 1 : 0;

    const newNode: ScopeTreeNode = {
      id,
      code: data.code.toUpperCase(),
      name: data.name,
      path,
      depth,
      parentId: data.parentId || null,
      children: []
    };

    if (parent) {
      parent.children.push(newNode);
    } else {
      this.scopes.push(newNode);
    }

    return {
      id,
      tenantId: DEFAULT_TENANT_ID,
      parentId: newNode.parentId,
      code: newNode.code,
      name: newNode.name,
      path: newNode.path,
      depth: newNode.depth,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
  }

  public updateScope(id: string, code: string, name: string): ScopeNodeResponse {
    const node = this.findScopeNode(this.scopes, id);
    if (!node) throw new Error(`Scope node ${id} not found.`);
    node.code = code;
    node.name = name;
    return {
      id: node.id,
      tenantId: DEFAULT_TENANT_ID,
      parentId: node.parentId || null,
      code: node.code,
      name: node.name,
      path: node.path,
      depth: node.depth,
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: new Date().toISOString()
    };
  }

  public deleteScope(id: string): void {
    const removeRecursive = (nodes: ScopeTreeNode[]): ScopeTreeNode[] => {
      return nodes.filter(n => n.id !== id).map(n => ({
        ...n,
        children: removeRecursive(n.children)
      }));
    };
    this.scopes = removeRecursive(this.scopes);
  }

  private findScopeNode(nodes: ScopeTreeNode[], id: string): ScopeTreeNode | null {
    for (const node of nodes) {
      if (node.id === id) return node;
      const child = this.findScopeNode(node.children, id);
      if (child) return child;
    }
    return null;
  }
}

export const mockStorage = new MockStorageEngine();
