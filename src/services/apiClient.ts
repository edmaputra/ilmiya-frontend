/**
 * HTTP Client for Ilmiya and ed-iam Backend APIs.
 * Supports multi-tenant X-Tenant-ID headers, Bearer tokens, and RFC 9457 ProblemDetail error parsing.
 */

export interface ApiErrorDetail {
  status: number;
  title: string;
  detail?: string;
  instance?: string;
  violations?: { field: string; message: string }[];
}

export class ApiError extends Error {
  status: number;
  data?: ApiErrorDetail;

  constructor(status: number, message: string, data?: ApiErrorDetail) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.data = data;
  }
}

// In-memory fallback for test and non-browser environments
const memoryStore: Record<string, string> = {};
const safeStorage = {
  getItem: (key: string): string | null => {
    try {
      if (typeof window !== 'undefined' && window.localStorage) {
        return window.localStorage.getItem(key);
      }
    } catch {}
    return memoryStore[key] || null;
  },
  setItem: (key: string, value: string): void => {
    try {
      if (typeof window !== 'undefined' && window.localStorage) {
        window.localStorage.setItem(key, value);
        return;
      }
    } catch {}
    memoryStore[key] = value;
  },
  removeItem: (key: string): void => {
    try {
      if (typeof window !== 'undefined' && window.localStorage) {
        window.localStorage.removeItem(key);
        return;
      }
    } catch {}
    delete memoryStore[key];
  }
};

class ApiClient {
  private _baseUrl: string;
  private _tenantId: string;
  private _token: string | null;
  private _mockMode: boolean;

  constructor() {
    this._baseUrl = safeStorage.getItem('ilmiya_api_base_url') || 'http://localhost:8080';
    this._tenantId = safeStorage.getItem('ilmiya_tenant_id') || 'tenant-lincoln-high-001';
    this._token = safeStorage.getItem('ilmiya_auth_token') || null;
    // Default to mock mode if not explicitly turned off or until live backend is connected
    const savedMode = safeStorage.getItem('ilmiya_mock_mode');
    this._mockMode = savedMode !== null ? savedMode === 'true' : true;
  }

  public get baseUrl(): string {
    return this._baseUrl;
  }

  public setBaseUrl(url: string) {
    this._baseUrl = url.replace(/\/+$/, '');
    safeStorage.setItem('ilmiya_api_base_url', this._baseUrl);
  }

  public get tenantId(): string {
    return this._tenantId;
  }

  public setTenantId(tenantId: string) {
    this._tenantId = tenantId;
    safeStorage.setItem('ilmiya_tenant_id', tenantId);
  }

  public get token(): string | null {
    return this._token;
  }

  public setToken(token: string | null) {
    this._token = token;
    if (token) {
      safeStorage.setItem('ilmiya_auth_token', token);
    } else {
      safeStorage.removeItem('ilmiya_auth_token');
    }
  }

  public get isMockMode(): boolean {
    return this._mockMode;
  }

  public setMockMode(enabled: boolean) {
    this._mockMode = enabled;
    safeStorage.setItem('ilmiya_mock_mode', String(enabled));
  }

  public async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this._baseUrl}${endpoint.startsWith('/') ? endpoint : '/' + endpoint}`;

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      Accept: 'application/json',
      ...((options.headers as Record<string, string>) || {})
    };

    if (this._tenantId && !headers['X-Tenant-ID']) {
      headers['X-Tenant-ID'] = this._tenantId;
    }

    if (this._token && !headers['Authorization']) {
      headers['Authorization'] = `Bearer ${this._token}`;
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers
      });

      if (!response.ok) {
        let errorData: ApiErrorDetail | undefined;
        let message = `Request failed with status ${response.status}`;

        try {
          errorData = await response.json();
          if (errorData?.detail) {
            message = errorData.detail;
          } else if (errorData?.title) {
            message = errorData.title;
          }
        } catch {
          // If response body is not JSON
        }

        throw new ApiError(response.status, message, errorData);
      }

      if (response.status === 204) {
        return undefined as unknown as T;
      }

      return await response.json();
    } catch (err: any) {
      if (err instanceof ApiError) {
        throw err;
      }
      throw new ApiError(0, err?.message || 'Network connection error. Check if backend server is running.');
    }
  }
}

export const apiClient = new ApiClient();
