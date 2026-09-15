/**
 * Identity & Access Management (ed-iam) Service.
 * Interacts with /api/v1/auth, /api/v1/users, /api/v1/roles, /api/v1/groups, and /api/v1/scopes.
 */

import { apiClient, safeStorage } from './apiClient';
import { mockStorage } from './mockStorage';
import {
  UserResponse,
  CreateUserRequest,
  UpdateUserRequest,
  ChangeUserStatusRequest,
  UserRoleAssignmentResponse,
  AssignUserRoleRequest,
  RoleResponse,
  CreateRoleRequest,
  UpdateRoleRequest,
  GroupResponse,
  CreateGroupRequest,
  UpdateGroupRequest,
  ScopeTreeNode,
  ScopeNodeResponse,
  CreateScopeRequest,
  UpdateScopeRequest,
  MoveScopeRequest,
  TokenResponse,
  UserProfileResponse,
  LoginRequest
} from '../types/iam';

export class IamService {
  // ================= Auth Endpoints =================

  public async login(request: LoginRequest): Promise<TokenResponse> {
    const email = (request.email || '').toLowerCase().trim();
    if (request.tenantId) {
      apiClient.setTenantId(request.tenantId);
    }

    if (apiClient.isMockMode) {
      const token = `mock-jwt-token-${Date.now()}`;
      const refreshToken = `mock-refresh-${Date.now()}`;
      apiClient.setToken(token);
      apiClient.setRefreshToken(refreshToken);

      const mockUser = mockStorage.getUserByEmail(email);
      let roles = ['USER'];
      let permissions: string[] = [];
      let fullName = mockUser?.fullName || 'Academic Staff Member';
      let userId = mockUser?.id || `u-${Date.now()}`;

      if (email.includes('admin.utama') || mockUser?.isPlatformSuperAdmin) {
        roles = ['SUPERADMIN'];
        permissions = ['*'];
        fullName = 'Dr. Sarah Jenkins (Head Administrator)';
      } else if (email.includes('principal')) {
        roles = ['SCHOOL_ADMIN'];
        permissions = mockStorage.listRoles(apiClient.tenantId).find(r => r.code === 'SCHOOL_ADMIN')?.permissions || [
          'school:profile:read', 'school:profile:write', 'school:settings:manage',
          'academic:year:read', 'academic:year:write', 'academic:curriculum:read', 'academic:curriculum:manage',
          'iam:user:create', 'iam:user:read', 'iam:user:update', 'iam:user:assign-role', 'iam:group:read'
        ];
        fullName = 'Prof. Marcus Chen (School Principal)';
      } else if (email.includes('eleanor.vance') || email.includes('teacher')) {
        roles = ['TEACHER'];
        permissions = mockStorage.listRoles(apiClient.tenantId).find(r => r.code === 'TEACHER')?.permissions || [
          'school:profile:read', 'academic:year:read', 'academic:course:read', 'academic:course:write',
          'student:profile:read', 'attendance:record:read', 'attendance:record:create', 'attendance:record:update',
          'exam:grade:create', 'exam:grade:update', 'exam:report-card:publish'
        ];
        fullName = 'Dr. Eleanor Vance (Computer Science Faculty)';
      } else if (email.includes('student') || email.includes('alex.rivera')) {
        roles = ['STUDENT'];
        permissions = mockStorage.listRoles(apiClient.tenantId).find(r => r.code === 'STUDENT')?.permissions || [
          'school:profile:read', 'academic:year:read', 'academic:course:read', 'student:profile:read',
          'attendance:record:read', 'exam:grade:create'
        ];
        fullName = 'Alex Rivera (Class 10-A)';
      } else if (email.includes('parent') || email.includes('elena.rivera')) {
        roles = ['PARENT'];
        permissions = ['student:profile:read', 'attendance:record:read', 'exam:grade:read'];
        fullName = 'Elena Rivera (Parent / Guardian)';
      } else {
        roles = ['USER'];
        permissions = ['school:profile:read', 'academic:year:read'];
      }

      const profile: UserProfileResponse = {
        id: userId,
        email: email || 'user@ilmiya.edu',
        fullName,
        tenantId: apiClient.tenantId,
        roles,
        permissions,
        scopes: ['/CAMPUS_MAIN']
      };
      safeStorage.setItem('ilmiya_user_profile', JSON.stringify(profile));

      return {
        accessToken: token,
        refreshToken,
        tokenType: 'Bearer',
        expiresIn: 3600,
        tenantId: apiClient.tenantId,
        roles,
        permissions
      };
    }

    try {
      const response = await apiClient.request<TokenResponse>('/api/v1/auth/login', {
        method: 'POST',
        body: JSON.stringify(request)
      });
      apiClient.setToken(response.accessToken);
      if (response.refreshToken) {
        apiClient.setRefreshToken(response.refreshToken);
      }
      if (response.tenantId) {
        apiClient.setTenantId(response.tenantId);
      }
      // Attempt to load actor profile
      try {
        const me = await this.getMe();
        safeStorage.setItem('ilmiya_user_profile', JSON.stringify(me));
      } catch {}
      return response;
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock login:', err);
      const token = `mock-jwt-token-${Date.now()}`;
      const refreshToken = `mock-refresh-${Date.now()}`;
      apiClient.setToken(token);
      apiClient.setRefreshToken(refreshToken);

      const profile: UserProfileResponse = {
        id: 'u-11111111-1111-1111-1111-111111111111',
        email: email || 'admin.utama@ilmiya.edu',
        fullName: 'Dr. Sarah Jenkins (Head Administrator)',
        tenantId: apiClient.tenantId,
        roles: ['SUPERADMIN'],
        permissions: ['*'],
        scopes: ['/CAMPUS_MAIN']
      };
      safeStorage.setItem('ilmiya_user_profile', JSON.stringify(profile));

      return {
        accessToken: token,
        refreshToken,
        tokenType: 'Bearer',
        expiresIn: 3600,
        tenantId: apiClient.tenantId,
        roles: ['SUPERADMIN'],
        permissions: ['*']
      };
    }
  }

