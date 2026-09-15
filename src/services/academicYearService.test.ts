import { describe, it, expect, beforeEach } from 'bun:test';
import { academicYearService } from './academicYearService';
import { apiClient } from './apiClient';

describe('AcademicYearService', () => {
  beforeEach(() => {
    apiClient.setMockMode(true);
    apiClient.setTenantId('tenant-lincoln-high-001');
  });

  it('should list academic years and get active academic year', async () => {
    const list = await academicYearService.listAcademicYears();
    expect(list.length).toBeGreaterThan(0);

    const active = await academicYearService.getActiveAcademicYear();
    expect(active).toBeDefined();
    expect(active?.status).toBe('ACTIVE');
    expect(active?.terms.length).toBeGreaterThan(0);
  });

  it('should create an academic year, add terms and activate them', async () => {
    const created = await academicYearService.createAcademicYear({
      name: 'Academic Year 2028/2029',
      startDate: '2028-07-15',
      endDate: '2029-06-25'
    });

    expect(created.name).toBe('Academic Year 2028/2029');
    expect(created.status).toBe('UPCOMING');

    const term = await academicYearService.addTerm(created.id, {
      name: 'Semester 1 (Ganjil)',
      type: 'SEMESTER_1',
      displayName: 'Semester Ganjil 2028',
      startDate: '2028-07-15',
      endDate: '2028-12-20'
    });

    expect(term.displayName).toBe('Semester Ganjil 2028');

    const activatedYear = await academicYearService.activateYear(created.id);
    expect(activatedYear.status).toBe('ACTIVE');

    const activeYearCheck = await academicYearService.getActiveAcademicYear();
    expect(activeYearCheck?.id).toBe(created.id);
  });
});
