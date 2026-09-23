class UserResponse {
  final String id;
  final String email;
  final String fullName;
  final String status;
  final bool isPlatformSuperAdmin;
  final String createdAt;
  final String updatedAt;

  UserResponse({
    required this.id,
    required this.email,
    required this.fullName,
    required this.status,
    required this.isPlatformSuperAdmin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      isPlatformSuperAdmin: json['isPlatformSuperAdmin'] as bool? ?? false,
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt:
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'status': status,
        'isPlatformSuperAdmin': isPlatformSuperAdmin,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  UserResponse copyWith({
    String? id,
    String? email,
    String? fullName,
    String? status,
    bool? isPlatformSuperAdmin,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserResponse(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      status: status ?? this.status,
      isPlatformSuperAdmin: isPlatformSuperAdmin ?? this.isPlatformSuperAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CreateUserRequest {
  final String email;
  final String fullName;
  final String? password;
  final bool? isPlatformSuperAdmin;

  CreateUserRequest({
    required this.email,
    required this.fullName,
    this.password,
    this.isPlatformSuperAdmin,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
        if (password != null) 'password': password,
        if (isPlatformSuperAdmin != null)
          'isPlatformSuperAdmin': isPlatformSuperAdmin,
      };
}

class UserRoleAssignmentResponse {
  final String id;
  final String userId;
  final String roleId;
  final String tenantId;
  final String? scopeNodeId;
  final String assignedAt;

  UserRoleAssignmentResponse({
    required this.id,
    required this.userId,
    required this.roleId,
    required this.tenantId,
    this.scopeNodeId,
    required this.assignedAt,
  });

  factory UserRoleAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return UserRoleAssignmentResponse(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      roleId: json['roleId'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      scopeNodeId: json['scopeNodeId'] as String?,
      assignedAt:
          json['assignedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'roleId': roleId,
        'tenantId': tenantId,
        if (scopeNodeId != null) 'scopeNodeId': scopeNodeId,
        'assignedAt': assignedAt,
      };
}

class RoleResponse {
  final String id;
  final String tenantId;
  final String code;
  final String name;
  final String? description;
  final List<String> permissions;
  final bool isSystemRole;
  final String createdAt;
  final String updatedAt;

  RoleResponse({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    this.description,
    required this.permissions,
    this.isSystemRole = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoleResponse.fromJson(Map<String, dynamic> json) {
    return RoleResponse(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isSystemRole: json['isSystemRole'] as bool? ?? false,
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt:
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'code': code,
        'name': name,
        if (description != null) 'description': description,
        'permissions': permissions,
        'isSystemRole': isSystemRole,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class CreateRoleRequest {
  final String code;
  final String name;
  final String? description;
  final List<String> permissions;

  CreateRoleRequest({
    required this.code,
    required this.name,
    this.description,
    required this.permissions,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        if (description != null) 'description': description,
        'permissions': permissions,
      };
}

class GroupResponse {
  final String id;
  final String tenantId;
  final String code;
  final String name;
  final String? description;
  final String? externalIdpGroupName;
  final String createdAt;
  final String updatedAt;

  GroupResponse({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    this.description,
    this.externalIdpGroupName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    return GroupResponse(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      externalIdpGroupName: json['externalIdpGroupName'] as String?,
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt:
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'code': code,
        'name': name,
        if (description != null) 'description': description,
        if (externalIdpGroupName != null)
          'externalIdpGroupName': externalIdpGroupName,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class CreateGroupRequest {
  final String code;
  final String name;
  final String? description;
  final String? externalIdpGroupName;

  CreateGroupRequest({
    required this.code,
    required this.name,
    this.description,
    this.externalIdpGroupName,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        if (description != null) 'description': description,
        if (externalIdpGroupName != null)
          'externalIdpGroupName': externalIdpGroupName,
      };
}

class ScopeTreeNode {
  final String id;
  final String code;
  final String name;
  final String path;
  final int depth;
  final String? parentId;
  final List<ScopeTreeNode> children;

  ScopeTreeNode({
    required this.id,
    required this.code,
    required this.name,
    required this.path,
    required this.depth,
    this.parentId,
    required this.children,
  });

  factory ScopeTreeNode.fromJson(Map<String, dynamic> json) {
    return ScopeTreeNode(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      depth: (json['depth'] as num?)?.toInt() ?? 0,
      parentId: json['parentId'] as String?,
      children: (json['children'] as List<dynamic>?)
              ?.map((c) => ScopeTreeNode.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'path': path,
        'depth': depth,
        if (parentId != null) 'parentId': parentId,
        'children': children.map((c) => c.toJson()).toList(),
      };
}

class CreateScopeRequest {
  final String code;
  final String name;
  final String? parentId;

  CreateScopeRequest({
    required this.code,
    required this.name,
    this.parentId,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        if (parentId != null) 'parentId': parentId,
      };
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String tenantId;
  final List<String> roles;
  final List<String> permissions;
  final UserProfileResponse? user;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 3600,
    required this.tenantId,
    required this.roles,
    required this.permissions,
    this.user,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;
    final parsedUser =
        userJson != null ? UserProfileResponse.fromJson(userJson) : null;

    final tenantId =
        json['tenantId'] as String? ?? userJson?['tenantId'] as String? ?? '';
    final roles =
        (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            (userJson?['roles'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
    final permissions = (json['permissions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (userJson?['permissions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return TokenResponse(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 3600,
      tenantId: tenantId,
      roles: roles,
      permissions: permissions,
      user: parsedUser,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'tokenType': tokenType,
        'expiresIn': expiresIn,
        'tenantId': tenantId,
        'roles': roles,
        'permissions': permissions,
        if (user != null) 'user': user!.toJson(),
      };
}

class UserProfileResponse {
  final String id;
  final String email;
  final String fullName;
  final String tenantId;
  final List<String> roles;
  final List<String> permissions;
  final List<String> scopes;

  UserProfileResponse({
    required this.id,
    required this.email,
    required this.fullName,
    required this.tenantId,
    required this.roles,
    required this.permissions,
    required this.scopes,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    final scopesList =
        (json['scopes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            (json['accessibleScopePaths'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

    return UserProfileResponse(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      scopes: scopesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'tenantId': tenantId,
        'roles': roles,
        'permissions': permissions,
        'scopes': scopes,
      };

  UserProfileResponse copyWith({
    String? id,
    String? email,
    String? fullName,
    String? tenantId,
    List<String>? roles,
    List<String>? permissions,
    List<String>? scopes,
  }) {
    return UserProfileResponse(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      tenantId: tenantId ?? this.tenantId,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      scopes: scopes ?? this.scopes,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;
  final String? tenantId;

  LoginRequest({
    required this.email,
    required this.password,
    this.tenantId,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        if (tenantId != null) 'tenantId': tenantId,
      };
}

enum DemoPersonaKey { superadmin, principal, teacher, student, parent }

class DemoPersona {
  final DemoPersonaKey key;
  final String name;
  final String roleLabel;
  final String email;
  final String description;

  const DemoPersona({
    required this.key,
    required this.name,
    required this.roleLabel,
    required this.email,
    required this.description,
  });
}

const Map<DemoPersonaKey, DemoPersona> DEMO_PERSONAS = {
  DemoPersonaKey.superadmin: DemoPersona(
    key: DemoPersonaKey.superadmin,
    name: 'Dr. Sarah Jenkins',
    roleLabel: 'Platform SuperAdmin',
    email: 'admin.utama@ilmiya.edu',
    description:
        'Unrestricted master access across all bounded contexts, scopes, and tenants.',
  ),
  DemoPersonaKey.principal: DemoPersona(
    key: DemoPersonaKey.principal,
    name: 'Prof. Marcus Chen',
    roleLabel: 'School Principal',
    email: 'principal@ilmiya.edu',
    description:
        'Institutional management, academic year rollovers, settings, and user provisioning.',
  ),
  DemoPersonaKey.teacher: DemoPersona(
    key: DemoPersonaKey.teacher,
    name: 'Dr. Eleanor Vance',
    roleLabel: 'Senior Faculty',
    email: 'eleanor.vance@ilmiya.edu',
    description:
        'Course management, grading, attendance tracking, and report cards.',
  ),
  DemoPersonaKey.student: DemoPersona(
    key: DemoPersonaKey.student,
    name: 'Alex Rivera',
    roleLabel: 'Student (Class 10-A)',
    email: 'alex.rivera@student.ilmiya.edu',
    description:
        'Student portal, schedule review, grade viewing, and attendance logs.',
  ),
  DemoPersonaKey.parent: DemoPersona(
    key: DemoPersonaKey.parent,
    name: 'Elena Rivera',
    roleLabel: 'Parent / Guardian',
    email: 'elena.rivera@parent.ilmiya.edu',
    description:
        'Family portal, student attendance oversight, and term grade cards.',
  ),
};
