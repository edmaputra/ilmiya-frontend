import 'package:flutter/foundation.dart';
import '../core/models/iam.dart';
import '../core/services/api_client.dart';
import '../core/services/iam_service.dart';
import '../core/services/school_service.dart';
import '../core/services/session_storage_service.dart';

bool checkPermission(List<String> userPermissions, List<String> userRoles,
    String targetPermission) {
  if (userRoles.any((r) => r.toUpperCase() == 'SUPERADMIN') ||
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

  UserProfileResponse? _user;
  String _tenantId = 'tenant-lincoln-high-001';
  String? _schoolName;
  String? _token;
  List<String> _roles = [];
  List<String> _permissions = [];
  bool _isLoading = false;
  String? _error;
  void Function()? _unsubscribeAuthExpired;
  bool _lastMockMode = true;

  AuthNotifier({
    ApiClient? apiClient,
    IamService? iamService,
    SchoolService? schoolService,
    SessionStorageService? sessionStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _iamService = iamService ?? IamService(),
        _schoolService = schoolService ?? SchoolService(),
        _sessionStorage = sessionStorage ?? SessionStorageService() {
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
    _unsubscribeAuthExpired = _apiClient.onAuthExpired(([reason]) {
      _user = null;
      _token = null;
      _roles = [];
      _permissions = [];
      _isLoading = false;
      _sessionStorage.clearAuthSession();
      _error = reason ?? 'Your session has expired. Please sign in again.';
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
  String get schoolName {
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

  String? get token => _token;
  List<String> get roles => List.unmodifiable(_roles);
  List<String> get permissions => List.unmodifiable(_permissions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool hasPermission(String targetPermission) {
    return checkPermission(_permissions, _roles, targetPermission);
  }

  bool hasRole(String role) {
    final normalized = role.toUpperCase();
    return _roles.any((r) => r.toUpperCase() == normalized);
  }

  Future<void> refreshProfile({bool showLoading = false}) async {
    try {
      if (showLoading) {
        _isLoading = true;
        notifyListeners();
      }
      final profile = await _iamService.getMe();
      _user = profile;
      _tenantId =
          profile.tenantId.isNotEmpty ? profile.tenantId : _apiClient.tenantId;
      _roles = profile.roles;
      _permissions = profile.permissions;
      _token = _apiClient.token;
      _error = null;

      try {
        final school = await _schoolService.getProfile(tenantId: _tenantId);
        _schoolName = school.name;
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
      _tenantId =
          resp.tenantId.isNotEmpty ? resp.tenantId : _apiClient.tenantId;
      _roles = resp.roles;
      _permissions = resp.permissions;
      if (resp.user != null) {
        _user = resp.user;
      }
      await refreshProfile();
      await _sessionStorage.saveAuthSession(
        accessToken: _token,
        refreshToken: _apiClient.refreshToken,
        tenantId: _tenantId,
        user: _user,
        schoolName: _schoolName,
      );
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
    await login(LoginRequest(
      email: persona.email,
      password:
          '${persona.key.name[0].toUpperCase()}${persona.key.name.substring(1)}@123',
      tenantId: _apiClient.tenantId,
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
    _error = null;
    _isLoading = false;
    _tenantId = _apiClient.tenantId;
    notifyListeners();
  }

  Future<void> switchTenant(String newTenantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final resp = await _iamService.switchTenant(newTenantId);
      _tenantId = resp.tenantId.isNotEmpty ? resp.tenantId : newTenantId;
      _roles = resp.roles;
      _permissions = resp.permissions;
      try {
        final school = await _schoolService.getProfile(tenantId: _tenantId);
        _schoolName = school.name;
      } catch (_) {}
      await refreshProfile();
      await _sessionStorage.saveAuthSession(
        accessToken: _token,
        refreshToken: _apiClient.refreshToken,
        tenantId: _tenantId,
        user: _user,
        schoolName: _schoolName,
      );
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
