import '../models/tenant.dart';
import 'api_client.dart';
import 'mock_storage_service.dart';

class TenantService {
  final ApiClient _apiClient;
  final MockStorageService _mockStorage;

  TenantService({ApiClient? apiClient, MockStorageService? mockStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _mockStorage = mockStorage ?? MockStorageService();

  Future<List<TenantResponse>> listTenants(
      {String? query, String? status}) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.listTenants(query: query, status: status);
    }

    String endpoint = '/api/v1/tenants';
    final qParams = <String>[];
    if (query != null && query.isNotEmpty) {
      qParams.add('query=${Uri.encodeComponent(query)}');
    }
    if (status != null && status.isNotEmpty && status.toUpperCase() != 'ALL') {
      qParams.add('status=${Uri.encodeComponent(status)}');
    }
    if (qParams.isNotEmpty) {
      endpoint = '$endpoint?${qParams.join('&')}';
    }

    final json = await _apiClient.request(
      endpoint: endpoint,
      method: 'GET',
    );
    if (json is Map && json.containsKey('content') && json['content'] is List) {
      return (json['content'] as List)
          .map((e) => TenantResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (json is List) {
      return json
          .map((e) => TenantResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<TenantResponse> getTenant(String tenantId) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.getTenant(tenantId);
    }

    final json = await _apiClient.request(
      endpoint: '/api/v1/tenants/$tenantId',
      method: 'GET',
    );
    return TenantResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<TenantResponse> createTenant(CreateTenantRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.createTenant(req);
    }

    final json = await _apiClient.request(
      endpoint: '/api/v1/tenants',
      method: 'POST',
      body: req.toJson(),
    );
    return TenantResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<TenantResponse> updateTenant(
      String tenantId, UpdateTenantRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.updateTenant(tenantId, req);
    }

    final json = await _apiClient.request(
      endpoint: '/api/v1/tenants/$tenantId',
      method: 'PUT',
      body: req.toJson(),
    );
    return TenantResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<TenantResponse> updateTenantStatus(
      String tenantId, String status) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.updateTenantStatus(tenantId, status);
    }

    final existing = await getTenant(tenantId);
    final req = UpdateTenantRequest(
      name: existing.name,
      address: existing.address,
      contactEmail: existing.contactEmail,
      contactPhone: existing.contactPhone,
      logoUrl: existing.logoUrl,
      legalEntityNumber: existing.legalEntityNumber,
      registrationType: existing.registrationType,
      status: status,
    );
    return updateTenant(tenantId, req);
  }

  Future<bool> deleteTenant(String tenantId) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.deleteTenant(tenantId);
    }

    await _apiClient.request(
      endpoint: '/api/v1/tenants/$tenantId',
      method: 'DELETE',
    );
    return true;
  }
}

final tenantService = TenantService();