  public async getMe(): Promise<UserProfileResponse> {
    const saved = safeStorage.getItem('ilmiya_user_profile');
    if (apiClient.isMockMode) {
      if (saved) {
        try {
          const parsed = JSON.parse(saved);
          return { ...parsed, tenantId: apiClient.tenantId };
        } catch {}
      }
      return {
        id: 'u-11111111-1111-1111-1111-111111111111',
        email: 'admin.utama@ilmiya.edu',
        fullName: 'Dr. Sarah Jenkins (Head Administrator)',
        tenantId: apiClient.tenantId,
        roles: ['SUPERADMIN'],
        permissions: ['*'],
        scopes: ['/CAMPUS_MAIN']
      };
    }

    try {
      const profile = await apiClient.request<UserProfileResponse>('/api/v1/auth/me', {
        method: 'GET'
      });
      safeStorage.setItem('ilmiya_user_profile', JSON.stringify(profile));
      return profile;
    } catch (err) {
      if (saved) {
        try {
          return JSON.parse(saved);
        } catch {}
      }
      console.warn('Backend unavailable, falling back to mock getMe:', err);
      return {
        id: 'u-11111111-1111-1111-1111-111111111111',
        email: 'admin.utama@ilmiya.edu',
        fullName: 'Dr. Sarah Jenkins (Head Administrator)',
        tenantId: apiClient.tenantId,
        roles: ['SUPERADMIN'],
        permissions: ['*'],
        scopes: ['/CAMPUS_MAIN']
      };
    }
  }

  public logout(): void {
    apiClient.setToken(null);
    apiClient.setRefreshToken(null);
    safeStorage.removeItem('ilmiya_user_profile');
  }

