import { describe, it, expect, beforeEach } from 'bun:test';
import { schoolService } from './schoolService';
import { apiClient } from './apiClient';

describe('SchoolService', () => {
  beforeEach(() => {
    apiClient.setMockMode(true);
    apiClient.setTenantId('tenant-lincoln-high-001');
  });

  it('should fetch school profile', async () => {
    const profile = await schoolService.getProfile();
    expect(profile).toBeDefined();
    expect(profile.tenantId).toBe('tenant-lincoln-high-001');
    expect(profile.name).toContain('SMA Negeri 1 Ilmiya');
    expect(profile.accreditationStatus).toBe('ACCREDITED_A');
  });

  it('should update school profile metadata', async () => {
    const updated = await schoolService.updateProfile({
      name: 'SMA Negeri 1 Ilmiya (Updated Campus)',
      address: 'Jl. Melawai Raya No. 10',
      contactEmail: 'info@ilmiya-updated.edu',
      contactPhone: '+62 21 5555 1234'
    });

    expect(updated.name).toBe('SMA Negeri 1 Ilmiya (Updated Campus)');
    expect(updated.contactEmail).toBe('info@ilmiya-updated.edu');
  });

  it('should configure operational settings', async () => {
    const configured = await schoolService.configureSettings({
      workingDays: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
      gradingPreference: 'LETTER_A_F',
      termLayout: 'SEMESTER'
    });

    expect(configured.gradingPreference).toBe('LETTER_A_F');
    expect(configured.termLayout).toBe('SEMESTER');
  });

  it('should register a new school tenant', async () => {
    const newSchool = await schoolService.registerSchool({
      tenantId: 'tenant-islamic-boarding-01',
      name: 'Pesantren Modern Darul Ilmi',
      institutionCode: 'NPSN-50109923',
      address: 'Jl. Pesantren Luhur No. 7, Bogor',
      contactEmail: 'admin@darul-ilmi.ac.id',
      contactPhone: '+62 251 8888 9999',
      workingDays: ['SATURDAY', 'SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY'],
      gradingPreference: 'DESCRIPTIVE_KURIKULUM_MERDEKA',
      termLayout: 'SEMESTER'
    });

    expect(newSchool.tenantId).toBe('tenant-islamic-boarding-01');
    expect(newSchool.name).toBe('Pesantren Modern Darul Ilmi');
  });
});
