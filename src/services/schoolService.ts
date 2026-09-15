/**
 * School Profile & Operational Settings Service.
 * Interacts with Ilmiya backend /api/v1/schools endpoints.
 */

import { apiClient } from './apiClient';
import { mockStorage } from './mockStorage';
import {
  SchoolResponse,
  RegisterSchoolRequest,
  UpdateSchoolRequest,
  ConfigureSchoolSettingsRequest
} from '../types/ilmiya';

export class SchoolService {
  /**
   * Registers a new school and tenant boundary.
   * POST /api/v1/schools
   */
  public async registerSchool(request: RegisterSchoolRequest): Promise<SchoolResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.registerSchool(request as any);
    }

    try {
      return await apiClient.request<SchoolResponse>('/api/v1/schools', {
        method: 'POST',
        body: JSON.stringify(request)
      });
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock storage for registerSchool:', err);
      return mockStorage.registerSchool(request as any);
    }
  }

  /**
   * Retrieves the institutional profile for the currently active tenant.
   * GET /api/v1/schools/profile
   */
  public async getProfile(): Promise<SchoolResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.getSchoolProfile(apiClient.tenantId);
    }

    try {
      return await apiClient.request<SchoolResponse>('/api/v1/schools/profile', {
        method: 'GET'
      });
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock storage for getProfile:', err);
      return mockStorage.getSchoolProfile(apiClient.tenantId);
    }
  }

  /**
   * Updates institutional details (name, contact, address, accreditation).
   * PUT /api/v1/schools/profile
   */
  public async updateProfile(request: UpdateSchoolRequest): Promise<SchoolResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.updateSchoolProfile(request);
    }

    try {
      return await apiClient.request<SchoolResponse>('/api/v1/schools/profile', {
        method: 'PUT',
        body: JSON.stringify(request)
      });
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock storage for updateProfile:', err);
      return mockStorage.updateSchoolProfile(request);
    }
  }

  /**
   * Updates school operational settings (working days, grading format, term layout).
   * PUT /api/v1/schools/settings
   */
  public async configureSettings(request: ConfigureSchoolSettingsRequest): Promise<SchoolResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.configureSettings(request);
    }

    try {
      return await apiClient.request<SchoolResponse>('/api/v1/schools/settings', {
        method: 'PUT',
        body: JSON.stringify(request)
      });
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock storage for configureSettings:', err);
      return mockStorage.configureSettings(request);
    }
  }
}

export const schoolService = new SchoolService();
