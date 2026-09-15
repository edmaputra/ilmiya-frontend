import React, { useState } from 'react';
import { Shield, Building2, Server, Settings2, CheckCircle2, AlertCircle, RefreshCw, Key } from 'lucide-react';
import { apiClient } from '../services/apiClient';
import { iamService } from '../services/iamService';
import { UserProfileResponse } from '../types/iam';

interface ApiStatusBarProps {
  currentTenantId: string;
  onTenantChange: (newTenantId: string) => void;
  currentUserProfile?: UserProfileResponse | null;
  onRefreshData: () => void;
  onOpenAuthModal?: () => void;
}

export const ApiStatusBar: React.FC<ApiStatusBarProps> = ({
  currentTenantId,
  onTenantChange,
  currentUserProfile,
  onRefreshData,
  onOpenAuthModal
}) => {
  const [showSettingsModal, setShowSettingsModal] = useState(false);
  const [showTenantModal, setShowTenantModal] = useState(false);

  // Form states
  const [apiUrl, setApiUrl] = useState(apiClient.baseUrl);
  const [mockMode, setMockMode] = useState(apiClient.isMockMode);
  const [targetTenantInput, setTargetTenantInput] = useState(currentTenantId);
  const [authTokenInput, setAuthTokenInput] = useState(apiClient.token || '');
  const [isTestingConnection, setIsTestingConnection] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState<'idle' | 'success' | 'failed'>('idle');
  const [statusMessage, setStatusMessage] = useState('');

  const handleSaveSettings = () => {
    apiClient.setBaseUrl(apiUrl);
    apiClient.setMockMode(mockMode);
    apiClient.setToken(authTokenInput.trim() ? authTokenInput.trim() : null);
    setShowSettingsModal(false);
    onRefreshData();
  };

  const handleTestConnection = async () => {
    setIsTestingConnection(true);
    setConnectionStatus('idle');
    try {
      const response = await fetch(`${apiUrl.replace(/\/+$/, '')}/api/v1/schools/profile`, {
        headers: {
          'X-Tenant-ID': currentTenantId,
          ...(authTokenInput ? { Authorization: `Bearer ${authTokenInput}` } : {})
        }
      });
      if (response.ok || response.status === 401 || response.status === 403) {
        setConnectionStatus('success');
        setStatusMessage(`Connected! Server responded with HTTP ${response.status}`);
      } else {
        setConnectionStatus('failed');
        setStatusMessage(`Server reached but returned HTTP ${response.status}`);
      }
    } catch (err: any) {
      setConnectionStatus('failed');
      setStatusMessage(err.message || 'Cannot reach server. Ensure backend is running.');
    } finally {
      setIsTestingConnection(false);
    }
  };

  const handleSwitchTenant = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!targetTenantInput.trim()) return;
    try {
      await iamService.switchTenant(targetTenantInput.trim());
      onTenantChange(targetTenantInput.trim());
      setShowTenantModal(false);
      onRefreshData();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <>
      <div className="bg-[#FAF9F6] border-b border-[#E9E4DB] px-4 py-2 text-xs text-[#6B6E68]">
        <div className="max-w-7xl mx-auto flex flex-wrap items-center justify-between gap-3">
          
          {/* Active Tenant and Actor Badge */}
          <div className="flex items-center gap-3">
            <button
              onClick={() => setShowTenantModal(true)}
              className="flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-[#FEFAE0] border border-[#E9E4DB] hover:border-[#A9B388] text-[#5F6F52] font-semibold transition-all cursor-pointer"
              title="Click to switch active tenant"
            >
              <Building2 className="w-3.5 h-3.5" />
              <span>Tenant:</span>
              <code className="text-[#2C2E2A] font-mono text-[11px]">{currentTenantId}</code>
              <RefreshCw className="w-2.5 h-2.5 text-[#8C887D] ml-0.5" />
            </button>

            {currentUserProfile ? (
              <button
                onClick={onOpenAuthModal}
                className="hidden sm:flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-white border border-[#E9E4DB] hover:border-[#A9B388] text-[#2C2E2A] transition cursor-pointer"
                title="Click to switch persona or manage session"
              >
                <Shield className="w-3.5 h-3.5 text-[#5F6F52]" />
                <span className="text-[#8C887D]">Actor:</span>
                <span className="font-semibold truncate max-w-[160px]">{currentUserProfile.fullName}</span>
                <span className="text-[10px] uppercase font-bold bg-[#5F6F52] text-white px-1.5 py-0.2 rounded">
                  {currentUserProfile.roles[0] || 'USER'}
                </span>
                <Key className="w-2.5 h-2.5 text-[#8C887D] ml-0.5" />
              </button>
            ) : (
              <button
                onClick={onOpenAuthModal}
                className="flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43] transition cursor-pointer text-xs shadow-xs"
              >
                <Key className="w-3.5 h-3.5" />
                <span>Sign In / Demo</span>
              </button>
            )}
          </div>

          {/* Backend Status & Mode Selector */}
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-white border border-[#E9E4DB]">
              <Server className="w-3.5 h-3.5 text-[#5F6F52]" />
              <span className="text-[#8C887D]">Mode:</span>
              <span className={`font-semibold flex items-center gap-1 ${mockMode ? 'text-[#B99470]' : 'text-[#5F6F52]'}`}>
                <span className={`w-1.5 h-1.5 rounded-full ${mockMode ? 'bg-[#B99470]' : 'bg-emerald-500 animate-pulse'}`} />
                {mockMode ? 'Mock Simulation' : 'Live REST API'}
              </span>
            </div>

            <button
              onClick={() => setShowSettingsModal(true)}
              className="flex items-center gap-1 px-2.5 py-1 rounded-xl bg-[#FAF9F6] border border-[#D9D1C5] hover:bg-[#E9E4DB] text-[#2C2E2A] font-medium transition-all cursor-pointer"
            >
              <Settings2 className="w-3.5 h-3.5" />
              <span>API Settings</span>
            </button>
          </div>

        </div>
      </div>

      {/* Switch Tenant Modal */}
      {showTenantModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-md w-full p-6 shadow-2xl animate-fade-in">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Building2 className="w-5 h-5 text-[#5F6F52]" />
                <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Switch Active Tenant</h3>
              </div>
              <button
                onClick={() => setShowTenantModal(false)}
                className="text-[#8C887D] hover:text-[#2C2E2A] p-1 cursor-pointer"
              >
                ✕
              </button>
            </div>

            <p className="text-xs text-[#6B6E68] mb-4">
              Tenant context propagates through the <code className="bg-[#FAF9F6] px-1 py-0.5 rounded border border-[#E9E4DB]">X-Tenant-ID</code> HTTP header and triggers backend tenant context switching (<code className="bg-[#FAF9F6] px-1 py-0.5 rounded border border-[#E9E4DB]">/api/v1/auth/switch-tenant</code>).
            </p>

            <form onSubmit={handleSwitchTenant} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Tenant ID (Identifier or UUID)</label>
                <input
                  type="text"
                  value={targetTenantInput}
                  onChange={(e) => setTargetTenantInput(e.target.value)}
                  placeholder="e.g. tenant-lincoln-high-001 or 550e8400-e29b-41d4-a716-446655440000"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] focus:outline-none focus:border-[#5F6F52] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div className="pt-2 flex items-center justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowTenantModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68] hover:bg-[#FAF9F6] cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43] transition-colors cursor-pointer"
                >
                  Switch Tenant
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* API Settings Modal */}
      {showSettingsModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-lg w-full p-6 shadow-2xl animate-fade-in">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Settings2 className="w-5 h-5 text-[#5F6F52]" />
                <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Backend API Configuration</h3>
              </div>
              <button
                onClick={() => setShowSettingsModal(false)}
                className="text-[#8C887D] hover:text-[#2C2E2A] p-1 cursor-pointer"
              >
                ✕
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Backend Base URL</label>
                <input
                  type="text"
                  value={apiUrl}
                  onChange={(e) => setApiUrl(e.target.value)}
                  placeholder="http://localhost:8080"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] focus:outline-none focus:border-[#5F6F52] bg-[#FAF9F6]"
                />
                <p className="text-[11px] text-[#8C887D] mt-1">
                  Connects to Spring Boot 4 / ed-iam API services.
                </p>
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Execution Mode</label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => setMockMode(true)}
                    className={`p-3 rounded-xl border text-left cursor-pointer transition-all ${
                      mockMode
                        ? 'border-[#5F6F52] bg-[#FEFAE0]/70 text-[#2C2E2A]'
                        : 'border-[#E9E4DB] hover:bg-[#FAF9F6] text-[#6B6E68]'
                    }`}
                  >
                    <div className="font-semibold text-xs">Mock Simulation</div>
                    <div className="text-[10px] text-[#8C887D] mt-0.5">In-browser stateful persistence (no backend needed)</div>
                  </button>

                  <button
                    type="button"
                    onClick={() => setMockMode(false)}
                    className={`p-3 rounded-xl border text-left cursor-pointer transition-all ${
                      !mockMode
                        ? 'border-[#5F6F52] bg-[#FEFAE0]/70 text-[#2C2E2A]'
                        : 'border-[#E9E4DB] hover:bg-[#FAF9F6] text-[#6B6E68]'
                    }`}
                  >
                    <div className="font-semibold text-xs">Live REST Backend</div>
                    <div className="text-[10px] text-[#8C887D] mt-0.5">Issues HTTP requests to {apiUrl}</div>
                  </button>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">JWT Bearer Token (Optional)</label>
                <div className="relative">
                  <input
                    type="password"
                    value={authTokenInput}
                    onChange={(e) => setAuthTokenInput(e.target.value)}
                    placeholder="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] focus:outline-none focus:border-[#5F6F52] bg-[#FAF9F6] font-mono pr-8"
                  />
                  <Key className="w-3.5 h-3.5 text-[#8C887D] absolute right-2.5 top-2.5" />
                </div>
              </div>

              {/* Test Connection Button and Feedback */}
              <div className="pt-2 border-t border-[#E9E4DB] flex items-center justify-between">
                <button
                  type="button"
                  onClick={handleTestConnection}
                  disabled={isTestingConnection}
                  className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-[#D9D1C5] text-xs font-medium hover:bg-[#FAF9F6] cursor-pointer disabled:opacity-50"
                >
                  <RefreshCw className={`w-3 h-3 ${isTestingConnection ? 'animate-spin' : ''}`} />
                  <span>Test Connection</span>
                </button>

                {connectionStatus === 'success' && (
                  <span className="flex items-center gap-1 text-[11px] text-emerald-600 font-medium">
                    <CheckCircle2 className="w-3.5 h-3.5" />
                    {statusMessage}
                  </span>
                )}
                {connectionStatus === 'failed' && (
                  <span className="flex items-center gap-1 text-[11px] text-amber-600 font-medium">
                    <AlertCircle className="w-3.5 h-3.5" />
                    {statusMessage}
                  </span>
                )}
              </div>

              <div className="pt-4 flex items-center justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowSettingsModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68] hover:bg-[#FAF9F6] cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleSaveSettings}
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43] transition-colors cursor-pointer"
                >
                  Apply & Save
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};
