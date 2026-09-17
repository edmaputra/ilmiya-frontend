import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  String _baseUrl = const String.fromEnvironment(
    'ILMIYA_API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  String _tenantId = const String.fromEnvironment(
    'ILMIYA_DEFAULT_TENANT_ID',
    defaultValue: 'tenant-lincoln-high-001',
  );
  String? token;
  String? refreshToken;
  bool _isMockMode = true;
  bool _isRefreshing = false;

  final List<void Function()> _onAuthExpiredListeners = [];

  bool get isMockMode => _isMockMode;
  set isMockMode(bool value) {
    if (_isMockMode != value) {
      _isMockMode = value;
      notifyListeners();
    }
  }

  void toggleMockMode() {
    isMockMode = !_isMockMode;
  }

  String get tenantId => _tenantId;
  set tenantId(String value) {
    if (_tenantId != value) {
      _tenantId = value;
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

  void Function() onAuthExpired(void Function() listener) {
    _onAuthExpiredListeners.add(listener);
    return () => _onAuthExpiredListeners.remove(listener);
  }

  void triggerAuthExpired() {
    token = null;
    refreshToken = null;
    for (final listener in List.of(_onAuthExpiredListeners)) {
      listener();
    }
  }

  Future<dynamic> request({
    required String endpoint,
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$_baseUrl$cleanEndpoint');

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (tenantId.isNotEmpty) 'X-Tenant-ID': tenantId,
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    try {
      http.Response response;
      final encodedBody = body is String ? body : (body != null ? jsonEncode(body) : null);

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(url, headers: requestHeaders, body: encodedBody);
          break;
        case 'PUT':
          response = await http.put(url, headers: requestHeaders, body: encodedBody);
          break;
        case 'PATCH':
          response = await http.patch(url, headers: requestHeaders, body: encodedBody);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders);
          break;
        case 'GET':
        default:
          response = await http.get(url, headers: requestHeaders);
          break;
      }

      // Automatic 401 Session Refresh
      if (response.statusCode == 401 &&
          refreshToken != null &&
          !endpoint.contains('/api/v1/auth/') &&
          !_isRefreshing) {
        _isRefreshing = true;
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
            _isRefreshing = false;
            // Retry request with new token
            return await request(
              endpoint: endpoint,
              method: method,
              headers: headers,
              body: body,
            );
          } else {
            triggerAuthExpired();
          }
        } catch (_) {
          triggerAuthExpired();
        } finally {
          _isRefreshing = false;
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

      throw ApiException(response.statusCode, message, errorData);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(0, 'Network connection error: $e');
    }
  }
}

final apiClient = ApiClient();
