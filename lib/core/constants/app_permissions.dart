/// Central catalog of permission codes and screen visibility rules.
///
/// Visibility rule: a user may view a screen if they hold **at least one**
/// permission in that screen's visibility set. Individual actions inside the
/// screen are guarded by their specific permission code.
///
/// Wildcards (`*`, `iam:*`, `iam:user:*`) and SUPERADMIN roles are resolved by
/// [AuthNotifier.hasPermission], so this catalog only lists concrete codes.
library;

class AppPermissions {
  const AppPermissions._();

  // Platform
  static const String all = '*';

  // Identity & Access Management
  static const String iamUserRead = 'iam:user:read';
  static const String iamUserCreate = 'iam:user:create';
  static const String iamUserUpdate = 'iam:user:update';
  static const String iamUserStatus = 'iam:user:status';
  static const String iamUserAssignRole = 'iam:user:assign-role';
  static const String iamUserManageMembership = 'iam:user:manage-membership';
  static const String iamUserDelete = 'iam:user:delete';
  static const String iamRoleRead = 'iam:role:read';
  static const String iamRoleCreate = 'iam:role:create';
  static const String iamRoleUpdate = 'iam:role:update';
  static const String iamRoleDelete = 'iam:role:delete';
  static const String iamGroupRead = 'iam:group:read';
  static const String iamGroupCreate = 'iam:group:create';
  static const String iamGroupUpdate = 'iam:group:update';
  static const String iamGroupDelete = 'iam:group:delete';
  static const String iamGroupAssignRole = 'iam:group:assign-role';
  static const String iamScopeRead = 'iam:scope:read';
  static const String iamScopeCreate = 'iam:scope:create';
  static const String iamScopeUpdate = 'iam:scope:update';
  static const String iamScopeMove = 'iam:scope:move';
  static const String iamScopeDelete = 'iam:scope:delete';
  static const String tenantPasswordPolicyRead = 'tenant:password-policy:read';
  static const String tenantPasswordPolicyWrite =
      'tenant:password-policy:write';

  // Institution & Governance
  static const String schoolProfileRead = 'school:profile:read';
  static const String schoolProfileWrite = 'school:profile:write';
  static const String schoolSettingsManage = 'school:settings:manage';
  static const String schoolCampusRead = 'school:campus:read';
  static const String schoolCampusCreate = 'school:campus:create';
  static const String schoolStatusManage = 'school:status:manage';
  static const String tenantRead = 'tenant:read';
  static const String tenantWrite = 'tenant:write';

  // Academics & Curricula
  static const String academicYearRead = 'academic:year:read';
  static const String academicYearWrite = 'academic:year:write';
  static const String academicCourseRead = 'academic:course:read';
  static const String academicCourseWrite = 'academic:course:write';

  // Student & Classroom
  static const String studentProfileRead = 'student:profile:read';
  static const String studentProfileWrite = 'student:profile:write';
  static const String attendanceRecordRead = 'attendance:record:read';
  static const String attendanceRecordCreate = 'attendance:record:create';
  static const String examGradeCreate = 'exam:grade:create';

  /// Screen visibility sets — at least one permission grants view access.
  static const List<String> schoolProfileView = [
    schoolProfileRead,
    schoolProfileWrite,
    schoolSettingsManage,
  ];

  static const List<String> schoolsCampusesView = [
    ...schoolProfileView,
    schoolCampusRead,
    schoolCampusCreate,
    tenantRead,
    tenantWrite,
  ];

  static const List<String> academicYearsView = [
    academicYearRead,
    academicYearWrite,
  ];

  static const List<String> iamView = [
    iamUserRead,
    iamUserCreate,
    iamUserUpdate,
    iamUserStatus,
    iamUserAssignRole,
    iamUserManageMembership,
    iamUserDelete,
    iamRoleRead,
    iamRoleCreate,
    iamRoleUpdate,
    iamRoleDelete,
    iamGroupRead,
    iamGroupCreate,
    iamGroupUpdate,
    iamGroupDelete,
    iamGroupAssignRole,
    iamScopeRead,
    iamScopeCreate,
    iamScopeUpdate,
    iamScopeMove,
    iamScopeDelete,
    tenantPasswordPolicyRead,
    tenantPasswordPolicyWrite,
  ];

  static const List<String> coursesAndGradesView = [
    academicCourseRead,
    academicCourseWrite,
    examGradeCreate,
    studentProfileRead,
  ];

  /// IAM Console sub-tab visibility sets.
  static const List<String> iamUsersTabView = [
    iamUserRead,
    iamUserCreate,
    iamUserUpdate,
    iamUserStatus,
    iamUserAssignRole,
    iamUserManageMembership,
    iamUserDelete,
  ];

  static const List<String> iamRolesTabView = [
    iamRoleRead,
    iamRoleCreate,
    iamRoleUpdate,
    iamRoleDelete,
  ];

  static const List<String> iamGroupsTabView = [
    iamGroupRead,
    iamGroupCreate,
    iamGroupUpdate,
    iamGroupDelete,
    iamGroupAssignRole,
  ];

  static const List<String> iamScopesTabView = [
    iamScopeRead,
    iamScopeCreate,
    iamScopeUpdate,
    iamScopeMove,
    iamScopeDelete,
  ];

  static const List<String> iamPasswordPolicyTabView = [
    tenantPasswordPolicyRead,
    tenantPasswordPolicyWrite,
  ];
}
