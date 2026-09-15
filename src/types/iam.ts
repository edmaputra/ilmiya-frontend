/**
 * ed-iam Management Domain Models & DTOs
 * Matching backend: io.github.edmaputra.iam
 */

export type UserStatus = 'ACTIVE' | 'SUSPENDED' | 'PENDING_ACTIVATION' | 'DEACTIVATED';

export interface UserResponse {
  id: string;
  email: string;
  fullName: string;
  status: UserStatus;
  isPlatformSuperAdmin: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface CreateUserRequest {
  email: string;
  password?: string;
  fullName: string;
  isPlatformSuperAdmin?: boolean;
}

export interface UpdateUserRequest {
  fullName: string;
}

export interface ChangeUserStatusRequest {
  status: UserStatus;
}

export interface UserRoleAssignmentResponse {
  id: string;
  userId: string;
  roleId: string;
  tenantId: string;
  scopeNodeId?: string | null;
  assignedAt: string;
}

export interface AssignUserRoleRequest {
  roleId: string;
  tenantId: string;
  scopeNodeId?: string | null;
}

export interface RoleResponse {
  id: string;
  tenantId: string;
  code: string;
  name: string;
  description?: string | null;
  permissions: string[];
  isSystemRole?: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface CreateRoleRequest {
  tenantId?: string;
  code: string;
  name: string;
  description?: string | null;
  permissions: string[];
}

export interface UpdateRoleRequest {
  name: string;
  description?: string | null;
  permissions: string[];
}

export interface GroupResponse {
  id: string;
  tenantId: string;
  code: string;
  name: string;
  description?: string | null;
  externalIdpGroupName?: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface CreateGroupRequest {
  tenantId?: string;
  code: string;
  name: string;
  description?: string | null;
  externalIdpGroupName?: string | null;
}

export interface UpdateGroupRequest {
  name: string;
  description?: string | null;
  externalIdpGroupName?: string | null;
}

export interface GroupRoleAssignmentResponse {
  id: string;
  groupId: string;
  roleId: string;
  tenantId: string;
  scopeNodeId?: string | null;
  assignedAt: string;
}

export interface AssignGroupRoleRequest {
  roleId: string;
  tenantId: string;
  scopeNodeId?: string | null;
}

export interface ScopeNodeResponse {
  id: string;
  tenantId: string;
  parentId?: string | null;
  code: string;
  name: string;
  path: string;
  depth: number;
  createdAt: string;
  updatedAt: string;
}

export interface ScopeTreeNode {
  id: string;
  code: string;
  name: string;
  path: string;
  depth: number;
  parentId?: string | null;
  children: ScopeTreeNode[];
}

export interface CreateScopeRequest {
  tenantId?: string;
  parentId?: string | null;
  code: string;
  name: string;
}

export interface UpdateScopeRequest {
  code: string;
  name: string;
}

export interface MoveScopeRequest {
  newParentId: string;
}

export interface TokenResponse {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  tenantId?: string | null;
  roles: string[];
  permissions: string[];
}

export interface UserProfileResponse {
  id: string;
  email: string;
  fullName: string;
  tenantId?: string | null;
  roles: string[];
  permissions: string[];
  scopes: string[];
}

export interface LoginRequest {
  username?: string;
  email?: string;
  password?: string;
  tenantId?: string;
}

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface SwitchTenantRequest {
  tenantId: string;
}

/**
 * Standard fine-grained permission constants across Ilmiya and ed-iam.
 */
export const AVAILABLE_PERMISSIONS = [
  // School Context
  { code: 'school:profile:read', category: 'School Profile', label: 'View School Profile' },
  { code: 'school:profile:write', category: 'School Profile', label: 'Edit School Profile' },
  { code: 'school:settings:manage', category: 'School Profile', label: 'Manage School Settings' },

  // Academic Context
  { code: 'academic:year:read', category: 'Academic', label: 'View Academic Years' },
  { code: 'academic:year:write', category: 'Academic', label: 'Manage Academic Years & Terms' },
  { code: 'academic:curriculum:read', category: 'Academic', label: 'View Curriculum' },
  { code: 'academic:curriculum:manage', category: 'Academic', label: 'Manage Curriculum' },
  { code: 'academic:course:read', category: 'Academic', label: 'View Courses' },
  { code: 'academic:course:write', category: 'Academic', label: 'Edit Courses' },

  // Student Context
  { code: 'student:profile:read', category: 'Student', label: 'View Student Master' },
  { code: 'student:profile:write', category: 'Student', label: 'Manage Student Master' },
  { code: 'student:enrollment:manage', category: 'Student', label: 'Manage Enrollment (PPDB)' },
  { code: 'student:guardian:manage', category: 'Student', label: 'Manage Guardian Links' },

  // Attendance Context
  { code: 'attendance:record:read', category: 'Attendance', label: 'View Attendance Records' },
  { code: 'attendance:record:create', category: 'Attendance', label: 'Record Attendance' },
  { code: 'attendance:record:update', category: 'Attendance', label: 'Modify Attendance' },
  { code: 'attendance:record:approve', category: 'Attendance', label: 'Approve Attendance Leaves' },

  // Examination Context
  { code: 'exam:schedule:read', category: 'Examination', label: 'View Exam Schedules' },
  { code: 'exam:schedule:manage', category: 'Examination', label: 'Manage Exam Schedules' },
  { code: 'exam:grade:create', category: 'Examination', label: 'Submit Grades' },
  { code: 'exam:grade:update', category: 'Examination', label: 'Modify Grades' },
  { code: 'exam:report-card:publish', category: 'Examination', label: 'Publish Report Cards (e-Rapor)' },

  // Finance Context
  { code: 'finance:fee:manage', category: 'Finance', label: 'Manage Fee Structures' },
  { code: 'finance:invoice:create', category: 'Finance', label: 'Generate Invoices' },
  { code: 'finance:payment:create', category: 'Finance', label: 'Record Fee Payments' },
  { code: 'finance:report:read', category: 'Finance', label: 'View Financial Reports' },

  // IAM Context
  { code: 'iam:user:create', category: 'IAM User', label: 'Create User' },
  { code: 'iam:user:read', category: 'IAM User', label: 'Read Users' },
  { code: 'iam:user:update', category: 'IAM User', label: 'Update User Profile' },
  { code: 'iam:user:status', category: 'IAM User', label: 'Change User Status' },
  { code: 'iam:user:delete', category: 'IAM User', label: 'Delete User' },
  { code: 'iam:user:assign-role', category: 'IAM User', label: 'Assign / Revoke User Roles' },
  { code: 'iam:user:manage-membership', category: 'IAM User', label: 'Manage Group Memberships' },

  { code: 'iam:role:create', category: 'IAM Role', label: 'Create Custom Role' },
  { code: 'iam:role:read', category: 'IAM Role', label: 'Read Roles' },
  { code: 'iam:role:update', category: 'IAM Role', label: 'Update Role Permissions' },
  { code: 'iam:role:delete', category: 'IAM Role', label: 'Delete Role' },

  { code: 'iam:group:create', category: 'IAM Group', label: 'Create Group' },
  { code: 'iam:group:read', category: 'IAM Group', label: 'Read Groups' },
  { code: 'iam:group:update', category: 'IAM Group', label: 'Update Group' },
  { code: 'iam:group:delete', category: 'IAM Group', label: 'Delete Group' },

  { code: 'iam:scope:create', category: 'IAM Scope', label: 'Create Scope Node' },
  { code: 'iam:scope:read', category: 'IAM Scope', label: 'Read Scope Tree' },
  { code: 'iam:scope:update', category: 'IAM Scope', label: 'Update Scope Node' },
  { code: 'iam:scope:move', category: 'IAM Scope', label: 'Move / Reparent Scope' },
  { code: 'iam:scope:delete', category: 'IAM Scope', label: 'Delete Scope Node' }
];
