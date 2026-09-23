import 'package:flutter/foundation.dart';
import '../core/models/iam.dart';
import '../core/services/api_client.dart';
import '../core/services/iam_service.dart';

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

  UserProfileResponse? _user;
  String _tenantId = 'tenant-lincoln-high-001';
  String? _token;
  List<String> _roles = [];
  List<String> _permissions = [];
  bool _isLoading = false;
  String? _error;
  void Function()? _unsubscribeAuthExpired;

  AuthNotifier({ApiClient? apiClient, IamService? iamService})
      : _apiClient = apiClient ?? ApiClient(),
        _iamService = iamService ?? IamService() {
    _tenantId = _apiClient.tenantId;
    _token = _apiClient.token;
    _unsubscribeAuthExpired = _apiClient.onAuthExpired(() {
      _user = null;
      _token = null;
      _roles = [];
      _permissions = [];
      _error = 'Your session has expired. Please sign in again.';
      notifyListeners();
    });
    // Hydrate default profile
    refreshProfile();
  }

  @override
  void dispose() {
    _unsubscribeAuthExpired?.call();
    super.dispose();
  }

  bool get isAuthenticated =>
      _user != null && (_token != null || _apiClient.isMockMode);
  UserProfileResponse? get user => _user;
  String get tenantId => _tenantId;
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

  Future<void> refreshProfile() async {
    try {
      _isLoading = true;
      notifyListeners();
      final profile = await _iamService.getMe();
      _user = profile;
      _tenantId =
          profile.tenantId.isNotEmpty ? profile.tenantId : _apiClient.tenantId;
      _roles = profile.roles;
      _permissions = profile.permissions;
      _token = _apiClient.token;
      _error = null;
    } catch (e) {
      if (_apiClient.token == null && !_apiClient.isMockMode) {
        _user = null;
        _roles = [];
        _permissions = [];
      }
    } finally {
      _isLoading = false;
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
      await refreshProfile();
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

  void logout() {
    _iamService.logout();
    _user = null;
    _token = null;
    _roles = [];
    _permissions = [];
    _error = null;
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
      await refreshProfile();
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
