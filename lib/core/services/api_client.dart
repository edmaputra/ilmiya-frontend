import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'session_storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;

  ApiException(this.statusCode, this.message, [this.data]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient extends ChangeNotifier {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const String _envMode = String.fromEnvironment(
    'PROFILE',
    defaultValue: String.fromEnvironment(
      'APP_PROFILE',
      defaultValue: String.fromEnvironment(
        'APP_MODE',
        defaultValue: '',
      ),
    ),
  );
  static const bool _hasEnvMock = bool.hasEnvironment('ILMIYA_MOCK_MODE') ||
      bool.hasEnvironment('MOCK_MODE') ||
      bool.hasEnvironment('MOCK');
  static const bool _envMock = bool.fromEnvironment(
    'ILMIYA_MOCK_MODE',
    defaultValue: bool.fromEnvironment(
      'MOCK_MODE',
      defaultValue: bool.fromEnvironment(
        'MOCK',
        defaultValue: false,
      ),
    ),
  );

  static bool _resolveInitialMockMode() {
    if (_envMode.toLowerCase() == 'mock') return true;
    if (_envMode.toLowerCase() == 'live' || _envMode.toLowerCase() == 'prod') {
      return false;
    }
    if (_hasEnvMock) return _envMock;

    // Detect if running under automated test runner (flutter test)
    try {
      if (Zone.current[#test.declarer] != null) {
        return true;
      }
      final binding = ServicesBinding.instance;
      if (binding.runtimeType.toString().contains('Test')) {
        return true;
      }
    } catch (_) {}

    return false; // Default is Live REST API for the application
  }

  static String _resolveInitialTenantId(bool isMock) {
    const envTenant = String.fromEnvironment(
      'ILMIYA_DEFAULT_TENANT_ID',
      defaultValue: '',
    );
    if (envTenant.isNotEmpty) return envTenant;
    return isMock
        ? 'tenant-lincoln-high-001'
        : '01940000-0000-7000-8000-000000000001';
  }

  static String _resolveInitialBaseUrl() {
    const envBaseUrl = String.fromEnvironment(
      'ILMIYA_API_BASE_URL',
      defaultValue: '',
    );
    if (envBaseUrl.isNotEmpty) return envBaseUrl;
    return 'https://ilmiya.localhost';
  }

  String _baseUrl = _resolveInitialBaseUrl();
  String _tenantId = _resolveInitialTenantId(_resolveInitialMockMode());
  String? token;
  String? refreshToken;
  bool _isMockMode = _resolveInitialMockMode();
  Completer<bool>? _refreshCompleter;
  final List<Function> _onAuthExpiredListeners = [];
  final List<Function> _onAccessDeniedListeners = [];

  bool get isMockMode => _isMockMode;
  set isMockMode(bool value) {
    if (_isMockMode != value) {
      _isMockMode = value;
      if (!_isMockMode && _tenantId == 'tenant-lincoln-high-001') {
        _tenantId = '01940000-0000-7000-8000-000000000001';
      } else if (_isMockMode &&
          _tenantId == '01940000-0000-7000-8000-000000000001') {
        _tenantId = 'tenant-lincoln-high-001';
      }
      notifyListeners();
    }
  }

  void resetTenantId() {
    _tenantId = _resolveInitialTenantId(_isMockMode);
    sessionStorageService.saveTenantId(_tenantId);
    notifyListeners();
  }

  void toggleMockMode() {
    isMockMode = !_isMockMode;
  }

  /// Loads startup profiling configuration from assets/config.json if available
  Future<void> loadRuntimeConfig() async {
    try {
      final content = await rootBundle.loadString('assets/config.json');
      _applyConfigJson(content);
    } catch (_) {
      try {
        final response = await http.get(Uri.parse('assets/config.json'));
        if (response.statusCode == 200) {
          _applyConfigJson(response.body);
        }
      } catch (_) {
        // Gracefully fall back to compile-time --dart-define or defaults
      }
    }

    // Restore persisted session from storage if available
    final savedToken = sessionStorageService.accessToken;
    final savedRefreshToken = sessionStorageService.refreshToken;
    final savedTenantId = sessionStorageService.tenantId;
    if (savedToken != null && savedToken.isNotEmpty) {
      token = savedToken;
    }
    if (savedRefreshToken != null && savedRefreshToken.isNotEmpty) {
      refreshToken = savedRefreshToken;
    }
    if (savedTenantId != null && savedTenantId.isNotEmpty) {
      _tenantId = savedTenantId;
    }
  }

  void _applyConfigJson(String rawJson) {
    final dynamic data = json.decode(rawJson);
    if (data is Map<String, dynamic>) {
      if (data['apiBaseUrl'] is String &&
          (data['apiBaseUrl'] as String).isNotEmpty) {
        baseUrl = data['apiBaseUrl'] as String;
      }
      if (data['defaultTenantId'] is String &&
          (data['defaultTenantId'] as String).isNotEmpty) {
        tenantId = data['defaultTenantId'] as String;
      }
      if (data['mockMode'] is bool) {
        if (_envMode.isEmpty && !_hasEnvMock) {
          isMockMode = data['mockMode'] as bool;
        }
      }
    }
  }

  String get tenantId => _tenantId;
  set tenantId(String value) {
    if (_tenantId != value) {
      _tenantId = value;
      sessionStorageService.saveTenantId(_tenantId);
      notifyListeners();
    }
  }

  String get baseUrl => _baseUrl;
  set baseUrl(String url) {
    final cleaned = url.replaceAll(RegExp(r'/+$'), '');
    if (_baseUrl != cleaned) {
      _baseUrl = cleaned;
      notifyListeners();
    }
  }

  void Function() onAuthExpired(Function listener) {
    _onAuthExpiredListeners.add(listener);
    return () => _onAuthExpiredListeners.remove(listener);
  }

  void triggerAuthExpired([String? reason]) {
    token = null;
    refreshToken = null;
    sessionStorageService.clearAuthSession();
    for (final listener in List.of(_onAuthExpiredListeners)) {
      try {
        (listener as dynamic)(reason);
      } catch (_) {
        (listener as dynamic)();
      }
    }
    notifyListeners();
  }

  void Function() onAccessDenied(Function listener) {
    _onAccessDeniedListeners.add(listener);
    return () => _onAccessDeniedListeners.remove(listener);
  }

  void triggerAccessDenied([String? reason]) {
    final msg = reason ??
        'Access denied (403): You do not have sufficient permission to access this resource.';
    for (final listener in List.of(_onAccessDeniedListeners)) {
      try {
        (listener as dynamic)(msg);
      } catch (_) {
        (listener as dynamic)();
      }
    }
  }

  Future<dynamic> request({
    required String endpoint,
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body,
    bool isRetry = false,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final normalizedEndpoint =
        (_baseUrl.endsWith('/api') && cleanEndpoint.startsWith('/api/'))
            ? cleanEndpoint.substring(4)
            : cleanEndpoint;
    final url = Uri.parse('$_baseUrl$normalizedEndpoint');

    final isLoginEndpoint = cleanEndpoint == '/api/v1/auth/login';
    final isUuid = RegExp(
            r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
        .hasMatch(tenantId);
    final shouldSendTenantHeader =
        !isLoginEndpoint && tenantId.isNotEmpty && (_isMockMode || isUuid);

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (shouldSendTenantHeader) 'X-Tenant-ID': tenantId,
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    try {
      http.Response response;
      final encodedBody =
          body is String ? body : (body != null ? jsonEncode(body) : null);

      switch (method.toUpperCase()) {
        case 'POST':
          response =
              await http.post(url, headers: requestHeaders, body: encodedBody);
          break;
        case 'PUT':
          response =
              await http.put(url, headers: requestHeaders, body: encodedBody);
          break;
        case 'PATCH':
          response =
              await http.patch(url, headers: requestHeaders, body: encodedBody);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders);
          break;
        case 'GET':
        default:
          response = await http.get(url, headers: requestHeaders);
          break;
      }

      // Automatic 401 Session Refresh with concurrency guard and single retry
      if (response.statusCode == 401 &&
          refreshToken != null &&
          !endpoint.contains('/api/v1/auth/') &&
          !isRetry) {
        bool refreshSucceeded = false;
        if (_refreshCompleter == null) {
          _refreshCompleter = Completer<bool>();
          try {
            final refreshUrl = Uri.parse('$_baseUrl/api/v1/auth/refresh');
            final refreshResp = await http.post(
              refreshUrl,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refreshToken': refreshToken}),
            );

            if (refreshResp.statusCode >= 200 && refreshResp.statusCode < 300) {
              final data = jsonDecode(refreshResp.body) as Map<String, dynamic>;
              token = data['accessToken'] as String?;
              if (data['refreshToken'] != null) {
                refreshToken = data['refreshToken'] as String?;
              }
              await sessionStorageService.saveTokens(
                accessToken: token,
                refreshToken: refreshToken,
              );
              refreshSucceeded = true;
              _refreshCompleter!.complete(true);
            } else {
              _refreshCompleter!.complete(false);
              triggerAuthExpired(
                  'Session refresh token expired (401). Please sign in again.');
            }
          } catch (_) {
            _refreshCompleter!.complete(false);
            triggerAuthExpired('Session refresh failed. Please sign in again.');
          } finally {
            _refreshCompleter = null;
          }
        } else {
          // A concurrent request is already refreshing the session, await its outcome
          refreshSucceeded = await _refreshCompleter!.future;
        }

        if (refreshSucceeded && token != null) {
          // Retry request with new token exactly once
          return await request(
            endpoint: endpoint,
            method: method,
            headers: headers,
            body: body,
            isRetry: true,
          );
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.statusCode == 204 || response.body.isEmpty) {
          return null;
        }
        return jsonDecode(response.body);
      }

      // Handle ProblemDetail error parsing (RFC 9457)
      String message = 'Request failed with status ${response.statusCode}';
      Map<String, dynamic>? errorData;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          errorData = decoded;
          message = decoded['detail'] as String? ??
              decoded['title'] as String? ??
              decoded['message'] as String? ??
              message;
        }
      } catch (_) {}

      // Security guard:
      // 401 Unauthorized -> Session expired, token cleared, redirect to login
      // 403 Forbidden    -> Access denied, keep session, stay on page, show error message
      if (!endpoint.contains('/api/v1/auth/login')) {
        if (response.statusCode == 401) {
          triggerAuthExpired('Session expired (401): $message');
        } else if (response.statusCode == 403) {
          triggerAccessDenied('Access denied (403): $message');
        }
      }

      throw ApiException(response.statusCode, message, errorData);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(0, 'Network connection error: $e');
    }
  }
}

final apiClient = ApiClient();
