import '../models/school.dart';
import 'api_client.dart';
import 'mock_storage_service.dart';

class SchoolService {
  final ApiClient _apiClient;
  final MockStorageService _mockStorage;

  SchoolService({ApiClient? apiClient, MockStorageService? mockStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _mockStorage = mockStorage ?? MockStorageService();

  Future<List<SchoolResponse>> listSchools(
      {String? query, String? status}) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.listSchools(query: query, status: status);
    }

    String endpoint = '/api/v1/schools';
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
    if (json is List) {
      return json
          .map((e) => SchoolResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<SchoolResponse> getProfile({String? tenantId}) async {
    final effectiveTenant = tenantId ?? _apiClient.tenantId;
    if (_apiClient.isMockMode) {
      return _mockStorage.getSchoolProfile(effectiveTenant);
    }

    final endpoint = tenantId != null
        ? '/api/v1/schools/$tenantId'
        : '/api/v1/schools/profile';
    final json = await _apiClient.request(
      endpoint: endpoint,
      method: 'GET',
    );
    return SchoolResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<SchoolResponse> updateProfile(UpdateSchoolRequest req,
      {String? tenantId}) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.updateSchoolProfile(req,
          targetTenantId: tenantId ?? _apiClient.tenantId);
    }

    final endpoint = tenantId != null
        ? '/api/v1/schools/$tenantId'
        : '/api/v1/schools/profile';
    final json = await _apiClient.request(
      endpoint: endpoint,
      method: 'PUT',
      body: req.toJson(),
    );
    return SchoolResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<SchoolResponse> configureSettings(ConfigureSchoolSettingsRequest req,
      {String? tenantId}) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.configureSchoolSettings(req,
          targetTenantId: tenantId ?? _apiClient.tenantId);
    }

    final endpoint = tenantId != null
        ? '/api/v1/schools/$tenantId/settings'
        : '/api/v1/schools/settings';
    final json = await _apiClient.request(
      endpoint: endpoint,
      method: 'PUT',
      body: req.toJson(),
    );
    return SchoolResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<SchoolResponse> registerSchool(RegisterSchoolRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.registerSchool(req);
    }

    final json = await _apiClient.request(
      endpoint: '/api/v1/schools/register',
      method: 'POST',
      body: req.toJson(),
    );
    return SchoolResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<SchoolResponse> updateSchoolStatus(
      String tenantId, String status) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.updateSchoolStatus(tenantId, status);
    }

    final json = await _apiClient.request(
      endpoint: '/api/v1/schools/$tenantId/status',
      method: 'PATCH',
      body: {'status': status},
    );
    return SchoolResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<bool> deleteSchool(String tenantId) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.deleteSchool(tenantId);
    }

    await _apiClient.request(
      endpoint: '/api/v1/schools/$tenantId',
      method: 'DELETE',
    );
    return true;
  }
}

final schoolService = SchoolService();
