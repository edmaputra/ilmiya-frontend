import '../models/iam.dart';
import 'api_client.dart';
import 'mock_storage_service.dart';

class IamService {
  final ApiClient _apiClient;
  final MockStorageService _mockStorage;

  UserProfileResponse? _cachedProfile;

  IamService({ApiClient? apiClient, MockStorageService? mockStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _mockStorage = mockStorage ?? MockStorageService();

  UserProfileResponse? get cachedProfile => _cachedProfile;

  // ================= Auth Endpoints =================

  Future<TokenResponse> login(LoginRequest req) async {
    final email = req.email.toLowerCase().trim();
    if (req.tenantId != null && req.tenantId!.isNotEmpty) {
      _apiClient.tenantId = req.tenantId!;
    }

    if (_apiClient.isMockMode) {
      final token = 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}';
      final refreshToken = 'mock-refresh-${DateTime.now().millisecondsSinceEpoch}';
      _apiClient.token = token;
      _apiClient.refreshToken = refreshToken;

      final mockUser = _mockStorage.getUserByEmail(email);
      List<String> roles = ['USER'];
      List<String> permissions = [];
      String fullName = mockUser?.fullName ?? 'Academic Staff Member';
      final userId = mockUser?.id ?? 'u-${DateTime.now().millisecondsSinceEpoch}';

      if (email.contains('admin.utama') || (mockUser?.isPlatformSuperAdmin ?? false)) {
        roles = ['SUPERADMIN'];
        permissions = ['*'];
        fullName = 'Dr. Sarah Jenkins (Head Administrator)';
      } else if (email.contains('principal')) {
        roles = ['SCHOOL_ADMIN'];
        permissions = _mockStorage.listRoles(_apiClient.tenantId).firstWhere(
          (r) => r.code == 'SCHOOL_ADMIN',
          orElse: () => _mockStorage.listRoles(_apiClient.tenantId).first,
        ).permissions;
        fullName = 'Prof. Marcus Chen (School Principal)';
      } else if (email.contains('eleanor.vance') || email.contains('teacher')) {
        roles = ['TEACHER'];
        permissions = _mockStorage.listRoles(_apiClient.tenantId).firstWhere(
          (r) => r.code == 'TEACHER',
          orElse: () => _mockStorage.listRoles(_apiClient.tenantId).first,
        ).permissions;
        fullName = 'Dr. Eleanor Vance (Computer Science Faculty)';
      } else if (email.contains('student') || email.contains('alex.rivera')) {
        roles = ['STUDENT'];
        permissions = _mockStorage.listRoles(_apiClient.tenantId).firstWhere(
          (r) => r.code == 'STUDENT',
          orElse: () => _mockStorage.listRoles(_apiClient.tenantId).first,
        ).permissions;
        fullName = 'Alex Rivera (Class 10-A)';
      } else if (email.contains('parent') || email.contains('elena.rivera')) {
        roles = ['PARENT'];
        permissions = ['student:profile:read', 'attendance:record:read', 'exam:grade:read'];
        fullName = 'Elena Rivera (Parent / Guardian)';
      } else {
        roles = ['USER'];
        permissions = ['school:profile:read', 'academic:year:read'];
      }

      _cachedProfile = UserProfileResponse(
        id: userId,
        email: email.isNotEmpty ? email : 'user@ilmiya.edu',
        fullName: fullName,
        tenantId: _apiClient.tenantId,
        roles: roles,
        permissions: permissions,
        scopes: ['/CAMPUS_MAIN'],
      );

      return TokenResponse(
        accessToken: token,
        refreshToken: refreshToken,
        tokenType: 'Bearer',
        expiresIn: 3600,
        tenantId: _apiClient.tenantId,
        roles: roles,
        permissions: permissions,
      );
    }

    final json = await _apiClient.request(
      endpoint: '/api/v1/auth/login',
      method: 'POST',
      body: req.toJson(),
    );
    final resp = TokenResponse.fromJson(json as Map<String, dynamic>);
    _apiClient.token = resp.accessToken;
    if (resp.refreshToken.isNotEmpty) {
      _apiClient.refreshToken = resp.refreshToken;
    }
    if (resp.tenantId.isNotEmpty) {
      _apiClient.tenantId = resp.tenantId;
    }
    try {
      await getMe();
    } catch (_) {}
    return resp;
  }

  Future<UserProfileResponse> getMe() async {
    if (_apiClient.isMockMode) {
      if (_cachedProfile != null) {
        return _cachedProfile!.copyWith(tenantId: _apiClient.tenantId);
      }
      return UserProfileResponse(
        id: 'u-11111111-1111-1111-1111-111111111111',
        email: 'admin.utama@ilmiya.edu',
        fullName: 'Dr. Sarah Jenkins (Head Administrator)',
        tenantId: _apiClient.tenantId,
        roles: ['SUPERADMIN'],
        permissions: ['*'],
        scopes: ['/CAMPUS_MAIN'],
      );
    }

    if (_apiClient.token == null) {
      throw ApiException(401, 'No active authentication session in Live mode.');
    }

    final json = await _apiClient.request(
      endpoint: '/api/v1/auth/me',
      method: 'GET',
    );
    _cachedProfile = UserProfileResponse.fromJson(json as Map<String, dynamic>);
    return _cachedProfile!;
  }

  void logout() {
    _apiClient.token = null;
    _apiClient.refreshToken = null;
    _cachedProfile = null;
  }

  Future<TokenResponse> switchTenant(String targetTenantId) async {
    _apiClient.tenantId = targetTenantId;
    if (_cachedProfile != null) {
      _cachedProfile = _cachedProfile!.copyWith(tenantId: targetTenantId);
    }

    if (_apiClient.isMockMode) {
      final token = 'mock-jwt-switched-${DateTime.now().millisecondsSinceEpoch}';
      final refreshToken = 'mock-refresh-${DateTime.now().millisecondsSinceEpoch}';
      _apiClient.token = token;
      _apiClient.refreshToken = refreshToken;
      return TokenResponse(
        accessToken: token,
        refreshToken: refreshToken,
        tokenType: 'Bearer',
        expiresIn: 3600,
        tenantId: targetTenantId,
        roles: ['SUPERADMIN'],
        permissions: ['*'],
      );
    }

    final json = await _apiClient.request(
      endpoint: '/api/v1/auth/switch-tenant',
      method: 'POST',
      headers: {'X-Tenant-ID': targetTenantId},
      body: {'tenantId': targetTenantId},
    );
    final resp = TokenResponse.fromJson(json as Map<String, dynamic>);
    _apiClient.token = resp.accessToken;
    if (resp.refreshToken.isNotEmpty) {
      _apiClient.refreshToken = resp.refreshToken;
    }
    return resp;
  }

  // ================= User Management Endpoints =================

  Future<List<UserResponse>> listUsers() async {
    if (_apiClient.isMockMode) {
      return _mockStorage.listUsers();
    }
    final json = await _apiClient.request(endpoint: '/api/v1/users', method: 'GET');
    return (json as List<dynamic>)
        .map((u) => UserResponse.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  Future<UserResponse> createUser(CreateUserRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.createUser(req);
    }
    final json = await _apiClient.request(
      endpoint: '/api/v1/users',
      method: 'POST',
      body: req.toJson(),
    );
    return UserResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<UserResponse> updateUser(String id, String fullName) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.updateUser(id, fullName);
    }
    final json = await _apiClient.request(
      endpoint: '/api/v1/users/$id',
      method: 'PUT',
      body: {'fullName': fullName},
    );
    return UserResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<UserResponse> changeUserStatus(String id, String status) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.changeUserStatus(id, status);
    }
    final json = await _apiClient.request(
      endpoint: '/api/v1/users/$id/status',
      method: 'PATCH',
      body: {'status': status},
    );
    return UserResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteUser(String id) async {
    if (_apiClient.isMockMode) {
      _mockStorage.deleteUser(id);
      return;
    }
    await _apiClient.request(endpoint: '/api/v1/users/$id', method: 'DELETE');
  }

  Future<UserRoleAssignmentResponse> assignRole({
    required String userId,
    required String roleId,
    required String tenantId,
    String? scopeNodeId,
  }) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.assignUserRole(
        userId: userId,
        roleId: roleId,
        tenantId: tenantId,
        scopeNodeId: scopeNodeId,
      );
    }
    final json = await _apiClient.request(
      endpoint: '/api/v1/users/$userId/roles',
      method: 'POST',
      body: {
        'roleId': roleId,
        'tenantId': tenantId,
        if (scopeNodeId != null) 'scopeNodeId': scopeNodeId,
      },
    );
    return UserRoleAssignmentResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<List<UserRoleAssignmentResponse>> getUserRoles(String userId) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.getUserRoles(userId);
    }
    final json = await _apiClient.request(
      endpoint: '/api/v1/users/$userId/roles',
      method: 'GET',
    );
    return (json as List<dynamic>)
        .map((r) => UserRoleAssignmentResponse.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> revokeRole(String userId, String assignmentId) async {
    if (_apiClient.isMockMode) {
      _mockStorage.revokeUserRole(assignmentId);
      return;
    }
    await _apiClient.request(
      endpoint: '/api/v1/users/$userId/roles/$assignmentId',
      method: 'DELETE',
    );
  }

  // ================= Roles Endpoints =================

  Future<List<RoleResponse>> listRoles() async {
    if (_apiClient.isMockMode) {
      return _mockStorage.listRoles(_apiClient.tenantId);
    }
    final json = await _apiClient.request(endpoint: '/api/v1/roles', method: 'GET');
    return (json as List<dynamic>)
        .map((r) => RoleResponse.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<RoleResponse> createRole(CreateRoleRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.createRole(_apiClient.tenantId, req);
    }
    final json = await _apiClient.request(
      endpoint: '/api/v1/roles',
      method: 'POST',
      body: req.toJson(),
    );
    return RoleResponse.fromJson(json as Map<String, dynamic>);
  }

  // ================= Groups Endpoints =================

  Future<List<GroupResponse>> listGroups() async {
    if (_apiClient.isMockMode) {
      return _mockStorage.listGroups(_apiClient.tenantId);
    }
    final json = await _apiClient.request(endpoint: '/api/v1/groups', method: 'GET');
    return (json as List<dynamic>)
        .map((g) => GroupResponse.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  Future<GroupResponse> createGroup(CreateGroupRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.createGroup(_apiClient.tenantId, req);
    }
    final json = await _apiClient.request(
      endpoint: '/api/v1/groups',
      method: 'POST',
      body: req.toJson(),
    );
    return GroupResponse.fromJson(json as Map<String, dynamic>);
  }

  // ================= Scopes Endpoints =================

  Future<List<ScopeTreeNode>> getScopeTree() async {
    if (_apiClient.isMockMode) {
      return _mockStorage.getScopeTree(_apiClient.tenantId);
    }
    final json = await _apiClient.request(endpoint: '/api/v1/scopes/tree', method: 'GET');
    return (json as List<dynamic>)
        .map((s) => ScopeTreeNode.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<ScopeTreeNode> createScope(CreateScopeRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.createScope(_apiClient.tenantId, req);
    }
    final json = await _apiClient.request(
      endpoint: '/api/v1/scopes',
      method: 'POST',
      body: req.toJson(),
    );
    return ScopeTreeNode.fromJson(json as Map<String, dynamic>);
  }
}

final iamService = IamService();
