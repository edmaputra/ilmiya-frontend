/**
 * Academic Year & Term Configuration Service.
 * Interacts with Ilmiya backend /api/v1/academic-years endpoints.
 */

import { apiClient } from './apiClient';
import { mockStorage } from './mockStorage';
import {
  AcademicYearResponse,
  AcademicTermResponse,
  CreateAcademicYearRequest,
  AddAcademicTermRequest
} from '../types/ilmiya';

export class AcademicYearService {
  /**
   * Creates a new academic year under the current tenant context.
   * POST /api/v1/academic-years
   */
  public async createAcademicYear(request: CreateAcademicYearRequest): Promise<AcademicYearResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.createAcademicYear(request, apiClient.tenantId);
    }

    try {
      return await apiClient.request<AcademicYearResponse>('/api/v1/academic-years', {
        method: 'POST',
        body: JSON.stringify(request)
      });
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock storage for createAcademicYear:', err);
      return mockStorage.createAcademicYear(request, apiClient.tenantId);
    }
  }

  /**
   * Lists all academic years for the current tenant.
   * GET /api/v1/academic-years
   */
  public async listAcademicYears(): Promise<AcademicYearResponse[]> {
    if (apiClient.isMockMode) {
      return mockStorage.listAcademicYears(apiClient.tenantId);
    }

    try {
      return await apiClient.request<AcademicYearResponse[]>('/api/v1/academic-years', {
        method: 'GET'
      });
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock storage for listAcademicYears:', err);
      return mockStorage.listAcademicYears(apiClient.tenantId);
    }
  }

  /**
   * Retrieves the currently active academic year for the tenant.
   * GET /api/v1/academic-years/active
   */
  public async getActiveAcademicYear(): Promise<AcademicYearResponse | null> {
    if (apiClient.isMockMode) {
      return mockStorage.getActiveAcademicYear(apiClient.tenantId);
    }

    try {
      return await apiClient.request<AcademicYearResponse>('/api/v1/academic-years/active', {
        method: 'GET'
      });
    } catch (err: any) {
      if (err?.status === 404) return null;
      console.warn('Backend unavailable, falling back to mock storage for getActiveAcademicYear:', err);
      return mockStorage.getActiveAcademicYear(apiClient.tenantId);
    }
  }

  /**
   * Retrieves a single academic year by its ID.
   * GET /api/v1/academic-years/{id}
   */
  public async getById(id: string): Promise<AcademicYearResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.getAcademicYearById(id);
    }

    try {
      return await apiClient.request<AcademicYearResponse>(`/api/v1/academic-years/${id}`, {
        method: 'GET'
      });
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock storage for getById:', err);
      return mockStorage.getAcademicYearById(id);
    }
  }

  /**
   * Activates an academic year, archiving any currently active year.
   * PUT /api/v1/academic-years/{id}/activate
   */
  public async activateYear(id: string): Promise<AcademicYearResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.activateAcademicYear(id);
    }

    try {
      return await apiClient.request<AcademicYearResponse>(`/api/v1/academic-years/${id}/activate`, {
        method: 'PUT'
      });
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock storage for activateYear:', err);
      return mockStorage.activateAcademicYear(id);
    }
  }

  /**
   * Adds an academic term/semester to an academic year.
   * POST /api/v1/academic-years/{id}/terms
   */
  public async addTerm(yearId: string, request: AddAcademicTermRequest): Promise<AcademicTermResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.addAcademicTerm(yearId, request);
    }

    try {
      return await apiClient.request<AcademicTermResponse>(`/api/v1/academic-years/${yearId}/terms`, {
        method: 'POST',
        body: JSON.stringify(request)
      });
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock storage for addTerm:', err);
      return mockStorage.addAcademicTerm(yearId, request);
    }
  }

  /**
   * Activates an academic term within an academic year.
   * PUT /api/v1/academic-years/{id}/terms/{termId}/activate
   */
  public async activateTerm(yearId: string, termId: string): Promise<AcademicTermResponse> {
    if (apiClient.isMockMode) {
      return mockStorage.activateAcademicTerm(yearId, termId);
    }

    try {
      return await apiClient.request<AcademicTermResponse>(`/api/v1/academic-years/${yearId}/terms/${termId}/activate`, {
        method: 'PUT'
      });
    } catch (err) {
      console.warn('Backend unavailable, falling back to mock storage for activateTerm:', err);
      return mockStorage.activateAcademicTerm(yearId, termId);
    }
  }
}

export const academicYearService = new AcademicYearService();
