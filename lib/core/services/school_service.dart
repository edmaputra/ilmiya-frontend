import '../models/school.dart';
import 'api_client.dart';
import 'mock_storage_service.dart';

class SchoolService {
  final ApiClient _apiClient;
  final MockStorageService _mockStorage;

  SchoolService({ApiClient? apiClient, MockStorageService? mockStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _mockStorage = mockStorage ?? MockStorageService();

  Future<SchoolResponse> getProfile() async {
    if (_apiClient.isMockMode) {
      return _mockStorage.getSchoolProfile(_apiClient.tenantId);
    }

    try {
      final json = await _apiClient.request(
        endpoint: '/api/v1/schools/profile',
        method: 'GET',
      );
      return SchoolResponse.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return _mockStorage.getSchoolProfile(_apiClient.tenantId);
    }
  }

  Future<SchoolResponse> updateProfile(UpdateSchoolRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.updateSchoolProfile(req);
    }

    try {
      final json = await _apiClient.request(
        endpoint: '/api/v1/schools/profile',
        method: 'PUT',
        body: req.toJson(),
      );
      return SchoolResponse.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return _mockStorage.updateSchoolProfile(req);
    }
  }

  Future<SchoolResponse> configureSettings(
      ConfigureSchoolSettingsRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.configureSchoolSettings(req);
    }

    try {
      final json = await _apiClient.request(
        endpoint: '/api/v1/schools/settings',
        method: 'PUT',
        body: req.toJson(),
      );
      return SchoolResponse.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return _mockStorage.configureSchoolSettings(req);
    }
  }

  Future<SchoolResponse> registerSchool(RegisterSchoolRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.registerSchool(req);
    }

    try {
      final json = await _apiClient.request(
        endpoint: '/api/v1/schools/register',
        method: 'POST',
        body: req.toJson(),
      );
      return SchoolResponse.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return _mockStorage.registerSchool(req);
    }
  }
}

final schoolService = SchoolService();
