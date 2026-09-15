import React, { useState, useEffect } from 'react';
import { 
  Users, 
  Shield, 
  Layers, 
  FolderTree, 
  PlusCircle, 
  Trash2, 
  Edit3, 
  UserCheck, 
  UserX, 
  Key, 
  FolderPlus, 
  ChevronDown, 
  ChevronRight, 
  Search,
  CheckCircle2,
  Lock,
  Tag
} from 'lucide-react';
import { 
  UserResponse, 
  RoleResponse, 
  GroupResponse, 
  ScopeTreeNode, 
  UserStatus,
  AVAILABLE_PERMISSIONS
} from '../types/iam';
import { iamService } from '../services/iamService';
import { useAuth } from '../context/AuthContext';

interface IamManagementViewProps {
  currentTenantId: string;
  onNotification: (title: string, message: string, category: 'announcement' | 'emergency') => void;
}

type IamTab = 'users' | 'roles' | 'groups' | 'scopes';

export const IamManagementView: React.FC<IamManagementViewProps> = ({
  currentTenantId,
  onNotification
}) => {
  const { hasPermission } = useAuth();
  const canCreateUser = hasPermission('iam:user:create');
  const canUpdateUserStatus = hasPermission('iam:user:status');
  const canAssignRole = hasPermission('iam:user:assign-role');
  const canDeleteUser = hasPermission('iam:user:delete');
  const canCreateRole = hasPermission('iam:role:create');
  const canCreateGroup = hasPermission('iam:group:create');
  const canCreateScope = hasPermission('iam:scope:create');

  const [activeTab, setActiveTab] = useState<IamTab>('users');
  const [users, setUsers] = useState<UserResponse[]>([]);
  const [roles, setRoles] = useState<RoleResponse[]>([]);
  const [groups, setGroups] = useState<GroupResponse[]>([]);
  const [scopeTree, setScopeTree] = useState<ScopeTreeNode[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Search filter
  const [searchQuery, setSearchQuery] = useState('');

  // Modals state
  const [showCreateUserModal, setShowCreateUserModal] = useState(false);
  const [showAssignRoleModal, setShowAssignRoleModal] = useState(false);
  const [showCreateRoleModal, setShowCreateRoleModal] = useState(false);
  const [showCreateGroupModal, setShowCreateGroupModal] = useState(false);
  const [showCreateScopeModal, setShowCreateScopeModal] = useState(false);

  // Form states
  const [selectedUser, setSelectedUser] = useState<UserResponse | null>(null);
  const [newEmail, setNewEmail] = useState('');
  const [newFullName, setNewFullName] = useState('');
  const [newIsSuperAdmin, setNewIsSuperAdmin] = useState(false);

  // Role Assignment
  const [selectedRoleId, setSelectedRoleId] = useState('');
  const [selectedScopeNodeId, setSelectedScopeNodeId] = useState('');

  // Role Creation
  const [newRoleCode, setNewRoleCode] = useState('');
  const [newRoleName, setNewRoleName] = useState('');
  const [newRoleDesc, setNewRoleDesc] = useState('');
  const [selectedPermissions, setSelectedPermissions] = useState<string[]>([]);

  // Group Creation
  const [newGroupCode, setNewGroupCode] = useState('');
  const [newGroupName, setNewGroupName] = useState('');
  const [newGroupDesc, setNewGroupDesc] = useState('');
  const [newGroupIdpName, setNewGroupIdpName] = useState('');

  // Scope Creation
  const [parentScopeId, setParentScopeId] = useState<string | null>(null);
  const [newScopeCode, setNewScopeCode] = useState('');
  const [newScopeName, setNewScopeName] = useState('');

  const loadAllIamData = async () => {
    setIsLoading(true);
    try {
      const [uList, rList, gList, sTree] = await Promise.all([
        iamService.listUsers(),
        iamService.listRoles(),
        iamService.listGroups(),
        iamService.getScopeTree()
      ]);
      setUsers(uList);
      setRoles(rList);
      setGroups(gList);
      setScopeTree(sTree);
      if (rList.length > 0 && !selectedRoleId) {
        setSelectedRoleId(rList[0].id);
      }
    } catch (err) {
      console.error('Error loading IAM data:', err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadAllIamData();
  }, [currentTenantId]);

  // User Actions
  const handleCreateUser = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const user = await iamService.createUser({
        email: newEmail,
        fullName: newFullName,
        isPlatformSuperAdmin: newIsSuperAdmin
      });
      setShowCreateUserModal(false);
      setNewEmail('');
      setNewFullName('');
      setNewIsSuperAdmin(false);
      await loadAllIamData();
      onNotification('User Created', `Identity account created for ${user.fullName}.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error creating user');
    }
  };

  const handleChangeStatus = async (userId: string, newStatus: UserStatus) => {
    try {
      await iamService.changeUserStatus(userId, { status: newStatus });
      await loadAllIamData();
      onNotification('Status Updated', `User status transitioned to ${newStatus}.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error changing status');
    }
  };

  const handleDeleteUser = async (userId: string, name: string) => {
    if (!confirm(`Are you sure you want to delete account for ${name}?`)) return;
    try {
      await iamService.deleteUser(userId);
      await loadAllIamData();
      onNotification('User Deleted', `Account ${name} removed.`, 'emergency');
    } catch (err: any) {
      alert(err.message || 'Error deleting user');
    }
  };

  const handleOpenAssignRole = (user: UserResponse) => {
    setSelectedUser(user);
    setSelectedRoleId(roles[0]?.id || '');
    setSelectedScopeNodeId('');
    setShowAssignRoleModal(true);
  };

  const handleAssignRoleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedUser || !selectedRoleId) return;
    try {
      await iamService.assignRole(selectedUser.id, {
        roleId: selectedRoleId,
        tenantId: currentTenantId,
        scopeNodeId: selectedScopeNodeId.trim() ? selectedScopeNodeId.trim() : null
      });
      setShowAssignRoleModal(false);
      onNotification('Role Assigned', `Role assigned to ${selectedUser.fullName}.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error assigning role');
    }
  };

  // Role Actions
  const handleCreateRoleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const role = await iamService.createRole({
        code: newRoleCode,
        name: newRoleName,
        description: newRoleDesc,
        permissions: selectedPermissions,
        tenantId: currentTenantId
      });
      setShowCreateRoleModal(false);
      setNewRoleCode('');
      setNewRoleName('');
      setNewRoleDesc('');
      setSelectedPermissions([]);
      await loadAllIamData();
      onNotification('Role Created', `Custom role "${role.name}" configured with ${role.permissions.length} permissions.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error creating role');
    }
  };

  const togglePermission = (permCode: string) => {
    setSelectedPermissions(prev =>
      prev.includes(permCode) ? prev.filter(p => p !== permCode) : [...prev, permCode]
    );
  };

  // Group Actions
  const handleCreateGroupSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const group = await iamService.createGroup({
        code: newGroupCode,
        name: newGroupName,
        description: newGroupDesc,
        externalIdpGroupName: newGroupIdpName.trim() ? newGroupIdpName.trim() : null,
        tenantId: currentTenantId
      });
      setShowCreateGroupModal(false);
      setNewGroupCode('');
      setNewGroupName('');
      setNewGroupDesc('');
      setNewGroupIdpName('');
      await loadAllIamData();
      onNotification('Group Created', `User group "${group.name}" created.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error creating group');
    }
  };

  // Scope Actions
  const handleCreateScopeSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const scope = await iamService.createScope({
        code: newScopeCode,
        name: newScopeName,
        parentId: parentScopeId,
        tenantId: currentTenantId
      });
      setShowCreateScopeModal(false);
      setNewScopeCode('');
      setNewScopeName('');
      setParentScopeId(null);
      await loadAllIamData();
      onNotification('Scope Added', `Scope node "${scope.name}" created under hierarchy.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error creating scope');
    }
  };

  const handleDeleteScope = async (id: string, name: string) => {
    if (!confirm(`Delete scope node "${name}" and its sub-hierarchy?`)) return;
    try {
      await iamService.deleteScope(id);
      await loadAllIamData();
      onNotification('Scope Deleted', `Scope "${name}" removed.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error deleting scope');
    }
  };

  const filteredUsers = users.filter(u =>
    u.fullName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    u.email.toLowerCase().includes(searchQuery.toLowerCase())
  );

  // Group permissions by category
  const permissionCategories = Array.from(new Set(AVAILABLE_PERMISSIONS.map(p => p.category)));

  // Recursive Tree Node Renderer
  const renderScopeNode = (node: ScopeTreeNode, depth = 0) => {
    return (
      <div key={node.id} className="space-y-1">
        <div 
          className={`flex items-center justify-between p-2.5 rounded-xl border transition-all ${
            depth === 0 ? 'bg-[#FAF9F6] border-[#D9D1C5]' : 'bg-white border-[#E9E4DB]'
          }`}
          style={{ marginLeft: `${depth * 20}px` }}
        >
          <div className="flex items-center gap-2">
            <FolderTree className={`w-4 h-4 ${depth === 0 ? 'text-[#5F6F52]' : 'text-[#8C887D]'}`} />
            <span className="text-xs font-bold font-serif text-[#2C2E2A]">{node.name}</span>
            <code className="text-[10px] font-mono bg-[#FAF9F6] px-1.5 py-0.5 rounded border border-[#E9E4DB] text-[#6B6E68]">
              {node.code}
            </code>
            <span className="text-[10px] text-[#8C887D] font-mono hidden md:inline">
              {node.path}
            </span>
          </div>

          <div className="flex items-center gap-1.5">
            <button
              onClick={() => {
                setParentScopeId(node.id);
                setShowCreateScopeModal(true);
              }}
              disabled={!canCreateScope}
              title={!canCreateScope ? "Requires permission: iam:scope:create" : "Add child scope under this node"}
              className={`p-1 text-[11px] font-semibold rounded-lg border flex items-center gap-1 ${
                canCreateScope
                  ? 'text-[#5F6F52] hover:bg-[#FEFAE0] border-[#D9D1C5] cursor-pointer'
                  : 'text-gray-400 bg-gray-50 border-gray-200 opacity-60 cursor-not-allowed'
              }`}
            >
              {canCreateScope ? <FolderPlus className="w-3 h-3" /> : <Lock className="w-3 h-3" />}
              <span className="hidden sm:inline">Add Child</span>
            </button>
            {depth > 0 && (
              <button
                onClick={() => handleDeleteScope(node.id, node.name)}
                className="p-1 text-red-600 hover:bg-red-50 rounded-lg cursor-pointer"
                title="Delete node"
              >
                <Trash2 className="w-3.5 h-3.5" />
              </button>
            )}
          </div>
        </div>

        {node.children && node.children.map(child => renderScopeNode(child, depth + 1))}
      </div>
    );
  };

  return (
    <div className="space-y-6">
      
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-serif font-bold text-[#2C2E2A]">IAM & Access Management</h1>
            <span className="text-xs uppercase tracking-wider font-semibold px-2.5 py-0.5 rounded-full bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
              ed-iam Foundation
            </span>
          </div>
          <p className="text-xs text-[#6B6E68] mt-1">
            Manage institutional users, role-based access controls (RBAC), user groups, and hierarchical scopes.
          </p>
        </div>

        {/* Tab switchers */}
        <div className="flex items-center gap-1 bg-[#E9E4DB] p-1.5 rounded-2xl border border-[#D9D1C5]">
          <button
            onClick={() => setActiveTab('users')}
            className={`flex items-center gap-1.5 px-3 py-1 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
              activeTab === 'users'
                ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-sm'
                : 'text-[#6B6E68] hover:text-[#2C2E2A]'
            }`}
          >
            <Users className="w-3.5 h-3.5" />
            <span>Users ({users.length})</span>
          </button>

          <button
            onClick={() => setActiveTab('roles')}
            className={`flex items-center gap-1.5 px-3 py-1 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
              activeTab === 'roles'
                ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-sm'
                : 'text-[#6B6E68] hover:text-[#2C2E2A]'
            }`}
          >
            <Shield className="w-3.5 h-3.5" />
            <span>Roles ({roles.length})</span>
          </button>

          <button
            onClick={() => setActiveTab('groups')}
            className={`flex items-center gap-1.5 px-3 py-1 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
              activeTab === 'groups'
                ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-sm'
                : 'text-[#6B6E68] hover:text-[#2C2E2A]'
            }`}
          >
            <Layers className="w-3.5 h-3.5" />
            <span>Groups ({groups.length})</span>
          </button>

          <button
            onClick={() => setActiveTab('scopes')}
            className={`flex items-center gap-1.5 px-3 py-1 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
              activeTab === 'scopes'
                ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-sm'
                : 'text-[#6B6E68] hover:text-[#2C2E2A]'
            }`}
          >
            <FolderTree className="w-3.5 h-3.5" />
            <span>Scope Tree</span>
          </button>
        </div>
      </div>

      {/* TAB 1: USERS */}
      {activeTab === 'users' && (
        <div className="bg-white rounded-[24px] border border-[#D9D1C5] p-6 shadow-sm space-y-4">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div className="relative flex-1 max-w-sm">
              <Search className="w-4 h-4 text-[#8C887D] absolute left-3 top-2.5" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search user by name or email..."
                className="w-full pl-9 pr-3 py-1.5 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6] focus:outline-none focus:border-[#5F6F52]"
              />
            </div>

            <button
              onClick={() => setShowCreateUserModal(true)}
              disabled={!canCreateUser}
              title={!canCreateUser ? "Requires permission: iam:user:create" : "Create new user"}
              className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
                canCreateUser
                  ? 'bg-[#5F6F52] text-white hover:bg-[#4E5C43] cursor-pointer'
                  : 'bg-gray-200 text-gray-500 opacity-60 cursor-not-allowed'
              }`}
            >
              {canCreateUser ? <PlusCircle className="w-3.5 h-3.5" /> : <Lock className="w-3.5 h-3.5" />}
              <span>Create User</span>
            </button>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead>
                <tr className="border-b border-[#E9E4DB] text-[#8C887D] font-semibold">
                  <th className="pb-3">User & Email</th>
                  <th className="pb-3">Status</th>
                  <th className="pb-3">Platform SuperAdmin</th>
                  <th className="pb-3">Created</th>
                  <th className="pb-3 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#E9E4DB]/60">
                {filteredUsers.map((user) => (
                  <tr key={user.id} className="hover:bg-[#FAF9F6] transition-colors">
                    <td className="py-3">
                      <div className="font-semibold text-[#2C2E2A]">{user.fullName}</div>
                      <div className="text-[11px] text-[#6B6E68]">{user.email}</div>
                    </td>
                    <td className="py-3">
                      <select
                        value={user.status}
                        onChange={(e) => handleChangeStatus(user.id, e.target.value as UserStatus)}
                        disabled={!canUpdateUserStatus}
                        title={!canUpdateUserStatus ? "Requires permission: iam:user:status" : "Change user status"}
                        className={`text-[10px] font-bold uppercase px-2 py-1 rounded-lg border ${
                          !canUpdateUserStatus ? 'opacity-50 cursor-not-allowed ' : 'cursor-pointer '
                        }${
                          user.status === 'ACTIVE'
                            ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
                            : 'bg-amber-50 text-amber-800 border-amber-200'
                        }`}
                      >
                        <option value="ACTIVE">ACTIVE</option>
                        <option value="SUSPENDED">SUSPENDED</option>
                        <option value="PENDING_ACTIVATION">PENDING</option>
                        <option value="DEACTIVATED">DEACTIVATED</option>
                      </select>
                    </td>
                    <td className="py-3">
                      {user.isPlatformSuperAdmin ? (
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-purple-100 text-purple-800">
                          SUPERADMIN
                        </span>
                      ) : (
                        <span className="text-[#8C887D] text-[11px]">Regular</span>
                      )}
                    </td>
                    <td className="py-3 text-[#6B6E68] text-[11px]">
                      {new Date(user.createdAt).toLocaleDateString()}
                    </td>
                    <td className="py-3 text-right space-x-1">
                      <button
                        onClick={() => handleOpenAssignRole(user)}
                        disabled={!canAssignRole}
                        title={!canAssignRole ? "Requires permission: iam:user:assign-role" : "Assign role"}
                        className={`px-2.5 py-1 text-[11px] rounded-lg border font-semibold ${
                          canAssignRole
                            ? 'border-[#D9D1C5] text-[#5F6F52] hover:bg-[#FEFAE0] cursor-pointer'
                            : 'border-gray-200 text-gray-400 bg-gray-50 opacity-60 cursor-not-allowed'
                        }`}
                      >
                        Assign Role
                      </button>
                      <button
                        onClick={() => handleDeleteUser(user.id, user.fullName)}
                        disabled={!canDeleteUser}
                        title={!canDeleteUser ? "Requires permission: iam:user:delete" : "Delete User"}
                        className={`p-1 rounded-lg ${
                          canDeleteUser
                            ? 'text-red-600 hover:bg-red-50 cursor-pointer'
                            : 'text-gray-300 cursor-not-allowed opacity-40'
                        }`}
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 2: ROLES */}
      {activeTab === 'roles' && (
        <div className="bg-white rounded-[24px] border border-[#D9D1C5] p-6 shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Role-Based Access Control (RBAC)</h3>
            <button
              onClick={() => setShowCreateRoleModal(true)}
              disabled={!canCreateRole}
              title={!canCreateRole ? "Requires permission: iam:role:create" : "Create custom role"}
              className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
                canCreateRole
                  ? 'bg-[#5F6F52] text-white hover:bg-[#4E5C43] cursor-pointer'
                  : 'bg-gray-200 text-gray-500 opacity-60 cursor-not-allowed'
              }`}
            >
              {canCreateRole ? <PlusCircle className="w-3.5 h-3.5" /> : <Lock className="w-3.5 h-3.5" />}
              <span>Create Custom Role</span>
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {roles.map((role) => (
              <div
                key={role.id}
                className="p-4 rounded-2xl border border-[#E9E4DB] hover:border-[#D9D1C5] bg-[#FAF9F6]/50 space-y-3"
              >
                <div className="flex items-start justify-between gap-2">
                  <div>
                    <div className="flex items-center gap-2">
                      <Shield className="w-4 h-4 text-[#5F6F52]" />
                      <h4 className="text-xs font-bold font-serif text-[#2C2E2A]">{role.name}</h4>
                    </div>
                    <code className="text-[10px] font-mono text-[#8C887D]">{role.code}</code>
                  </div>

                  {role.isSystemRole && (
                    <span className="text-[9px] font-bold uppercase px-2 py-0.5 rounded bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
                      System Role
                    </span>
                  )}
                </div>

                {role.description && (
                  <p className="text-[11px] text-[#6B6E68] line-clamp-2 leading-relaxed">
                    {role.description}
                  </p>
                )}

                <div>
                  <span className="text-[10px] font-bold text-[#8C887D] uppercase tracking-wider block mb-1">
                    Permissions ({role.permissions.length})
                  </span>
                  <div className="flex flex-wrap gap-1 max-h-24 overflow-y-auto pr-1">
                    {role.permissions.map((perm) => (
                      <span
                        key={perm}
                        className="text-[9px] font-mono px-1.5 py-0.5 rounded bg-white border border-[#E9E4DB] text-[#2C2E2A]"
                      >
                        {perm}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* TAB 3: GROUPS */}
      {activeTab === 'groups' && (
        <div className="bg-white rounded-[24px] border border-[#D9D1C5] p-6 shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-base font-serif font-bold text-[#2C2E2A]">User Groups & Directory</h3>
            <button
              onClick={() => setShowCreateGroupModal(true)}
              disabled={!canCreateGroup}
              title={!canCreateGroup ? "Requires permission: iam:group:create" : "Create user group"}
              className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
                canCreateGroup
                  ? 'bg-[#5F6F52] text-white hover:bg-[#4E5C43] cursor-pointer'
                  : 'bg-gray-200 text-gray-500 opacity-60 cursor-not-allowed'
              }`}
            >
              {canCreateGroup ? <PlusCircle className="w-3.5 h-3.5" /> : <Lock className="w-3.5 h-3.5" />}
              <span>Create Group</span>
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {groups.map((group) => (
              <div
                key={group.id}
                className="p-4 rounded-2xl border border-[#E9E4DB] hover:border-[#D9D1C5] bg-[#FAF9F6]/50 space-y-2"
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Layers className="w-4 h-4 text-[#5F6F52]" />
                    <h4 className="text-xs font-bold font-serif text-[#2C2E2A]">{group.name}</h4>
                  </div>
                  <code className="text-[10px] font-mono bg-white px-2 py-0.5 rounded border border-[#E9E4DB]">
                    {group.code}
                  </code>
                </div>

                <p className="text-xs text-[#6B6E68]">{group.description || 'No description provided.'}</p>

                {group.externalIdpGroupName && (
                  <div className="text-[11px] text-[#8C887D]">
                    <span>IdP Mapping: </span>
                    <code className="text-[#5F6F52]">{group.externalIdpGroupName}</code>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* TAB 4: SCOPE TREE */}
      {activeTab === 'scopes' && (
        <div className="bg-white rounded-[24px] border border-[#D9D1C5] p-6 shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Hierarchical Scope Tree</h3>
              <p className="text-xs text-[#6B6E68] mt-0.5">
                Multi-level organizational scopes for delegating permissions (e.g. Campus → Division → Department → Class).
              </p>
            </div>

            <button
              onClick={() => {
                setParentScopeId(null);
                setShowCreateScopeModal(true);
              }}
              disabled={!canCreateScope}
              title={!canCreateScope ? "Requires permission: iam:scope:create" : "Create root scope node"}
              className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-colors ${
                canCreateScope
                  ? 'bg-[#5F6F52] text-white hover:bg-[#4E5C43] cursor-pointer'
                  : 'bg-gray-200 text-gray-500 opacity-60 cursor-not-allowed'
              }`}
            >
              {canCreateScope ? <PlusCircle className="w-3.5 h-3.5" /> : <Lock className="w-3.5 h-3.5" />}
              <span>Create Root Scope</span>
            </button>
          </div>

          <div className="space-y-2 pt-2">
            {scopeTree.map(rootNode => renderScopeNode(rootNode))}
          </div>
        </div>
      )}

      {/* MODAL: Create User */}
      {showCreateUserModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-md w-full p-6 shadow-2xl">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Create New User Account</h3>
              <button onClick={() => setShowCreateUserModal(false)} className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer">✕</button>
            </div>

            <form onSubmit={handleCreateUser} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Full Name</label>
                <input
                  type="text"
                  value={newFullName}
                  onChange={(e) => setNewFullName(e.target.value)}
                  placeholder="e.g. Siti Rahmawati"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Email Address</label>
                <input
                  type="email"
                  value={newEmail}
                  onChange={(e) => setNewEmail(e.target.value)}
                  placeholder="name@school.edu"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div className="pt-2 flex items-center gap-2">
                <input
                  type="checkbox"
                  id="superadminCheck"
                  checked={newIsSuperAdmin}
                  onChange={(e) => setNewIsSuperAdmin(e.target.checked)}
                  className="rounded text-[#5F6F52]"
                />
                <label htmlFor="superadminCheck" className="text-xs text-[#2C2E2A] font-medium">
                  Grant Platform SuperAdmin Privileges
                </label>
              </div>

              <div className="pt-4 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowCreateUserModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43]"
                >
                  Create Account
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL: Assign Role */}
      {showAssignRoleModal && selectedUser && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-md w-full p-6 shadow-2xl">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Assign Role to User</h3>
              <button onClick={() => setShowAssignRoleModal(false)} className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer">✕</button>
            </div>

            <p className="text-xs text-[#6B6E68] mb-3">
              Assigning RBAC role to <strong className="text-[#2C2E2A]">{selectedUser.fullName}</strong> for tenant <code className="bg-[#FAF9F6] px-1 py-0.5 rounded border border-[#E9E4DB]">{currentTenantId}</code>.
            </p>

            <form onSubmit={handleAssignRoleSubmit} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Select Role</label>
                <select
                  value={selectedRoleId}
                  onChange={(e) => setSelectedRoleId(e.target.value)}
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                >
                  {roles.map(r => (
                    <option key={r.id} value={r.id}>{r.name} ({r.code})</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Scope Node ID (Optional)</label>
                <input
                  type="text"
                  value={selectedScopeNodeId}
                  onChange={(e) => setSelectedScopeNodeId(e.target.value)}
                  placeholder="Leave empty for whole tenant, or e.g. scope-dept-cs"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                />
              </div>

              <div className="pt-4 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowAssignRoleModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43]"
                >
                  Assign Role
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL: Create Role */}
      {showCreateRoleModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-xl w-full p-6 shadow-2xl max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Create Custom Role</h3>
              <button onClick={() => setShowCreateRoleModal(false)} className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer">✕</button>
            </div>

            <form onSubmit={handleCreateRoleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Role Code</label>
                  <input
                    type="text"
                    value={newRoleCode}
                    onChange={(e) => setNewRoleCode(e.target.value)}
                    placeholder="e.g. CURRICULUM_LEAD"
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                    required
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Role Name</label>
                  <input
                    type="text"
                    value={newRoleName}
                    onChange={(e) => setNewRoleName(e.target.value)}
                    placeholder="e.g. Curriculum Coordinator"
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Description</label>
                <textarea
                  value={newRoleDesc}
                  onChange={(e) => setNewRoleDesc(e.target.value)}
                  rows={2}
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-2">
                  Select Fine-Grained Permissions ({selectedPermissions.length} selected)
                </label>
                
                <div className="space-y-3 max-h-60 overflow-y-auto p-3 bg-[#FAF9F6] rounded-xl border border-[#E9E4DB]">
                  {permissionCategories.map(cat => (
                    <div key={cat} className="space-y-1.5">
                      <span className="text-[11px] font-bold text-[#5F6F52] uppercase tracking-wider block">
                        {cat}
                      </span>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-1.5">
                        {AVAILABLE_PERMISSIONS.filter(p => p.category === cat).map(p => {
                          const checked = selectedPermissions.includes(p.code);
                          return (
                            <label
                              key={p.code}
                              className={`flex items-center gap-2 p-1.5 rounded-lg border text-xs cursor-pointer transition-all ${
                                checked
                                  ? 'bg-[#FEFAE0] border-[#5F6F52] text-[#2C2E2A]'
                                  : 'bg-white border-[#E9E4DB] text-[#6B6E68]'
                              }`}
                            >
                              <input
                                type="checkbox"
                                checked={checked}
                                onChange={() => togglePermission(p.code)}
                                className="rounded text-[#5F6F52]"
                              />
                              <span className="truncate">{p.label}</span>
                            </label>
                          );
                        })}
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="pt-4 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowCreateRoleModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43]"
                >
                  Create Role
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL: Create Group */}
      {showCreateGroupModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-md w-full p-6 shadow-2xl">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Create User Group</h3>
              <button onClick={() => setShowCreateGroupModal(false)} className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer">✕</button>
            </div>

            <form onSubmit={handleCreateGroupSubmit} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Group Code</label>
                <input
                  type="text"
                  value={newGroupCode}
                  onChange={(e) => setNewGroupCode(e.target.value)}
                  placeholder="e.g. GRP_MATH_DEPT"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Group Name</label>
                <input
                  type="text"
                  value={newGroupName}
                  onChange={(e) => setNewGroupName(e.target.value)}
                  placeholder="e.g. Mathematics Faculty"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Description</label>
                <textarea
                  value={newGroupDesc}
                  onChange={(e) => setNewGroupDesc(e.target.value)}
                  rows={2}
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">IdP Group Name (Optional)</label>
                <input
                  type="text"
                  value={newGroupIdpName}
                  onChange={(e) => setNewGroupIdpName(e.target.value)}
                  placeholder="e.g. okta_math_teachers"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                />
              </div>

              <div className="pt-4 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowCreateGroupModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43]"
                >
                  Create Group
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL: Create Scope */}
      {showCreateScopeModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-md w-full p-6 shadow-2xl">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-serif font-bold text-[#2C2E2A]">
                {parentScopeId ? 'Create Child Scope Node' : 'Create Root Scope Node'}
              </h3>
              <button onClick={() => setShowCreateScopeModal(false)} className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer">✕</button>
            </div>

            <form onSubmit={handleCreateScopeSubmit} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Scope Code</label>
                <input
                  type="text"
                  value={newScopeCode}
                  onChange={(e) => setNewScopeCode(e.target.value)}
                  placeholder="e.g. CLASS_10B"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Scope Name</label>
                <input
                  type="text"
                  value={newScopeName}
                  onChange={(e) => setNewScopeName(e.target.value)}
                  placeholder="e.g. Class 10-B (Social Track)"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div className="pt-4 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowCreateScopeModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43]"
                >
                  Save Scope
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};
