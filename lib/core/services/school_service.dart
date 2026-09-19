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

    final json = await _apiClient.request(
      endpoint: '/api/v1/schools/profile',
      method: 'GET',
    );
    return SchoolResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<SchoolResponse> updateProfile(UpdateSchoolRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.updateSchoolProfile(req);
    }

    final json = await _apiClient.request(
      endpoint: '/api/v1/schools/profile',
      method: 'PUT',
      body: req.toJson(),
    );
    return SchoolResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<SchoolResponse> configureSettings(ConfigureSchoolSettingsRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.configureSchoolSettings(req);
    }

    final json = await _apiClient.request(
      endpoint: '/api/v1/schools/settings',
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
}

final schoolService = SchoolService();