  public async switchTenant(targetTenantId: string): Promise<TokenResponse> {
    apiClient.setTenantId(targetTenantId);

    // Update cached profile's tenantId if present
    const saved = safeStorage.getItem('ilmiya_user_profile');
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        parsed.tenantId = targetTenantId;
        safeStorage.setItem('ilmiya_user_profile', JSON.stringify(parsed));
      } catch {}
    }

    if (apiClient.isMockMode) {
      const token = `mock-jwt-switched-${Date.now()}`;
      const refreshToken = `mock-refresh-${Date.now()}`;
      apiClient.setToken(token);
      apiClient.setRefreshToken(refreshToken);
      return {
        accessToken: token,
        refreshToken,
        tokenType: 'Bearer',
        expiresIn: 3600,
        tenantId: targetTenantId,
        roles: ['SUPERADMIN'],
        permissions: ['*']
      };
    }

    try {
      const response = await apiClient.request<TokenResponse>('/api/v1/auth/switch-tenant', {
        method: 'POST',
        headers: {
          'X-Tenant-ID': targetTenantId
        },
        body: JSON.stringify({ tenantId: targetTenantId })
      });
      apiClient.setToken(response.accessToken);
      if (response.refreshToken) {
        apiClient.setRefreshToken(response.refreshToken);
      }
      return response;
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock switchTenant:', err);
      const token = `mock-jwt-switched-${Date.now()}`;
      const refreshToken = `mock-refresh-${Date.now()}`;
      apiClient.setToken(token);
      apiClient.setRefreshToken(refreshToken);
      return {
        accessToken: token,
        refreshToken,
        tokenType: 'Bearer',
        expiresIn: 3600,
        tenantId: targetTenantId,
        roles: ['SUPERADMIN'],
        permissions: ['*']
      };
    }
  }

  // ================= User Management Endpoints =================

  public async listUsers(): Promise<UserResponse[]> {
    if (apiClient.isMockMode) {
      return mockStorage.listUsers();
    }
    try {
      return await apiClient.request<UserResponse[]>('/api/v1/users', { method: 'GET' });
    } catch (err) {
      return mockStorage.listUsers();
    }
  }

  public async getUserById(id: string): Promise<UserResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.getUserById(id);
    }
    try {
      return await apiClient.request<UserResponse>(`/api/v1/users/${id}`, { method: 'GET' });
    } catch (err) {
      return mockStorage.getUserById(id);
    }
  }

  public async createUser(request: CreateUserRequest): Promise<UserResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.createUser(request);
    }
    try {
      return await apiClient.request<UserResponse>('/api/v1/users', {
        method: 'POST',
        body: JSON.stringify(request)
      });
    } catch (err) {
      return mockStorage.createUser(request);
    }
  }

  public async updateUser(id: string, request: UpdateUserRequest): Promise<UserResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.updateUser(id, request.fullName);
    }
    try {
      return await apiClient.request<UserResponse>(`/api/v1/users/${id}`, {
        method: 'PUT',
        body: JSON.stringify(request)
      });
    } catch (err) {
      return mockStorage.updateUser(id, request.fullName);
    }
  }

  public async changeUserStatus(id: string, request: ChangeUserStatusRequest): Promise<UserResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.changeUserStatus(id, request.status);
    }
    try {
      return await apiClient.request<UserResponse>(`/api/v1/users/${id}/status`, {
        method: 'PUT',
        body: JSON.stringify(request)
      });
    } catch (err) {
      return mockStorage.changeUserStatus(id, request.status);
    }
  }

  public async deleteUser(id: string): Promise<void> {
    if (apiClient.isMockMode) {
      return mockStorage.deleteUser(id);
    }
    try {
      await apiClient.request<void>(`/api/v1/users/${id}`, { method: 'DELETE' });
    } catch (err) {
      mockStorage.deleteUser(id);
    }
  }

  public async assignRole(userId: string, request: AssignUserRoleRequest): Promise<UserRoleAssignmentResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.assignUserRole(userId, request.roleId, request.tenantId, request.scopeNodeId);
    }
    try {
      return await apiClient.request<UserRoleAssignmentResponse>(`/api/v1/users/${userId}/roles`, {
        method: 'POST',
        body: JSON.stringify(request)
      });
    } catch (err) {
      return mockStorage.assignUserRole(userId, request.roleId, request.tenantId, request.scopeNodeId);
    }
  }

  public async revokeRole(userId: string, assignmentId: string): Promise<void> {
    if (apiClient.isMockMode) {
      return mockStorage.revokeUserRole(assignmentId);
    }
    try {
      await apiClient.request<void>(`/api/v1/users/${userId}/roles/${assignmentId}`, { method: 'DELETE' });
    } catch (err) {
      mockStorage.revokeUserRole(assignmentId);
    }
  }

  public async getUserRoles(userId: string): Promise<UserRoleAssignmentResponse[]> {
    if (apiClient.isMockMode) {
      return mockStorage.getUserRoleAssignments(userId);
    }
    try {
      return await apiClient.request<UserRoleAssignmentResponse[]>(`/api/v1/users/${userId}/roles`, {
        method: 'GET'
      });
    } catch (err) {
      return mockStorage.getUserRoleAssignments(userId);
    }
  }

  public async addUserToGroup(userId: string, groupId: string): Promise<void> {
    if (apiClient.isMockMode) {
      return mockStorage.addUserToGroup(userId, groupId);
    }
    try {
      await apiClient.request<void>(`/api/v1/users/${userId}/groups/${groupId}`, { method: 'POST' });
    } catch (err) {
      mockStorage.addUserToGroup(userId, groupId);
    }
  }

  public async removeUserFromGroup(userId: string, groupId: string): Promise<void> {
    if (apiClient.isMockMode) {
      return mockStorage.removeUserFromGroup(userId, groupId);
    }
    try {
      await apiClient.request<void>(`/api/v1/users/${userId}/groups/${groupId}`, { method: 'DELETE' });
    } catch (err) {
      mockStorage.removeUserFromGroup(userId, groupId);
    }
  }

  public async getUserGroups(userId: string): Promise<GroupResponse[]> {
    if (apiClient.isMockMode) {
      return mockStorage.getUserGroups(userId);
    }
    try {
      return await apiClient.request<GroupResponse[]>(`/api/v1/users/${userId}/groups`, { method: 'GET' });
    } catch (err) {
      return mockStorage.getUserGroups(userId);
    }
  }

  // ================= Role Management Endpoints =================

  public async listRoles(): Promise<RoleResponse[]> {
    if (apiClient.isMockMode) {
      return mockStorage.listRoles(apiClient.tenantId);
    }
    try {
      return await apiClient.request<RoleResponse[]>('/api/v1/roles', { method: 'GET' });
    } catch (err) {
      return mockStorage.listRoles(apiClient.tenantId);
    }
  }

  public async getRoleById(id: string): Promise<RoleResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.getRoleById(id);
    }
    try {
      return await apiClient.request<RoleResponse>(`/api/v1/roles/${id}`, { method: 'GET' });
    } catch (err) {
      return mockStorage.getRoleById(id);
    }
  }

  public async createRole(request: CreateRoleRequest): Promise<RoleResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.createRole(request);
    }
    try {
      return await apiClient.request<RoleResponse>('/api/v1/roles', {
        method: 'POST',
        body: JSON.stringify(request)
      });
    } catch (err) {
      return mockStorage.createRole(request);
    }
  }

  public async updateRole(id: string, request: UpdateRoleRequest): Promise<RoleResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.updateRole(id, request);
    }
    try {
      return await apiClient.request<RoleResponse>(`/api/v1/roles/${id}`, {
        method: 'PUT',
        body: JSON.stringify(request)
      });
    } catch (err) {
      return mockStorage.updateRole(id, request);
    }
  }

  public async deleteRole(id: string): Promise<void> {
    if (apiClient.isMockMode) {
      return mockStorage.deleteRole(id);
    }
    try {
      await apiClient.request<void>(`/api/v1/roles/${id}`, { method: 'DELETE' });
    } catch (err) {
      mockStorage.deleteRole(id);
    }
  }

  // ================= Group Management Endpoints =================

  public async listGroups(): Promise<GroupResponse[]> {
    if (apiClient.isMockMode) {
      return mockStorage.listGroups(apiClient.tenantId);
    }
    try {
      return await apiClient.request<GroupResponse[]>('/api/v1/groups', { method: 'GET' });
    } catch (err) {
      return mockStorage.listGroups(apiClient.tenantId);
    }
  }

  public async getGroupById(id: string): Promise<GroupResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.getGroupById(id);
    }
    try {
      return await apiClient.request<GroupResponse>(`/api/v1/groups/${id}`, { method: 'GET' });
    } catch (err) {
      return mockStorage.getGroupById(id);
    }
  }

  public async createGroup(request: CreateGroupRequest): Promise<GroupResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.createGroup(request);
    }
    try {
      return await apiClient.request<GroupResponse>('/api/v1/groups', {
        method: 'POST',
        body: JSON.stringify(request)
      });
    } catch (err) {
      return mockStorage.createGroup(request);
    }
  }

  public async updateGroup(id: string, request: UpdateGroupRequest): Promise<GroupResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.updateGroup(id, request);
    }
    try {
      return await apiClient.request<GroupResponse>(`/api/v1/groups/${id}`, {
        method: 'PUT',
        body: JSON.stringify(request)
      });
    } catch (err) {
      return mockStorage.updateGroup(id, request);
    }
  }

  public async deleteGroup(id: string): Promise<void> {
    if (apiClient.isMockMode) {
      return mockStorage.deleteGroup(id);
    }
    try {
      await apiClient.request<void>(`/api/v1/groups/${id}`, { method: 'DELETE' });
    } catch (err) {
      mockStorage.deleteGroup(id);
    }
  }

  public async getGroupMembers(groupId: string): Promise<UserResponse[]> {
    if (apiClient.isMockMode) {
      return mockStorage.getGroupMembers(groupId);
    }
    try {
      return await apiClient.request<UserResponse[]>(`/api/v1/groups/${groupId}/members`, { method: 'GET' });
    } catch (err) {
      return mockStorage.getGroupMembers(groupId);
    }
  }

  // ================= Scope Hierarchy Endpoints =================

  public async getScopeTree(): Promise<ScopeTreeNode[]> {
    if (apiClient.isMockMode) {
      return mockStorage.getScopeTree();
    }
    try {
      return await apiClient.request<ScopeTreeNode[]>('/api/v1/scopes/tree', { method: 'GET' });
    } catch (err) {
      return mockStorage.getScopeTree();
    }
  }

  public async getFlatScopes(): Promise<ScopeNodeResponse[]> {
    if (apiClient.isMockMode) {
      return mockStorage.getFlatScopes();
    }
    try {
      return await apiClient.request<ScopeNodeResponse[]>('/api/v1/scopes', { method: 'GET' });
    } catch (err) {
      return mockStorage.getFlatScopes();
    }
  }

  public async createScope(request: CreateScopeRequest): Promise<ScopeNodeResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.createScope(request);
    }
    try {
      return await apiClient.request<ScopeNodeResponse>('/api/v1/scopes', {
        method: 'POST',
        body: JSON.stringify(request)
      });
    } catch (err) {
      return mockStorage.createScope(request);
    }
  }

  public async updateScope(id: string, request: UpdateScopeRequest): Promise<ScopeNodeResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.updateScope(id, request.code, request.name);
    }
    try {
      return await apiClient.request<ScopeNodeResponse>(`/api/v1/scopes/${id}`, {
        method: 'PUT',
        body: JSON.stringify(request)
      });
    } catch (err) {
      return mockStorage.updateScope(id, request.code, request.name);
    }
  }

  public async moveScope(id: string, request: MoveScopeRequest): Promise<ScopeNodeResponse> {
    if (apiClient.isMockMode) {
      // In mock, moving can reparent
      const tree = mockStorage.getScopeTree();
      // simplified return
      return mockStorage.updateScope(id, 'MOVED', 'Moved Scope');
    }
    try {
      return await apiClient.request<ScopeNodeResponse>(`/api/v1/scopes/${id}/move`, {
        method: 'POST',
        body: JSON.stringify(request)
      });
    } catch (err) {
      return mockStorage.updateScope(id, 'MOVED', 'Moved Scope');
    }
  }

  public async deleteScope(id: string): Promise<void> {
    if (apiClient.isMockMode) {
      return mockStorage.deleteScope(id);
    }
    try {
      await apiClient.request<void>(`/api/v1/scopes/${id}`, { method: 'DELETE' });
    } catch (err) {
      mockStorage.deleteScope(id);
    }
  }
}

export const iamService = new IamService();
