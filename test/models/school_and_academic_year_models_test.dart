import 'package:flutter_test/flutter_test.dart';
import 'package:ilmiya_app/core/models/academic_year.dart';
import 'package:ilmiya_app/core/models/school.dart';

void main() {
  group('School and Academic Year Models Tests', () {
    test('SchoolResponse serialization and copyWith', () {
      final json = {
        'id': 'sch-1',
        'tenantId': 'tenant-test',
        'name': 'Test Academy',
        'institutionCode': 'TACAD',
        'address': '123 School Rd',
        'contactEmail': 'info@test.edu',
        'contactPhone': '+1234567890',
        'logoUrl': 'https://example.com/logo.png',
        'status': 'ACTIVE',
        'governmentRegistrationNumber': 'REG-1234',
        'registrationType': 'PRIVATE',
        'accreditationStatus': 'ACCREDITED_A',
        'accreditationBody': 'Test Board',
        'accreditationValidUntil': '2030-12-31',
        'workingDays': ['MONDAY', 'TUESDAY', 'WEDNESDAY'],
        'gradingPreference': 'NUMERIC_SCALE_100',
        'termLayout': 'SEMESTER',
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-02T00:00:00Z',
      };

      final school = SchoolResponse.fromJson(json);
      expect(school.id, 'sch-1');
      expect(school.name, 'Test Academy');
      expect(school.workingDays, ['MONDAY', 'TUESDAY', 'WEDNESDAY']);

      final serialized = school.toJson();
      expect(serialized['institutionCode'], 'TACAD');
      expect(serialized['accreditationStatus'], 'ACCREDITED_A');

      final copied =
          school.copyWith(name: 'Updated Academy', status: 'INACTIVE');
      expect(copied.name, 'Updated Academy');
      expect(copied.status, 'INACTIVE');
      expect(copied.id, 'sch-1');

      final fallback = SchoolResponse.fromJson({});
      expect(fallback.id, isEmpty);
      expect(fallback.status, 'ACTIVE');
      expect(fallback.workingDays, isNotEmpty);
    });

    test('School request DTOs toJson', () {
      final updateReq = UpdateSchoolRequest(
        name: 'Updated School',
        address: 'New Address',
        contactEmail: 'new@school.edu',
        contactPhone: '+11223344',
        logoUrl: 'https://logo.png',
        governmentRegistrationNumber: 'GOV-99',
        registrationType: 'PUBLIC',
        accreditationStatus: 'ACCREDITED_B',
        accreditationBody: 'State Board',
        accreditationValidUntil: '2029-01-01',
      );
      final updateJson = updateReq.toJson();
      expect(updateJson['name'], 'Updated School');
      expect(updateJson['accreditationStatus'], 'ACCREDITED_B');

      final configReq = ConfigureSchoolSettingsRequest(
        workingDays: ['MONDAY', 'FRIDAY'],
        gradingPreference: 'LETTER_GRADE_A_F',
        termLayout: 'QUARTER',
      );
      final configJson = configReq.toJson();
      expect(configJson['workingDays'], ['MONDAY', 'FRIDAY']);
      expect(configJson['termLayout'], 'QUARTER');

      final registerReq = RegisterSchoolRequest(
        tenantId: 'tenant-reg',
        name: 'Registered School',
        institutionCode: 'REG-SCH',
        address: 'Reg Address',
        contactEmail: 'reg@school.edu',
        contactPhone: '+99887766',
      );
      final regJson = registerReq.toJson();
      expect(regJson['tenantId'], 'tenant-reg');
      expect(regJson['institutionCode'], 'REG-SCH');
    });

    test('AcademicYearResponse and AcademicTermResponse serialization', () {
      final termJson = {
        'id': 'term-1',
        'academicYearId': 'ay-1',
        'name': 'Semester 1',
        'displayName': 'Sem 1 2026',
        'type': 'SEMESTER_1',
        'startDate': '2026-07-01',
        'endDate': '2026-12-31',
        'status': 'ACTIVE',
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-02T00:00:00Z',
      };
      final term = AcademicTermResponse.fromJson(termJson);
      expect(term.name, 'Semester 1');
      expect(term.status, 'ACTIVE');

      final termMap = term.toJson();
      expect(termMap['displayName'], 'Sem 1 2026');

      final termCopy = term.copyWith(name: 'Updated Term', status: 'CONCLUDED');
      expect(termCopy.name, 'Updated Term');
      expect(termCopy.status, 'CONCLUDED');

      final yearJson = {
        'id': 'ay-1',
        'tenantId': 'tenant-test',
        'name': 'Academic Year 2026/2027',
        'startDate': '2026-07-01',
        'endDate': '2027-06-30',
        'status': 'ACTIVE',
        'terms': [termJson],
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-02T00:00:00Z',
      };
      final year = AcademicYearResponse.fromJson(yearJson);
      expect(year.name, 'Academic Year 2026/2027');
      expect(year.terms.length, 1);

      final yearMap = year.toJson();
      expect(yearMap['terms'], isNotEmpty);

      final yearCopy = year.copyWith(name: 'New Year', status: 'ARCHIVED');
      expect(yearCopy.name, 'New Year');
      expect(yearCopy.status, 'ARCHIVED');

      final createYearReq = CreateAcademicYearRequest(
        name: 'AY 2028',
        startDate: '2028-01-01',
        endDate: '2028-12-31',
      );
      expect(createYearReq.toJson()['name'], 'AY 2028');

      final addTermReq = AddAcademicTermRequest(
        name: 'Term A',
        displayName: 'Term A 2028',
        type: 'SEMESTER_1',
        startDate: '2028-01-01',
        endDate: '2028-06-01',
      );
      expect(addTermReq.toJson()['type'], 'SEMESTER_1');
    });
  });
}
