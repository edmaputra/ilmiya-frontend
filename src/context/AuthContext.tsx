import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { apiClient } from '../services/apiClient';
import { iamService } from '../services/iamService';
import { UserProfileResponse, LoginRequest } from '../types/iam';

export type DemoPersonaKey = 'superadmin' | 'principal' | 'teacher' | 'student' | 'parent';

export interface DemoPersona {
  key: DemoPersonaKey;
  name: string;
  roleLabel: string;
  email: string;
  description: string;
  badgeColor: string;
}

export const DEMO_PERSONAS: Record<DemoPersonaKey, DemoPersona> = {
  superadmin: {
    key: 'superadmin',
    name: 'Dr. Sarah Jenkins',
    roleLabel: 'Platform SuperAdmin',
    email: 'admin.utama@ilmiya.edu',
    description: 'Unrestricted master access across all bounded contexts, scopes, and tenants.',
    badgeColor: 'bg-[#5F6F52] text-white'
  },
  principal: {
    key: 'principal',
    name: 'Prof. Marcus Chen',
    roleLabel: 'School Principal',
    email: 'principal@ilmiya.edu',
    description: 'Institutional management, academic year rollovers, settings, and user provisioning.',
    badgeColor: 'bg-[#2C2E2A] text-[#FEFAE0]'
  },
  teacher: {
    key: 'teacher',
    name: 'Dr. Eleanor Vance',
    roleLabel: 'Senior Faculty',
    email: 'eleanor.vance@ilmiya.edu',
    description: 'Course management, grading, attendance tracking, and report cards.',
    badgeColor: 'bg-[#A9B388] text-[#2C2E2A]'
  },
  student: {
    key: 'student',
    name: 'Alex Rivera',
    roleLabel: 'Student (Class 10-A)',
    email: 'alex.rivera@student.ilmiya.edu',
    description: 'Student portal, schedule review, grade viewing, and attendance logs.',
    badgeColor: 'bg-[#B99470] text-white'
  },
  parent: {
    key: 'parent',
    name: 'Elena Rivera',
    roleLabel: 'Parent / Guardian',
    email: 'elena.rivera@parent.ilmiya.edu',
    description: 'Family portal, student attendance oversight, and term grade cards.',
    badgeColor: 'bg-[#D67D5B] text-white'
  }
};

export function checkPermission(userPermissions: string[], userRoles: string[], targetPermission: string): boolean {
  if (userRoles.some(r => r.toUpperCase() === 'SUPERADMIN') || userPermissions.includes('*')) {
    return true;
  }
  return userPermissions.some(perm => {
    if (perm === targetPermission) return true;
    if (perm.endsWith(':*')) {
      const prefix = perm.slice(0, -2);
      return targetPermission === prefix || targetPermission.startsWith(prefix + ':');
    }
    if (perm.endsWith('*')) {
      const prefix = perm.slice(0, -1);
      return targetPermission.startsWith(prefix);
    }
    return false;
  });
}

export interface AuthContextType {
  isAuthenticated: boolean;
  user: UserProfileResponse | null;
  tenantId: string;
  token: string | null;
  roles: string[];
  permissions: string[];
  isLoading: boolean;
  error: string | null;
  login: (credentials: LoginRequest) => Promise<void>;
  loginAsPersona: (personaKey: DemoPersonaKey) => Promise<void>;
  logout: () => void;
  switchTenant: (tenantId: string) => Promise<void>;
  hasPermission: (permission: string) => boolean;
  hasRole: (role: string) => boolean;
  refreshProfile: () => Promise<void>;
  clearError: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<UserProfileResponse | null>(null);
  const [tenantId, setTenantId] = useState<string>(apiClient.tenantId);
  const [token, setToken] = useState<string | null>(apiClient.token);
  const [roles, setRoles] = useState<string[]>([]);
  const [permissions, setPermissions] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const refreshProfile = useCallback(async () => {
    try {
      setIsLoading(true);
      const profile = await iamService.getMe();
      setUser(profile);
      setTenantId(profile.tenantId || apiClient.tenantId);
      setRoles(profile.roles || []);
      setPermissions(profile.permissions || []);
      setToken(apiClient.token);
      setError(null);
    } catch (err: any) {
      console.warn('Failed to refresh actor profile:', err);
      // If we couldn't get profile and have no token, user is not authenticated
      if (!apiClient.token && !apiClient.isMockMode) {
        setUser(null);
        setRoles([]);
        setPermissions([]);
      }
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    // Initial mount hydration
    refreshProfile();

    // Listen for session expiry from apiClient 401 handler
    const unsubscribe = apiClient.onAuthExpired(() => {
      setUser(null);
      setToken(null);
      setRoles([]);
      setPermissions([]);
      setError('Your session has expired. Please sign in again.');
    });

    return () => {
      unsubscribe();
    };
  }, [refreshProfile]);

  const login = async (credentials: LoginRequest) => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await iamService.login(credentials);
      setToken(response.accessToken);
      setTenantId(response.tenantId || apiClient.tenantId);
      setRoles(response.roles);
      setPermissions(response.permissions);
      await refreshProfile();
    } catch (err: any) {
      setError(err.message || 'Login failed. Please check your credentials.');
      throw err;
    } finally {
      setIsLoading(false);
    }
  };

  const loginAsPersona = async (personaKey: DemoPersonaKey) => {
    const persona = DEMO_PERSONAS[personaKey];
    if (!persona) return;
    await login({
      email: persona.email,
      password: `${persona.key.charAt(0).toUpperCase() + persona.key.slice(1)}@123`,
      tenantId: apiClient.tenantId
    });
  };

  const logout = () => {
    iamService.logout();
    setUser(null);
    setToken(null);
    setRoles([]);
    setPermissions([]);
    setError(null);
  };

  const switchTenant = async (newTenantId: string) => {
    setIsLoading(true);
    try {
      const response = await iamService.switchTenant(newTenantId);
      setTenantId(response.tenantId || newTenantId);
      setRoles(response.roles);
      setPermissions(response.permissions);
      await refreshProfile();
    } catch (err: any) {
      setError(err.message || `Failed to switch tenant to ${newTenantId}`);
      throw err;
    } finally {
      setIsLoading(false);
    }
  };

  const hasPermission = useCallback((permission: string): boolean => {
    return checkPermission(permissions, roles, permission);
  }, [permissions, roles]);

  const hasRole = useCallback((role: string): boolean => {
    const normalized = role.toUpperCase();
    return roles.some(r => r.toUpperCase() === normalized);
  }, [roles]);

  const clearError = () => setError(null);

  const isAuthenticated = Boolean(user && (token || apiClient.isMockMode));

  return (
    <AuthContext.Provider
      value={{
        isAuthenticated,
        user,
        tenantId,
        token,
        roles,
        permissions,
        isLoading,
        error,
        login,
        loginAsPersona,
        logout,
        switchTenant,
        hasPermission,
        hasRole,
        refreshProfile,
        clearError
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
