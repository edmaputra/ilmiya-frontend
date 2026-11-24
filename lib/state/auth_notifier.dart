import 'package:flutter/foundation.dart';
import '../core/models/iam.dart';
import '../core/services/api_client.dart';
import '../core/services/iam_service.dart';
import '../core/services/school_service.dart';
import '../core/services/session_storage_service.dart';
import '../core/services/tenant_service.dart';

bool checkPermission(List<String> userPermissions, List<String> userRoles,
    String targetPermission,
    {bool isSuperAdmin = false}) {
  if (isSuperAdmin ||
      userRoles.any((r) =>
          r.toUpperCase() == 'SUPERADMIN' ||
          r.toUpperCase() == 'ROLE_SUPERADMIN' ||
          r.toUpperCase() == 'PLATFORM_SUPERADMIN' ||
          r.toUpperCase() == 'ROLE_PLATFORM_SUPERADMIN') ||
      userPermissions.contains('*')) {
    return true;
  }
  for (final perm in userPermissions) {
    if (perm == targetPermission) return true;
    if (perm.endsWith(':*')) {
      final prefix = perm.substring(0, perm.length - 2);
      if (targetPermission == prefix ||
          targetPermission.startsWith('$prefix:')) {
        return true;
      }
    }
    if (perm.endsWith('*')) {
      final prefix = perm.substring(0, perm.length - 1);
      if (targetPermission.startsWith(prefix)) {
        return true;
      }
    }
  }
  return false;
}

class AuthNotifier extends ChangeNotifier {
  final ApiClient _apiClient;
  final IamService _iamService;
  final SchoolService _schoolService;
  final SessionStorageService _sessionStorage;
  final TenantService _tenantService;

  UserProfileResponse? _user;
  String _tenantId = 'tenant-lincoln-high-001';
  String? _tenantName;
  String? _schoolId;
  String? _schoolName;
  String? _token;
  List<String> _roles = [];
  List<String> _permissions = [];
  bool _isLoading = false;
  String? _error;
  void Function()? _unsubscribeAuthExpired;
  bool _lastMockMode = true;
  bool _hasSwitchedTenant = true;
  String _sessionId = DateTime.now().microsecondsSinceEpoch.toString();
  final List<VoidCallback> _onLogoutListeners = [];
  final List<VoidCallback> _onLoginListeners = [];

  void Function() onLogout(VoidCallback callback) {
    _onLogoutListeners.add(callback);
    return () => _onLogoutListeners.remove(callback);
  }

  void Function() onLogin(VoidCallback callback) {
    _onLoginListeners.add(callback);
    return () => _onLoginListeners.remove(callback);
  }

  String get sessionId => _sessionId;

