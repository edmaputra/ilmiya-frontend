import { describe, it, expect, beforeEach } from 'bun:test';
import { apiClient, ApiError } from './apiClient';

describe('ApiClient', () => {
  beforeEach(() => {
    apiClient.setBaseUrl('http://localhost:8080');
    apiClient.setTenantId('tenant-lincoln-high-001');
    apiClient.setToken('test-token-xyz');
    apiClient.setMockMode(true);
  });

  it('should store and read base URL, tenantId, and token correctly', () => {
    expect(apiClient.baseUrl).toBe('http://localhost:8080');
    expect(apiClient.tenantId).toBe('tenant-lincoln-high-001');
    expect(apiClient.token).toBe('test-token-xyz');
    expect(apiClient.isMockMode).toBe(true);
  });

  it('should trim trailing slashes from base URL', () => {
    apiClient.setBaseUrl('https://api.ilmiya.school///');
    expect(apiClient.baseUrl).toBe('https://api.ilmiya.school');
  });

  it('should support toggling mock mode', () => {
    apiClient.setMockMode(false);
    expect(apiClient.isMockMode).toBe(false);
    apiClient.setMockMode(true);
    expect(apiClient.isMockMode).toBe(true);
  });

  it('should properly instantiate ApiError', () => {
    const error = new ApiError(404, 'Resource not found', {
      status: 404,
      title: 'Not Found',
      detail: 'School tenant not found'
    });

    expect(error.status).toBe(404);
    expect(error.message).toBe('Resource not found');
    expect(error.data?.detail).toBe('School tenant not found');
  });
});
