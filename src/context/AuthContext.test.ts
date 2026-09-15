import { describe, it, expect } from 'bun:test';
import { checkPermission, DEMO_PERSONAS } from './AuthContext';

describe('AuthContext RBAC & Permissions', () => {
  it('should grant all permissions when user has SUPERADMIN role', () => {
    const permissions = ['school:profile:read'];
    const roles = ['SUPERADMIN'];

    expect(checkPermission(permissions, roles, 'school:profile:write')).toBe(true);
    expect(checkPermission(permissions, roles, 'iam:user:create')).toBe(true);
    expect(checkPermission(permissions, roles, 'finance:payment:create')).toBe(true);
  });

  it('should grant all permissions when user has wildcard * permission', () => {
    const permissions = ['*'];
    const roles = ['USER'];

    expect(checkPermission(permissions, roles, 'academic:year:write')).toBe(true);
    expect(checkPermission(permissions, roles, 'iam:role:delete')).toBe(true);
  });

  it('should resolve namespace wildcard permissions like school:* and iam:*', () => {
    const permissions = ['school:*', 'academic:year:*'];
    const roles = ['SCHOOL_ADMIN'];

    expect(checkPermission(permissions, roles, 'school:profile:read')).toBe(true);
    expect(checkPermission(permissions, roles, 'school:profile:write')).toBe(true);
    expect(checkPermission(permissions, roles, 'school:settings:manage')).toBe(true);
    expect(checkPermission(permissions, roles, 'academic:year:read')).toBe(true);
    expect(checkPermission(permissions, roles, 'academic:year:write')).toBe(true);

    // Negative tests: out-of-namespace permissions
    expect(checkPermission(permissions, roles, 'iam:user:create')).toBe(false);
    expect(checkPermission(permissions, roles, 'student:profile:write')).toBe(false);
  });

  it('should strictly evaluate exact fine-grained permissions', () => {
    const permissions = [
      'school:profile:read',
      'academic:year:read',
      'exam:grade:create'
    ];
    const roles = ['TEACHER'];

    expect(checkPermission(permissions, roles, 'school:profile:read')).toBe(true);
    expect(checkPermission(permissions, roles, 'exam:grade:create')).toBe(true);
    expect(checkPermission(permissions, roles, 'school:profile:write')).toBe(false);
    expect(checkPermission(permissions, roles, 'academic:year:write')).toBe(false);
    expect(checkPermission(permissions, roles, 'iam:user:create')).toBe(false);
  });

  it('should have all 5 predefined demo personas with required properties', () => {
    const keys = ['superadmin', 'principal', 'teacher', 'student', 'parent'] as const;
    for (const key of keys) {
      const persona = DEMO_PERSONAS[key];
      expect(persona).toBeDefined();
      expect(persona.name).toBeTruthy();
      expect(persona.email).toContain('@');
      expect(persona.roleLabel).toBeTruthy();
      expect(persona.badgeColor).toBeTruthy();
    }
  });
});