  AuthNotifier({
    ApiClient? apiClient,
    IamService? iamService,
    SchoolService? schoolService,
    SessionStorageService? sessionStorage,
    TenantService? tenantService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _iamService = iamService ?? IamService(),
        _schoolService = schoolService ?? SchoolService(),
        _sessionStorage = sessionStorage ?? SessionStorageService(),
        _tenantService = tenantService ?? TenantService() {
    // Restore session credentials from local storage
    final savedToken = _sessionStorage.accessToken;
    final savedRefreshToken = _sessionStorage.refreshToken;
    final savedTenant = _sessionStorage.tenantId;
    final savedUser = _sessionStorage.userProfile;
    final savedSchool = _sessionStorage.schoolName;

    if (savedToken != null && savedToken.isNotEmpty) {
      _apiClient.token = savedToken;
      _token = savedToken;
    } else {
      _token = _apiClient.token;
    }
    if (savedRefreshToken != null && savedRefreshToken.isNotEmpty) {
      _apiClient.refreshToken = savedRefreshToken;
    }
    if (savedTenant != null && savedTenant.isNotEmpty) {
      _apiClient.tenantId = savedTenant;
      _tenantId = savedTenant;
    } else {
      _tenantId = _apiClient.tenantId;
    }
    if (savedUser != null) {
      _user = savedUser;
      _roles = List.from(savedUser.roles);
      _permissions = List.from(savedUser.permissions);
    }
    if (savedSchool != null && savedSchool.isNotEmpty) {
      _schoolName = savedSchool;
    }
    _lastMockMode = _apiClient.isMockMode;
    _hasSwitchedTenant = _apiClient.tenantId != 'platform';
    _tenantId = _apiClient.tenantId;
    _unsubscribeAuthExpired = _apiClient.onAuthExpired(([reason]) {
      _user = null;
      _token = null;
      _roles = [];
      _permissions = [];
      _isLoading = false;
      _sessionStorage.clearAuthSession();
      _tenantName = 'Ilmiya Educational Foundation';
      _schoolName = 'SMA Negeri 1 Ilmiya';
      _schoolId = null;
      _sessionId = DateTime.now().microsecondsSinceEpoch.toString();
      _error = reason ?? 'Your session has expired. Please sign in again.';
      for (final listener in List.of(_onLogoutListeners)) {
        try {
          listener();
        } catch (_) {}
      }
      notifyListeners();
    });
    _apiClient.addListener(_onApiClientChanged);
    // Hydrate default profile
    refreshProfile();
  }

  void _onApiClientChanged() {
    _tenantId = _apiClient.tenantId;
    if (_lastMockMode != _apiClient.isMockMode) {
      _lastMockMode = _apiClient.isMockMode;
      if (!_apiClient.isMockMode && _apiClient.token == null) {
        _user = null;
        _token = null;
        _roles = [];
        _permissions = [];
      }
      refreshProfile();
    }
  }

  @override
  void dispose() {
    _apiClient.removeListener(_onApiClientChanged);
    _unsubscribeAuthExpired?.call();
    super.dispose();
  }

  bool get isAuthenticated =>
      _user != null && (_token != null || _apiClient.isMockMode);
  UserProfileResponse? get user => _user;
  String get tenantId => _tenantId;
  String get tenantName {
    if (_tenantId.isEmpty) {
      return '';
    }
    if (_tenantName != null && _tenantName!.isNotEmpty) {
      return _tenantName!;
    }
    if (_tenantId == 'platform') {
      return 'Platform Administration';
    }
    if (_tenantId == 'tenant-lincoln-high-001') {
      return 'Yayasan Pendidikan Lincoln Ilmiya';
    }
    if (_tenantId == 'tenant-sma1-ilmiya-002') {
      return 'Yayasan Pembina Generasi Ilmiya';
    }
    if (_tenantId == 'tenant-alazhar-003') {
      return 'Yayasan Pesantren Islam Al-Azhar';
    }
    if (_tenantId == 'tenant-horizon-004') {
      return 'Horizon STEM Education Trust';
    }
    if (_tenantId == 'tenant-stjude-005') {
      return 'St. Jude Educational Association';
    }
    return 'Yayasan Pendidikan Ilmiya';
  }

  String get tenantDisplayName => tenantName;

  String? get schoolId => _schoolId;

  String get schoolName {
    if (_tenantId.isEmpty) {
      return '';
    }
    if (_tenantId == 'platform') {
      return _schoolName != null && _schoolName!.isNotEmpty
          ? _schoolName!
          : 'Platform Operations';
    }
    if (_schoolName != null && _schoolName!.isNotEmpty) {
      return _schoolName!;
    }
    if (_tenantId == 'tenant-lincoln-high-001') {
      return 'Lincoln High School';
    }
    if (_tenantId == 'tenant-sma1-ilmiya-002') {
      return 'SMA Negeri 1 Ilmiya';
    }
    return 'Ilmiya Academy';
  }

  void setSchoolName(String name) {
    if (_schoolName != name) {
      _schoolName = name;
      notifyListeners();
    }
  }

  void setSchoolContext(String id, String name) {
    _schoolId = id;
    _schoolName = name;
    notifyListeners();
  }

  Future<void> switchSchool(String newSchoolId) async {
    try {
      final school = await _schoolService.getProfile(tenantId: newSchoolId);
      _schoolId = school.id;
      _schoolName = school.name;
      notifyListeners();
    } catch (_) {}
  }

  String? get token => _token;
  List<String> get roles => List.unmodifiable(_roles);
  List<String> get permissions => List.unmodifiable(_permissions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isSuperAdmin =>
      (_user?.isPlatformSuperAdmin ?? false) ||
      _roles.any((r) =>
          r.toUpperCase() == 'SUPERADMIN' ||
          r.toUpperCase() == 'ROLE_SUPERADMIN' ||
          r.toUpperCase() == 'PLATFORM_SUPERADMIN' ||
          r.toUpperCase() == 'ROLE_PLATFORM_SUPERADMIN');
  bool get isTenantAdmin =>
      !isSuperAdmin &&
      _roles.any((r) =>
          r.toUpperCase() == 'TENANT_ADMIN' ||
          r.toUpperCase() == 'ROLE_TENANT_ADMIN');
  bool get hasSwitchedTenant => _hasSwitchedTenant;
  bool get isPlatformSession => isSuperAdmin && _tenantId == 'platform';

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool hasPermission(String targetPermission) {
    return checkPermission(_permissions, _roles, targetPermission,
        isSuperAdmin: isSuperAdmin);
  }

  bool hasRole(String role) {
    if (isSuperAdmin) return true;
    final normalized = role.toUpperCase();
    return _roles.any((r) =>
        r.toUpperCase() == normalized ||
        r.toUpperCase() == 'ROLE_$normalized' ||
        'ROLE_${r.toUpperCase()}' == normalized);
  }

  Future<void> refreshProfile({bool showLoading = false}) async {
    try {
      if (showLoading) {
        _isLoading = true;
        notifyListeners();
      }
      final profile = await _iamService.getMe();
      _user = profile;
      _roles = profile.roles;
      _permissions = profile.permissions;
      final isSuper = (_user?.isPlatformSuperAdmin ?? false) ||
          _roles.any((r) =>
              r.toUpperCase() == 'SUPERADMIN' ||
              r.toUpperCase() == 'ROLE_SUPERADMIN' ||
              r.toUpperCase() == 'PLATFORM_SUPERADMIN' ||
              r.toUpperCase() == 'ROLE_PLATFORM_SUPERADMIN');
      if (isSuper && _apiClient.tenantId == 'platform') {
        _tenantId = 'platform';
        _tenantName = 'Platform Administration';
        _schoolName = 'Platform Operations';
      } else {
        _tenantId =
            _apiClient.tenantId.isNotEmpty && _apiClient.tenantId != 'platform'
                ? _apiClient.tenantId
                : (profile.tenantId.isNotEmpty ? profile.tenantId : _tenantId);
      }
      _token = _apiClient.token;
      _error = null;

      try {
        if (_tenantId.isNotEmpty && _tenantId != 'platform') {
          final school = await _schoolService.getProfile(tenantId: _tenantId);
          _schoolId = school.id;
          _schoolName = school.name;
        } else {
          _schoolId = null;
          _schoolName = '';
        }
      } catch (_) {}
      if (_user != null) {
        await _sessionStorage.saveUserProfile(_user, _schoolName);
      }
    } catch (e) {
      if (_apiClient.token == null && !_apiClient.isMockMode) {
        _user = null;
        _roles = [];
        _permissions = [];
        await _sessionStorage.clearAuthSession();
      }
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> login(LoginRequest req) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final resp = await _iamService.login(req);
      _token = resp.accessToken;
      _roles = resp.roles;
      _permissions = resp.permissions;
      if (resp.user != null) {
        _user = resp.user;
      }
      final isSuper = (_user?.isPlatformSuperAdmin ?? false) ||
          _roles.any((r) =>
              r.toUpperCase() == 'SUPERADMIN' ||
              r.toUpperCase() == 'ROLE_SUPERADMIN' ||
              r.toUpperCase() == 'PLATFORM_SUPERADMIN' ||
              r.toUpperCase() == 'ROLE_PLATFORM_SUPERADMIN');
      if (isSuper) {
        _hasSwitchedTenant = false;
        _tenantId = 'platform';
        _apiClient.tenantId = 'platform';
      } else {
        _hasSwitchedTenant = true;
        _tenantId =
            resp.tenantId.isNotEmpty ? resp.tenantId : _apiClient.tenantId;
      }
      await refreshProfile();
      await _sessionStorage.saveAuthSession(
        accessToken: _token,
        refreshToken: _apiClient.refreshToken,
        tenantId: _tenantId,
        user: _user,
        schoolName: _schoolName,
      );
      _sessionId = DateTime.now().microsecondsSinceEpoch.toString();
      for (final listener in List.of(_onLoginListeners)) {
        try {
          listener();
        } catch (_) {}
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginAsPersona(DemoPersonaKey personaKey) async {
    final persona = DEMO_PERSONAS[personaKey];
    if (persona == null) return;
    final tId = personaKey == DemoPersonaKey.superadmin
        ? 'platform'
        : _apiClient.tenantId.isNotEmpty && _apiClient.tenantId != 'platform'
            ? _apiClient.tenantId
            : 'tenant-lincoln-high-001';
    await login(LoginRequest(
      email: persona.email,
      password:
          '${persona.key.name[0].toUpperCase()}${persona.key.name.substring(1)}@123',
      tenantId: tId,
    ));
  }

  void resetLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _iamService.logout();
    _sessionStorage.clearAuthSession();
    _user = null;
    _token = null;
    _roles = [];
    _permissions = [];
    _hasSwitchedTenant = false;
    _error = null;
    _isLoading = false;
    _tenantId = _apiClient.tenantId;
    _tenantName = 'Ilmiya Educational Foundation';
    _schoolName = 'SMA Negeri 1 Ilmiya';
    _schoolId = null;
    _sessionId = DateTime.now().microsecondsSinceEpoch.toString();
    for (final listener in List.of(_onLogoutListeners)) {
      try {
        listener();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> switchTenant(String newTenantId,
      {String? targetSchoolId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (newTenantId == 'platform') {
        _hasSwitchedTenant = false;
        _tenantId = 'platform';
        _apiClient.tenantId = 'platform';
        _schoolName = 'Platform Operations';
        _tenantName = 'Platform Administration';
        await refreshProfile();
        await _sessionStorage.saveTenantId('platform');
        if (_user != null) {
          await _sessionStorage.saveUserProfile(_user, _schoolName);
        }
        _sessionId = DateTime.now().microsecondsSinceEpoch.toString();
        for (final listener in List.of(_onLoginListeners)) {
          try {
            listener();
          } catch (_) {}
        }
        return;
      }
      final resp = await _iamService.switchTenant(newTenantId);
      _hasSwitchedTenant = true;
      _tenantId = resp.tenantId.isNotEmpty ? resp.tenantId : newTenantId;
      _apiClient.tenantId = _tenantId;
      _roles = resp.roles;
      _permissions = resp.permissions;
      if (resp.user != null) {
        _user = resp.user;
      }
      try {
        final tenant = await _tenantService.getTenant(_tenantId);
        _tenantName = tenant.name;
      } catch (_) {}
      try {
        final schools = await _schoolService.listSchools(tenantId: _tenantId);
        if (schools.isNotEmpty) {
          final matched = targetSchoolId != null
              ? schools.firstWhere((s) => s.id == targetSchoolId,
                  orElse: () => schools.first)
              : schools.first;
          _schoolId = matched.id;
          _schoolName = matched.name;
        } else {
          final school = await _schoolService.getProfile(tenantId: _tenantId);
          _schoolId = school.id;
          _schoolName = school.name;
        }
      } catch (_) {}
      await refreshProfile();
      await _sessionStorage.saveAuthSession(
        accessToken: _token,
        refreshToken: _apiClient.refreshToken,
        tenantId: _tenantId,
        user: _user,
        schoolName: _schoolName,
      );
      _sessionId = DateTime.now().microsecondsSinceEpoch.toString();
      for (final listener in List.of(_onLoginListeners)) {
        try {
          listener();
        } catch (_) {}
      }
    } catch (e) {
      _error = 'Failed to switch tenant: $e';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
