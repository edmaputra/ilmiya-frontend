import React, { useState } from 'react';
import { 
  Shield, 
  Lock, 
  Mail, 
  Building2, 
  UserCheck, 
  GraduationCap, 
  Users, 
  BookOpen, 
  HeartHandshake, 
  ArrowRight, 
  AlertCircle, 
  Eye, 
  EyeOff, 
  Server,
  Sparkles,
  CheckCircle2
} from 'lucide-react';
import { useAuth, DEMO_PERSONAS, DemoPersonaKey } from '../context/AuthContext';
import { apiClient } from '../services/apiClient';

interface LoginViewProps {
  onSuccess?: () => void;
  isModal?: boolean;
  onClose?: () => void;
}

export const LoginView: React.FC<LoginViewProps> = ({ onSuccess, isModal = false, onClose }) => {
  const { login, loginAsPersona, isLoading, error, clearError, user, isAuthenticated, logout } = useAuth();
  
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [tenantId, setTenantId] = useState(apiClient.tenantId);
  const [showPassword, setShowPassword] = useState(false);
  const [activePersonaKey, setActivePersonaKey] = useState<DemoPersonaKey | null>(null);
  const [localError, setLocalError] = useState<string | null>(null);

  const personaIcons: Record<DemoPersonaKey, React.ReactNode> = {
    superadmin: <Shield className="w-5 h-5 text-[#5F6F52]" />,
    principal: <Building2 className="w-5 h-5 text-[#2C2E2A]" />,
    teacher: <BookOpen className="w-5 h-5 text-[#5F6F52]" />,
    student: <GraduationCap className="w-5 h-5 text-[#B99470]" />,
    parent: <HeartHandshake className="w-5 h-5 text-[#D67D5B]" />
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLocalError(null);
    clearError();

    if (!email.trim() || !password.trim()) {
      setLocalError('Please enter both email and password.');
      return;
    }

    try {
      await login({
        email: email.trim(),
        password,
        tenantId: tenantId.trim() || apiClient.tenantId
      });
      if (onSuccess) onSuccess();
      if (isModal && onClose) onClose();
    } catch (err: any) {
      setLocalError(err.message || 'Authentication failed. Please verify credentials.');
    }
  };

  const handlePersonaClick = async (key: DemoPersonaKey) => {
    setActivePersonaKey(key);
    setLocalError(null);
    clearError();
    try {
      await loginAsPersona(key);
      if (onSuccess) onSuccess();
      if (isModal && onClose) onClose();
    } catch (err: any) {
      setLocalError(err.message || 'Failed to authenticate persona.');
    } finally {
      setActivePersonaKey(null);
    }
  };

  const currentErrorMessage = localError || error;

  const content = (
    <div className="w-full max-w-4xl mx-auto space-y-8">
      {/* Header Banner */}
      <div className="text-center space-y-3">
        <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-[#FEFAE0] border border-[#E9E4DB] text-[#5F6F52] text-xs font-semibold tracking-wide uppercase">
          <Sparkles className="w-3.5 h-3.5" />
          ed-iam Security & Access Management
        </div>
        <h2 className="text-3xl sm:text-4xl font-serif font-bold text-[#2C2E2A] tracking-tight">
          Ilmiya Institutional Portal
        </h2>
        <p className="text-sm text-[#6B6E68] max-w-xl mx-auto leading-relaxed">
          Stateless JWT token authentication with multi-tenant tenancy, granular RBAC permission matrix, and automatic session refresh.
        </p>
      </div>

      {/* Error Banner */}
      {currentErrorMessage && (
        <div className="bg-red-50/90 border border-red-200 text-red-800 rounded-2xl p-4 text-xs sm:text-sm flex items-start gap-3 shadow-xs animate-shake">
          <AlertCircle className="w-5 h-5 text-red-500 shrink-0 mt-0.5" />
          <div className="flex-1">
            <span className="font-semibold">Authentication Error:</span> {currentErrorMessage}
          </div>
          <button 
            onClick={() => { setLocalError(null); clearError(); }} 
            className="text-red-400 hover:text-red-700 cursor-pointer font-bold"
          >
            ✕
          </button>
        </div>
      )}

      {/* Currently logged-in indicator if opened in modal */}
      {isAuthenticated && user && (
        <div className="bg-white border border-[#D9D1C5] rounded-2xl p-4 shadow-xs flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-[#5F6F52] text-white flex items-center justify-center font-serif font-bold text-sm">
              {user.fullName.charAt(0)}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-sm font-bold text-[#2C2E2A]">{user.fullName}</span>
                <span className="text-[10px] uppercase font-bold bg-[#FEFAE0] text-[#5F6F52] px-2 py-0.5 rounded border border-[#E9E4DB]">
                  {user.roles[0] || 'USER'}
                </span>
              </div>
              <p className="text-xs text-[#6B6E68]">{user.email} • Tenant: <code className="font-mono">{user.tenantId}</code></p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <span className="text-xs text-emerald-600 flex items-center gap-1 font-medium">
              <CheckCircle2 className="w-3.5 h-3.5" /> Signed In
            </span>
            <button
              onClick={logout}
              className="text-xs font-semibold px-3 py-1.5 rounded-xl border border-[#D9D1C5] text-[#2C2E2A] hover:bg-[#FAF9F6] transition cursor-pointer"
            >
              Sign Out
            </button>
          </div>
        </div>
      )}

      {/* Main Grid: 1-Click Demo Personas & Manual Login Form */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        
        {/* Left Column: 1-Click Demo Personas */}
        <div className="lg:col-span-7 space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-base font-serif font-bold text-[#2C2E2A] flex items-center gap-2">
              <UserCheck className="w-4 h-4 text-[#5F6F52]" />
              1-Click Demo Personas
            </h3>
            <span className="text-xs text-[#8C887D]">Instantly test RBAC roles</span>
          </div>

          <p className="text-xs text-[#6B6E68]">
            Select an institutional profile below to evaluate user privileges, access-controlled views, and scoped operational actions.
          </p>

          <div className="grid grid-cols-1 gap-3">
            {(Object.keys(DEMO_PERSONAS) as DemoPersonaKey[]).map(key => {
              const persona = DEMO_PERSONAS[key];
              const isSelected = activePersonaKey === key || (user?.email === persona.email);
              return (
                <button
                  key={key}
                  type="button"
                  disabled={isLoading}
                  onClick={() => handlePersonaClick(key)}
                  className={`w-full text-left p-4 rounded-2xl border transition-all duration-200 cursor-pointer flex items-start justify-between gap-4 ${
                    isSelected 
                      ? 'bg-[#FEFAE0]/70 border-[#5F6F52] shadow-[0_4px_16px_rgba(95,111,82,0.12)] ring-1 ring-[#5F6F52]' 
                      : 'bg-white border-[#E9E4DB] hover:border-[#A9B388] hover:shadow-sm'
                  }`}
                >
                  <div className="flex items-start gap-3.5">
                    <div className="p-2.5 rounded-xl bg-[#FAF9F6] border border-[#E9E4DB] mt-0.5">
                      {personaIcons[key]}
                    </div>
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-serif font-bold text-[#2C2E2A]">{persona.name}</span>
                        <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${persona.badgeColor}`}>
                          {persona.roleLabel}
                        </span>
                      </div>
                      <p className="text-xs text-[#8C887D] font-mono">{persona.email}</p>
                      <p className="text-[11px] text-[#6B6E68] leading-relaxed">{persona.description}</p>
                    </div>
                  </div>
                  <div className="shrink-0 mt-1">
                    {activePersonaKey === key && isLoading ? (
                      <div className="w-5 h-5 border-2 border-[#5F6F52] border-t-transparent rounded-full animate-spin" />
                    ) : (
                      <div className="w-8 h-8 rounded-full flex items-center justify-center bg-[#FAF9F6] text-[#5F6F52] border border-[#E9E4DB] group-hover:bg-[#FEFAE0]">
                        <ArrowRight className="w-4 h-4" />
                      </div>
                    )}
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Right Column: Manual Sign In Form */}
        <div className="lg:col-span-5 bg-white border border-[#D9D1C5] rounded-[24px] p-6 sm:p-7 shadow-sm space-y-5 flex flex-col justify-between">
          <div className="space-y-4">
            <div>
              <h3 className="text-base font-serif font-bold text-[#2C2E2A] flex items-center gap-2">
                <Lock className="w-4 h-4 text-[#5F6F52]" />
                Standard Credentials
              </h3>
              <p className="text-xs text-[#6B6E68] mt-1">
                Authenticate against the live Spring Boot API or local mock engine.
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-[#2C2E2A] flex items-center gap-1.5">
                  <Mail className="w-3.5 h-3.5 text-[#8C887D]" />
                  Institutional Email
                </label>
                <input
                  type="email"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  placeholder="name@ilmiya.edu"
                  required
                  className="w-full px-3.5 py-2.5 rounded-xl border border-[#D9D1C5] bg-[#FAF9F6] focus:bg-white focus:outline-none focus:border-[#5F6F52] text-xs sm:text-sm text-[#2C2E2A] transition"
                />
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-[#2C2E2A] flex items-center gap-1.5">
                  <Lock className="w-3.5 h-3.5 text-[#8C887D]" />
                  Password
                </label>
                <div className="relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    placeholder="••••••••"
                    required
                    className="w-full px-3.5 py-2.5 pr-10 rounded-xl border border-[#D9D1C5] bg-[#FAF9F6] focus:bg-white focus:outline-none focus:border-[#5F6F52] text-xs sm:text-sm text-[#2C2E2A] transition"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer"
                  >
                    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-[#2C2E2A] flex items-center gap-1.5">
                  <Building2 className="w-3.5 h-3.5 text-[#8C887D]" />
                  School Tenant ID
                </label>
                <input
                  type="text"
                  value={tenantId}
                  onChange={e => setTenantId(e.target.value)}
                  placeholder="tenant-lincoln-high-001"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-[#D9D1C5] bg-[#FAF9F6] focus:bg-white focus:outline-none focus:border-[#5F6F52] text-xs sm:text-sm font-mono text-[#2C2E2A] transition"
                />
                <p className="text-[11px] text-[#8C887D]">
                  Sent in <code className="bg-[#FAF9F6] px-1 py-0.5 rounded border border-[#E9E4DB]">X-Tenant-ID</code> header.
                </p>
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full py-3 px-4 rounded-xl bg-[#5F6F52] hover:bg-[#4d5b42] text-white font-semibold text-xs sm:text-sm shadow-sm hover:shadow-md transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50"
              >
                {isLoading ? (
                  <>
                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                    <span>Signing In...</span>
                  </>
                ) : (
                  <>
                    <span>Sign In to Portal</span>
                    <ArrowRight className="w-4 h-4" />
                  </>
                )}
              </button>
            </form>
          </div>

          {/* Engine Status Note */}
          <div className="pt-4 border-t border-[#E9E4DB] flex items-center justify-between text-[11px] text-[#6B6E68]">
            <div className="flex items-center gap-1.5">
              <Server className="w-3.5 h-3.5 text-[#5F6F52]" />
              <span>Target:</span>
              <span className="font-semibold text-[#2C2E2A]">
                {apiClient.isMockMode ? 'Mock Simulator' : 'Live REST API'}
              </span>
            </div>
            <span className="text-[#8C887D]">JWT Bearer</span>
          </div>
        </div>

      </div>
    </div>
  );

  if (isModal) {
    return (
      <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
        <div className="bg-[#FAF9F6] rounded-[28px] border border-[#D9D1C5] max-w-4xl w-full p-6 sm:p-8 shadow-2xl relative my-auto">
          {onClose && (
            <button
              onClick={onClose}
              className="absolute top-5 right-5 text-[#8C887D] hover:text-[#2C2E2A] p-2 rounded-full hover:bg-[#E9E4DB] transition cursor-pointer"
            >
              ✕
            </button>
          )}
          {content}
        </div>
      </div>
    );
  }

  return (
    <div className="py-8 px-4 sm:px-6">
      {content}
    </div>
  );
};
