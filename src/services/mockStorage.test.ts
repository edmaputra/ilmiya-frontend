import { describe, it, expect, beforeEach } from 'bun:test';
import { mockStorage } from './mockStorage';

describe('MockStorageEngine', () => {
  const tenantId = 'tenant-test-001';

  it('should return initial school profile with default properties', () => {
    const profile = mockStorage.getSchoolProfile(tenantId);
    expect(profile).toBeDefined();
    expect(profile.name).toBeDefined();
    expect(profile.workingDays).toContain('MONDAY');
    expect(profile.gradingPreference).toBe('DESCRIPTIVE_KURIKULUM_MERDEKA');
    expect(profile.termLayout).toBe('SEMESTER');
  });

  it('should update school operational settings', () => {
    const updated = mockStorage.configureSettings({
      workingDays: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'],
      gradingPreference: 'NUMERIC_0_100',
      termLayout: 'TRIMESTER'
    });

    expect(updated.workingDays).toHaveLength(6);
    expect(updated.gradingPreference).toBe('NUMERIC_0_100');
    expect(updated.termLayout).toBe('TRIMESTER');
  });

  it('should create and activate academic years', () => {
    const newYear = mockStorage.createAcademicYear({
      name: 'Academic Year 2027/2028',
      startDate: '2027-07-15',
      endDate: '2028-06-20'
    }, tenantId);

    expect(newYear.id).toBeDefined();
    expect(newYear.name).toBe('Academic Year 2027/2028');
    expect(newYear.status).toBe('UPCOMING');

    const activated = mockStorage.activateAcademicYear(newYear.id);
    expect(activated.status).toBe('ACTIVE');

    // Adding terms
    const term1 = mockStorage.addAcademicTerm(newYear.id, {
      name: 'Semester Ganjil 2027',
      type: 'SEMESTER_1',
      displayName: 'Semester 1',
      startDate: '2027-07-15',
      endDate: '2027-12-20'
    });
    expect(term1.id).toBeDefined();
    expect(term1.status).toBe('ACTIVE');

    const term2 = mockStorage.addAcademicTerm(newYear.id, {
      name: 'Semester Genap 2028',
      type: 'SEMESTER_2',
      displayName: 'Semester 2',
      startDate: '2028-01-10',
      endDate: '2028-06-20'
    });
    expect(term2.status).toBe('PENDING');

    const activatedTerm2 = mockStorage.activateAcademicTerm(newYear.id, term2.id);
    expect(activatedTerm2.status).toBe('ACTIVE');
  });

  it('should manage IAM users and status transitions', () => {
    const user = mockStorage.createUser({
      email: 'new.teacher@ilmiya.edu',
      fullName: 'Budi Rahardjo',
      isPlatformSuperAdmin: false
    });

    expect(user.id).toBeDefined();
    expect(user.status).toBe('ACTIVE');

    const suspended = mockStorage.changeUserStatus(user.id, 'SUSPENDED');
    expect(suspended.status).toBe('SUSPENDED');

    const roleAssignment = mockStorage.assignUserRole(user.id, 'role-teacher', tenantId, 'scope-dept-cs');
    expect(roleAssignment.roleId).toBe('role-teacher');
    expect(roleAssignment.scopeNodeId).toBe('scope-dept-cs');

    const assignments = mockStorage.getUserRoleAssignments(user.id);
    expect(assignments.some(a => a.id === roleAssignment.id)).toBe(true);

    mockStorage.deleteUser(user.id);
    expect(mockStorage.getUserByEmail('new.teacher@ilmiya.edu')).toBeNull();
  });

  it('should manage custom roles and permission assignment', () => {
    const role = mockStorage.createRole({
      code: 'CURRICULUM_LEAD',
      name: 'Curriculum Coordinator',
      description: 'Coordinates teaching syllabi and subject guidelines',
      permissions: ['academic:curriculum:read', 'academic:curriculum:manage', 'academic:course:read']
    });

    expect(role.code).toBe('CURRICULUM_LEAD');
    expect(role.permissions).toContain('academic:curriculum:manage');

    const updated = mockStorage.updateRole(role.id, {
      name: 'Senior Curriculum Coordinator',
      permissions: ['academic:curriculum:read', 'academic:curriculum:manage', 'academic:course:read', 'academic:course:write']
    });

    expect(updated.name).toBe('Senior Curriculum Coordinator');
    expect(updated.permissions).toContain('academic:course:write');
  });

  it('should navigate and manipulate hierarchical scope tree', () => {
    const tree = mockStorage.getScopeTree();
    expect(tree.length).toBeGreaterThan(0);
    expect(tree[0].code).toBe('CAMPUS_MAIN');

    const newScope = mockStorage.createScope({
      code: 'LAB_ROBOTICS',
      name: 'Advanced Robotics Lab',
      parentId: tree[0].id
    });

    expect(newScope.code).toBe('LAB_ROBOTICS');
    expect(newScope.path).toContain('/CAMPUS_MAIN/LAB_ROBOTICS');
  });
});
