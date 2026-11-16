import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/academic_year.dart';
import 'package:ilmiya_app/core/models/school.dart';
import 'package:ilmiya_app/core/services/academic_year_service.dart';
import 'package:ilmiya_app/core/services/api_client.dart';
import 'package:ilmiya_app/core/services/school_service.dart';

void main() {
  setUp(() {
    apiClient.isMockMode = true;
  });

  group('SchoolService Mock CRUD Tests', () {
    test('getProfile returns default school configuration', () async {
      final profile = await schoolService.getProfile();
      expect(profile.name, contains('Ilmiya'));
      expect(profile.workingDays.length, equals(5));
      expect(
          profile.gradingPreference, equals('DESCRIPTIVE_KURIKULUM_MERDEKA'));
    });

    test('updateProfile modifies school profile details', () async {
      final updated = await schoolService.updateProfile(UpdateSchoolRequest(
        name: 'Lincoln International Academy',
        address: '456 Innovation Blvd, Tech City',
        contactEmail: 'info@lincoln.edu',
        contactPhone: '+1-555-0199',
      ));
      expect(updated.name, equals('Lincoln International Academy'));
      expect(updated.address, equals('456 Innovation Blvd, Tech City'));

      // Check re-fetch returns updated
      final reloaded = await schoolService.getProfile();
      expect(reloaded.name, equals('Lincoln International Academy'));
    });

    test('configureSettings modifies working days and term layout', () async {
      final configured =
          await schoolService.configureSettings(ConfigureSchoolSettingsRequest(
        workingDays: [
          'MONDAY',
          'TUESDAY',
          'WEDNESDAY',
          'THURSDAY',
          'FRIDAY',
          'SATURDAY'
        ],
        gradingPreference: 'PERCENTAGE',
        termLayout: 'TRIMESTER',
      ));
      expect(configured.workingDays.length, equals(6));
      expect(configured.gradingPreference, equals('PERCENTAGE'));
    });
  });

  group('AcademicYearService Mock CRUD Tests', () {
    test('listAcademicYears returns initial seeded years', () async {
      final list = await academicYearService.listAcademicYears();
      expect(list, isNotEmpty);
      expect(list.any((ay) => ay.name.contains('2026/2027')), isTrue);
    });

    test('getActiveAcademicYear returns active year with terms', () async {
      final active = await academicYearService.getActiveAcademicYear();
      expect(active, isNotNull);
      expect(active!.status, equals('ACTIVE'));
      expect(active.terms, isNotEmpty);
    });

    test('createAcademicYear creates a new academic year entry', () async {
      final newAy = await academicYearService
          .createAcademicYear(CreateAcademicYearRequest(
        name: 'Tahun Ajaran 2028/2029',
        startDate: '2028-07-15',
        endDate: '2029-06-25',
      ));
      expect(newAy.name, equals('Tahun Ajaran 2028/2029'));
      expect(newAy.status, equals('PLANNED'));

      final list = await academicYearService.listAcademicYears();
      expect(list.any((ay) => ay.id == newAy.id), isTrue);
    });

    test('addTerm appends a term to an academic year', () async {
      final active = await academicYearService.getActiveAcademicYear();
      expect(active, isNotNull);

      final updatedYear = await academicYearService.addTerm(
        active!.id,
        AddAcademicTermRequest(
          name: 'Summer Intensive Term',
          displayName: 'Summer Intensive 2027',
          type: 'INTENSIVE',
          startDate: '2027-06-20',
          endDate: '2027-07-10',
        ),
      );

      expect(updatedYear.terms.any((t) => t.name == 'Summer Intensive Term'),
          isTrue);
    });

    test('activateYear and activateTerm function properly', () async {
      final active = await academicYearService.getActiveAcademicYear();
      expect(active, isNotNull);

      final activated = await academicYearService.activateYear(active!.id);
      expect(activated.status, equals('ACTIVE'));

      if (active.terms.isNotEmpty) {
        final activatedTerm = await academicYearService.activateTerm(
            active.id, active.terms.first.id);
        expect(activatedTerm.terms.first.status, equals('ACTIVE'));
      }
    });
  });

  group('Service Error Tests when isMockMode is false and API fails', () {
    late ApiClient client;
    late SchoolService schoolSvc;
    late AcademicYearService academicSvc;

    setUp(() {
      client = ApiClient();
      client.isMockMode = false;
      client.baseUrl = 'http://invalid-endpoint-for-fallback-testing:9999';
      schoolSvc = SchoolService(apiClient: client);
      academicSvc = AcademicYearService(apiClient: client);
    });

    tearDown(() {
      client.isMockMode = true;
      client.baseUrl = 'http://localhost:8080';
    });

    test('SchoolService throws ApiException on API errors', () async {
      await expectLater(
        schoolSvc.getProfile(),
        throwsA(isA<ApiException>()),
      );

      await expectLater(
        schoolSvc.updateProfile(UpdateSchoolRequest(
          name: 'Live School',
          address: '123 Test St',
          contactEmail: 'live@ilmiya.edu',
          contactPhone: '+1-555-0100',
        )),
        throwsA(isA<ApiException>()),
      );
    });

    test('AcademicYearService throws ApiException on API errors', () async {
      await expectLater(
        academicSvc.listAcademicYears(),
        throwsA(isA<ApiException>()),
      );

      await expectLater(
        academicSvc.getActiveAcademicYear(),
        throwsA(isA<ApiException>()),
      );

      await expectLater(
        academicSvc.createAcademicYear(CreateAcademicYearRequest(
          name: 'TA 2030/2031',
          startDate: '2030-07-01',
          endDate: '2031-06-30',
        )),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
