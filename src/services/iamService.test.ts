import { describe, it, expect, beforeEach } from 'bun:test';
import { iamService } from './iamService';
import { apiClient } from './apiClient';

describe('IamService', () => {
  beforeEach(() => {
    apiClient.setMockMode(true);
    apiClient.setTenantId('tenant-lincoln-high-001');
  });

  it('should authenticate user and switch tenant', async () => {
    const loginResp = await iamService.login({
      email: 'admin.utama@ilmiya.edu',
      password: 'password123'
    });

    expect(loginResp.accessToken).toBeDefined();
    expect(loginResp.roles).toContain('SUPERADMIN');

    const me = await iamService.getMe();
    expect(me.email).toBe('admin.utama@ilmiya.edu');

    const switched = await iamService.switchTenant('tenant-secondary-002');
    expect(switched.tenantId).toBe('tenant-secondary-002');
    expect(apiClient.tenantId).toBe('tenant-secondary-002');
  });

  it('should correctly authenticate personas (principal, teacher, student) and handle logout', async () => {
    // Principal login
    const principalLogin = await iamService.login({
      email: 'principal@ilmiya.edu',
      password: 'Principal@123'
    });
    expect(principalLogin.roles).toContain('SCHOOL_ADMIN');
    expect(principalLogin.permissions).toContain('school:profile:write');

    const principalProfile = await iamService.getMe();
    expect(principalProfile.fullName).toContain('Marcus Chen');
    expect(principalProfile.roles).toContain('SCHOOL_ADMIN');

    // Teacher login
    const teacherLogin = await iamService.login({
      email: 'eleanor.vance@ilmiya.edu',
      password: 'Teacher@123'
    });
    expect(teacherLogin.roles).toContain('TEACHER');
    expect(teacherLogin.permissions).toContain('exam:grade:create');

    const teacherProfile = await iamService.getMe();
    expect(teacherProfile.fullName).toContain('Eleanor Vance');

    // Student login
    const studentLogin = await iamService.login({
      email: 'alex.rivera@student.ilmiya.edu',
      password: 'Student@123'
    });
    expect(studentLogin.roles).toContain('STUDENT');

    // Logout
    iamService.logout();
    expect(apiClient.token).toBeNull();
    expect(apiClient.refreshToken).toBeNull();
  });

  it('should handle user creation, status updating, and role assignments', async () => {
    const user = await iamService.createUser({
      email: 'finance.officer@ilmiya.edu',
      fullName: 'Siti Rahmawati (Bursar)',
      isPlatformSuperAdmin: false
    });

    expect(user.id).toBeDefined();
    expect(user.fullName).toBe('Siti Rahmawati (Bursar)');

    const updatedUser = await iamService.updateUser(user.id, {
      fullName: 'Siti Rahmawati, S.E. (Chief Bursar)'
    });
    expect(updatedUser.fullName).toBe('Siti Rahmawati, S.E. (Chief Bursar)');

    const statusChanged = await iamService.changeUserStatus(user.id, { status: 'SUSPENDED' });
    expect(statusChanged.status).toBe('SUSPENDED');

    const roleAssignment = await iamService.assignRole(user.id, {
      roleId: 'role-superadmin',
      tenantId: 'tenant-lincoln-high-001'
    });
    expect(roleAssignment.roleId).toBe('role-superadmin');

    const roles = await iamService.getUserRoles(user.id);
    expect(roles.some(r => r.id === roleAssignment.id)).toBe(true);

    await iamService.revokeRole(user.id, roleAssignment.id);
    const rolesAfterRevoke = await iamService.getUserRoles(user.id);
    expect(rolesAfterRevoke.some(r => r.id === roleAssignment.id)).toBe(false);
  });

  it('should manage roles, groups, and scope hierarchy', async () => {
    const role = await iamService.createRole({
      code: 'EXAM_COORDINATOR',
      name: 'Examination Coordinator',
      permissions: ['exam:schedule:manage', 'exam:grade:create', 'exam:report-card:publish']
    });
    expect(role.code).toBe('EXAM_COORDINATOR');

    const group = await iamService.createGroup({
      code: 'EXAM_BOARD',
      name: 'School Examination Board'
    });
    expect(group.code).toBe('EXAM_BOARD');

    const scopeTree = await iamService.getScopeTree();
    expect(scopeTree.length).toBeGreaterThan(0);

    const childScope = await iamService.createScope({
      code: 'ROOM_LAB_BIO',
      name: 'Biology Laboratory Room',
      parentId: scopeTree[0].id
    });
    expect(childScope.code).toBe('ROOM_LAB_BIO');
  });
});
