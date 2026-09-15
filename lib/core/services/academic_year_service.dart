import '../models/academic_year.dart';
import 'api_client.dart';
import 'mock_storage_service.dart';

class AcademicYearService {
  final ApiClient _apiClient;
  final MockStorageService _mockStorage;

  AcademicYearService({ApiClient? apiClient, MockStorageService? mockStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _mockStorage = mockStorage ?? MockStorageService();

  Future<List<AcademicYearResponse>> listAcademicYears() async {
    if (_apiClient.isMockMode) {
      return _mockStorage.listAcademicYears(_apiClient.tenantId);
    }

    try {
      final json = await _apiClient.request(
        endpoint: '/api/v1/academic-years',
        method: 'GET',
      );
      return (json as List<dynamic>)
          .map((e) => AcademicYearResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _mockStorage.listAcademicYears(_apiClient.tenantId);
    }
  }

  Future<AcademicYearResponse?> getActiveAcademicYear() async {
    if (_apiClient.isMockMode) {
      return _mockStorage.getActiveAcademicYear(_apiClient.tenantId);
    }

    try {
      final json = await _apiClient.request(
        endpoint: '/api/v1/academic-years/active',
        method: 'GET',
      );
      if (json == null) return null;
      return AcademicYearResponse.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return _mockStorage.getActiveAcademicYear(_apiClient.tenantId);
    }
  }

  Future<AcademicYearResponse> createAcademicYear(CreateAcademicYearRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.createAcademicYear(_apiClient.tenantId, req);
    }

    try {
      final json = await _apiClient.request(
        endpoint: '/api/v1/academic-years',
        method: 'POST',
        body: req.toJson(),
      );
      return AcademicYearResponse.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return _mockStorage.createAcademicYear(_apiClient.tenantId, req);
    }
  }

  Future<AcademicYearResponse> activateYear(String yearId) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.activateAcademicYear(_apiClient.tenantId, yearId);
    }

    try {
      final json = await _apiClient.request(
        endpoint: '/api/v1/academic-years/$yearId/activate',
        method: 'POST',
      );
      return AcademicYearResponse.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return _mockStorage.activateAcademicYear(_apiClient.tenantId, yearId);
    }
  }

  Future<AcademicYearResponse> addTerm(String yearId, AddAcademicTermRequest req) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.addAcademicTerm(yearId, req);
    }

    try {
      final json = await _apiClient.request(
        endpoint: '/api/v1/academic-years/$yearId/terms',
        method: 'POST',
        body: req.toJson(),
      );
      return AcademicYearResponse.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return _mockStorage.addAcademicTerm(yearId, req);
    }
  }

  Future<AcademicYearResponse> activateTerm(String yearId, String termId) async {
    if (_apiClient.isMockMode) {
      return _mockStorage.activateAcademicTerm(yearId, termId);
    }

    try {
      final json = await _apiClient.request(
        endpoint: '/api/v1/academic-years/$yearId/terms/$termId/activate',
        method: 'POST',
      );
      return AcademicYearResponse.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return _mockStorage.activateAcademicTerm(yearId, termId);
    }
  }
}

final academicYearService = AcademicYearService();
