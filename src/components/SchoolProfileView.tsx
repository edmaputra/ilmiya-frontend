import React, { useState, useEffect } from 'react';
import { 
  Building2, 
  MapPin, 
  Mail, 
  Phone, 
  Award, 
  Calendar, 
  Check, 
  Sliders, 
  Edit3, 
  PlusCircle, 
  ShieldAlert, 
  ExternalLink,
  GraduationCap,
  Lock
} from 'lucide-react';
import { SchoolResponse, GradingPreference, TermLayout } from '../types/ilmiya';
import { schoolService } from '../services/schoolService';
import { useAuth } from '../context/AuthContext';

interface SchoolProfileViewProps {
  currentTenantId: string;
  onNotification: (title: string, message: string, category: 'announcement' | 'emergency') => void;
}

const ALL_DAYS = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];

export const SchoolProfileView: React.FC<SchoolProfileViewProps> = ({
  currentTenantId,
  onNotification
}) => {
  const { hasPermission } = useAuth();
  const canEditProfile = hasPermission('school:profile:write');
  const canManageSettings = hasPermission('school:settings:manage');

  const [profile, setProfile] = useState<SchoolResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Modals
  const [showEditModal, setShowEditModal] = useState(false);
  const [showSettingsModal, setShowSettingsModal] = useState(false);
  const [showRegisterModal, setShowRegisterModal] = useState(false);

  // Edit form state
  const [editName, setEditName] = useState('');
  const [editAddress, setEditAddress] = useState('');
  const [editEmail, setEditEmail] = useState('');
  const [editPhone, setEditPhone] = useState('');
  const [editLogoUrl, setEditLogoUrl] = useState('');
  const [editGovReg, setEditGovReg] = useState('');
  const [editRegType, setEditRegType] = useState('');
  const [editAccredStatus, setEditAccredStatus] = useState('ACCREDITED_A');
  const [editAccredBody, setEditAccredBody] = useState('');
  const [editAccredValid, setEditAccredValid] = useState('');

  // Settings form state
  const [selectedWorkingDays, setSelectedWorkingDays] = useState<string[]>([]);
  const [selectedGrading, setSelectedGrading] = useState<GradingPreference>('DESCRIPTIVE_KURIKULUM_MERDEKA');
  const [selectedTermLayout, setSelectedTermLayout] = useState<TermLayout>('SEMESTER');

  // Register form state
  const [regTenantId, setRegTenantId] = useState('');
  const [regName, setRegName] = useState('');
  const [regInstitutionCode, setRegInstitutionCode] = useState('');
  const [regAddress, setRegAddress] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regPhone, setRegPhone] = useState('');

  const loadProfile = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await schoolService.getProfile();
      setProfile(data);
      // Initialize edit fields
      setEditName(data.name);
      setEditAddress(data.address);
      setEditEmail(data.contactEmail);
      setEditPhone(data.contactPhone);
      setEditLogoUrl(data.logoUrl || '');
      setEditGovReg(data.governmentRegistrationNumber || '');
      setEditRegType(data.registrationType || '');
      setEditAccredStatus(data.accreditationStatus || 'UNACCREDITED');
      setEditAccredBody(data.accreditationBody || '');
      setEditAccredValid(data.accreditationValidUntil || '');

      // Initialize settings fields
      setSelectedWorkingDays(data.workingDays);
      setSelectedGrading(data.gradingPreference);
      setSelectedTermLayout(data.termLayout);
    } catch (err: any) {
      setError(err?.message || 'Failed to load school profile.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadProfile();
  }, [currentTenantId]);

  const handleUpdateProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const updated = await schoolService.updateProfile({
        name: editName,
        address: editAddress,
        contactEmail: editEmail,
        contactPhone: editPhone,
        logoUrl: editLogoUrl.trim() ? editLogoUrl.trim() : null,
        governmentRegistrationNumber: editGovReg.trim() ? editGovReg.trim() : null,
        registrationType: editRegType.trim() ? editRegType.trim() : null,
        accreditationStatus: editAccredStatus,
        accreditationBody: editAccredBody.trim() ? editAccredBody.trim() : null,
        accreditationValidUntil: editAccredValid.trim() ? editAccredValid.trim() : null
      });
      setProfile(updated);
      setShowEditModal(false);
      onNotification('School Profile Updated', `Institutional profile for ${updated.name} has been updated.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error updating profile');
    }
  };

  const handleSaveSettings = async (e: React.FormEvent) => {
    e.preventDefault();
    if (selectedWorkingDays.length === 0) {
      alert('At least one working day must be selected.');
      return;
    }
    try {
      const updated = await schoolService.configureSettings({
        workingDays: selectedWorkingDays,
        gradingPreference: selectedGrading,
        termLayout: selectedTermLayout
      });
      setProfile(updated);
      setShowSettingsModal(false);
      onNotification('Operational Settings Configured', 'Working days and grading preferences updated.', 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error updating operational settings');
    }
  };

  const handleRegisterSchool = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const created = await schoolService.registerSchool({
        tenantId: regTenantId,
        name: regName,
        institutionCode: regInstitutionCode,
        address: regAddress,
        contactEmail: regEmail,
        contactPhone: regPhone
      });
      setProfile(created);
      setShowRegisterModal(false);
      onNotification('School Registered', `New school tenant ${created.name} provisioned!`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error registering new school');
    }
  };

  const toggleDay = (day: string) => {
    setSelectedWorkingDays(prev => 
      prev.includes(day) ? prev.filter(d => d !== day) : [...prev, day]
    );
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-12 text-sm text-[#6B6E68]">
        <Building2 className="w-5 h-5 animate-pulse text-[#5F6F52] mr-2" />
        Loading institutional profile for {currentTenantId}...
      </div>
    );
  }

  return (
    <div className="space-y-6">
      
      {/* Top Banner Actions */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-serif font-bold text-[#2C2E2A]">School Profile & Settings</h1>
            <span className="text-xs uppercase tracking-wider font-semibold px-2.5 py-0.5 rounded-full bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
              Phase 1 Core
            </span>
          </div>
          <p className="text-xs text-[#6B6E68] mt-1">
            Institutional profile, government registration, accreditation status, and operational schedules.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowRegisterModal(true)}
            disabled={!canEditProfile}
            title={!canEditProfile ? "Requires permission: school:profile:write" : "Register a new school tenant"}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-[#D9D1C5] text-xs font-semibold text-[#2C2E2A] transition-all ${
              canEditProfile 
                ? 'hover:bg-[#E9E4DB] cursor-pointer' 
                : 'opacity-50 cursor-not-allowed bg-[#FAF9F6]'
            }`}
          >
            {canEditProfile ? <PlusCircle className="w-3.5 h-3.5 text-[#5F6F52]" /> : <Lock className="w-3.5 h-3.5 text-[#8C887D]" />}
            <span>Register New School</span>
          </button>
          <button
            onClick={() => setShowEditModal(true)}
            disabled={!canEditProfile}
            title={!canEditProfile ? "Requires permission: school:profile:write" : "Edit institutional profile"}
            className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-colors shadow-sm ${
              canEditProfile 
                ? 'bg-[#5F6F52] text-white hover:bg-[#4E5C43] cursor-pointer' 
                : 'bg-gray-200 text-gray-500 opacity-60 cursor-not-allowed'
            }`}
          >
            {canEditProfile ? <Edit3 className="w-3.5 h-3.5" /> : <Lock className="w-3.5 h-3.5" />}
            <span>Edit Profile</span>
          </button>
        </div>
      </div>

      {profile && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          
          {/* Main Institution Card */}
          <div className="lg:col-span-2 bg-white rounded-[24px] border border-[#D9D1C5] p-6 shadow-sm">
            <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4 pb-6 border-b border-[#E9E4DB]">
              {profile.logoUrl ? (
                <img
                  src={profile.logoUrl}
                  alt={profile.name}
                  className="w-20 h-20 rounded-2xl object-cover border border-[#D9D1C5]"
                />
              ) : (
                <div className="w-20 h-20 rounded-2xl bg-[#FEFAE0] border border-[#E9E4DB] flex items-center justify-center text-[#5F6F52]">
                  <Building2 className="w-10 h-10" />
                </div>
              )}

              <div className="flex-1 min-w-0">
                <div className="flex flex-wrap items-center gap-2">
                  <h2 className="text-lg font-serif font-bold text-[#2C2E2A] truncate">
                    {profile.name}
                  </h2>
                  <span className="text-[10px] font-bold uppercase px-2 py-0.5 rounded bg-emerald-100 text-emerald-800">
                    {profile.status}
                  </span>
                </div>
                <div className="flex flex-wrap items-center gap-4 text-xs text-[#6B6E68] mt-1.5">
                  <span className="font-mono bg-[#FAF9F6] px-2 py-0.5 rounded border border-[#E9E4DB]">
                    Code: {profile.institutionCode}
                  </span>
                  <span className="font-mono bg-[#FAF9F6] px-2 py-0.5 rounded border border-[#E9E4DB]">
                    Tenant: {profile.tenantId}
                  </span>
                  {profile.registrationType && (
                    <span className="bg-[#FAF9F6] px-2 py-0.5 rounded border border-[#E9E4DB]">
                      Type: {profile.registrationType}
                    </span>
                  )}
                </div>
              </div>
            </div>

            {/* Institutional Details Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-6">
              <div className="space-y-3">
                <div className="flex items-start gap-2.5 text-xs">
                  <MapPin className="w-4 h-4 text-[#8C887D] shrink-0 mt-0.5" />
                  <div>
                    <span className="font-semibold text-[#2C2E2A] block">Campus Address</span>
                    <span className="text-[#6B6E68] leading-relaxed">{profile.address}</span>
                  </div>
                </div>

                <div className="flex items-start gap-2.5 text-xs">
                  <Mail className="w-4 h-4 text-[#8C887D] shrink-0 mt-0.5" />
                  <div>
                    <span className="font-semibold text-[#2C2E2A] block">Official Email</span>
                    <a href={`mailto:${profile.contactEmail}`} className="text-[#5F6F52] hover:underline">
                      {profile.contactEmail}
                    </a>
                  </div>
                </div>

                <div className="flex items-start gap-2.5 text-xs">
                  <Phone className="w-4 h-4 text-[#8C887D] shrink-0 mt-0.5" />
                  <div>
                    <span className="font-semibold text-[#2C2E2A] block">Telephone</span>
                    <span className="text-[#6B6E68]">{profile.contactPhone}</span>
                  </div>
                </div>
              </div>

              <div className="space-y-3 bg-[#FAF9F6] p-4 rounded-2xl border border-[#E9E4DB]">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold text-[#2C2E2A] flex items-center gap-1.5">
                    <Award className="w-4 h-4 text-[#5F6F52]" />
                    Accreditation Status
                  </span>
                  <span className="text-[11px] font-bold px-2 py-0.5 rounded bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
                    {profile.accreditationStatus}
                  </span>
                </div>

                <div className="text-xs text-[#6B6E68] space-y-1">
                  <div className="flex justify-between">
                    <span>Accrediting Body:</span>
                    <span className="font-medium text-[#2C2E2A]">{profile.accreditationBody || 'N/A'}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Valid Until:</span>
                    <span className="font-medium text-[#2C2E2A]">{profile.accreditationValidUntil || 'N/A'}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Government Registration:</span>
                    <span className="font-medium text-[#2C2E2A]">{profile.governmentRegistrationNumber || 'N/A'}</span>
                  </div>
                </div>
              </div>
            </div>

          </div>

          {/* Operational Settings Card */}
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] p-6 shadow-sm flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between pb-4 border-b border-[#E9E4DB]">
                <div className="flex items-center gap-2">
                  <Sliders className="w-4 h-4 text-[#5F6F52]" />
                  <h3 className="text-sm font-serif font-bold text-[#2C2E2A]">Operational Settings</h3>
                </div>
                <button
                  onClick={() => setShowSettingsModal(true)}
                  disabled={!canManageSettings}
                  title={!canManageSettings ? "Requires permission: school:settings:manage" : "Configure working days and grading preferences"}
                  className={`text-xs font-semibold flex items-center gap-1 ${
                    canManageSettings
                      ? 'text-[#5F6F52] hover:text-[#4E5C43] cursor-pointer'
                      : 'text-[#8C887D] opacity-50 cursor-not-allowed'
                  }`}
                >
                  {!canManageSettings && <Lock className="w-3 h-3" />}
                  <span>Configure</span>
                </button>
              </div>

              <div className="py-4 space-y-4">
                <div>
                  <span className="text-xs font-semibold text-[#2C2E2A] block mb-2">School Working Days</span>
                  <div className="flex flex-wrap gap-1.5">
                    {ALL_DAYS.map(day => {
                      const isActive = profile.workingDays.includes(day);
                      return (
                        <span
                          key={day}
                          className={`text-[10px] font-bold px-2 py-1 rounded-lg transition-all ${
                            isActive
                              ? 'bg-[#5F6F52] text-white'
                              : 'bg-[#FAF9F6] text-[#8C887D] border border-[#E9E4DB]'
                          }`}
                        >
                          {day.substring(0, 3)}
                        </span>
                      );
                    })}
                  </div>
                </div>

                <div className="pt-2">
                  <span className="text-xs font-semibold text-[#2C2E2A] block mb-1">Grading System Preference</span>
                  <div className="p-2.5 rounded-xl bg-[#FAF9F6] border border-[#E9E4DB] text-xs">
                    <span className="font-medium text-[#2C2E2A]">
                      {profile.gradingPreference.replace(/_/g, ' ')}
                    </span>
                    <p className="text-[11px] text-[#8C887D] mt-0.5">
                      {profile.gradingPreference === 'DESCRIPTIVE_KURIKULUM_MERDEKA' && 'Supports Kurikulum Merdeka learning achievements and qualitative remarks.'}
                      {profile.gradingPreference === 'NUMERIC_0_100' && 'Direct scale 0-100 evaluation.'}
                      {profile.gradingPreference === 'LETTER_A_F' && 'Standard Letter grades (A, B, C, D, F).'}
                    </p>
                  </div>
                </div>

                <div className="pt-2">
                  <span className="text-xs font-semibold text-[#2C2E2A] block mb-1">Term Layout</span>
                  <div className="p-2.5 rounded-xl bg-[#FAF9F6] border border-[#E9E4DB] text-xs font-medium text-[#2C2E2A]">
                    {profile.termLayout === 'SEMESTER' && 'Semester Schedule (2 terms per academic year)'}
                    {profile.termLayout === 'TRIMESTER' && 'Trimester Schedule (3 terms per academic year)'}
                    {profile.termLayout === 'QUARTER' && 'Quarter Schedule (4 terms per academic year)'}
                  </div>
                </div>
              </div>
            </div>

            <div className="text-[11px] text-[#8C887D] pt-4 border-t border-[#E9E4DB] flex items-center justify-between">
              <span>Last updated: {new Date(profile.updatedAt).toLocaleDateString()}</span>
              <span>v1.0.0-phase1</span>
            </div>
          </div>

        </div>
      )}

      {/* Edit Profile Modal */}
      {showEditModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-lg w-full p-6 shadow-2xl max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Edit Institutional Profile</h3>
              <button onClick={() => setShowEditModal(false)} className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer">✕</button>
            </div>

            <form onSubmit={handleUpdateProfile} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">School Name</label>
                <input
                  type="text"
                  value={editName}
                  onChange={(e) => setEditName(e.target.value)}
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Address</label>
                <textarea
                  value={editAddress}
                  onChange={(e) => setEditAddress(e.target.value)}
                  rows={2}
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Contact Email</label>
                  <input
                    type="email"
                    value={editEmail}
                    onChange={(e) => setEditEmail(e.target.value)}
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                    required
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Contact Phone</label>
                  <input
                    type="text"
                    value={editPhone}
                    onChange={(e) => setEditPhone(e.target.value)}
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Logo URL</label>
                <input
                  type="url"
                  value={editLogoUrl}
                  onChange={(e) => setEditLogoUrl(e.target.value)}
                  placeholder="https://..."
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Accreditation Status</label>
                  <select
                    value={editAccredStatus}
                    onChange={(e) => setEditAccredStatus(e.target.value)}
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  >
                    <option value="ACCREDITED_A">Accredited A (Unggul)</option>
                    <option value="ACCREDITED_B">Accredited B (Baik Sekali)</option>
                    <option value="ACCREDITED_C">Accredited C (Baik)</option>
                    <option value="UNACCREDITED">Unaccredited</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Valid Until</label>
                  <input
                    type="date"
                    value={editAccredValid}
                    onChange={(e) => setEditAccredValid(e.target.value)}
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  />
                </div>
              </div>

              <div className="pt-4 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowEditModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43]"
                >
                  Save Profile
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Configure Settings Modal */}
      {showSettingsModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-md w-full p-6 shadow-2xl">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Configure Operational Settings</h3>
              <button onClick={() => setShowSettingsModal(false)} className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer">✕</button>
            </div>

            <form onSubmit={handleSaveSettings} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1.5">Working Days</label>
                <div className="grid grid-cols-4 gap-1.5">
                  {ALL_DAYS.map(day => (
                    <button
                      key={day}
                      type="button"
                      onClick={() => toggleDay(day)}
                      className={`py-1.5 text-[10px] font-bold rounded-xl border cursor-pointer transition-all ${
                        selectedWorkingDays.includes(day)
                          ? 'bg-[#5F6F52] text-white border-[#5F6F52]'
                          : 'bg-[#FAF9F6] text-[#8C887D] border-[#D9D1C5]'
                      }`}
                    >
                      {day.substring(0, 3)}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Grading Preference</label>
                <select
                  value={selectedGrading}
                  onChange={(e) => setSelectedGrading(e.target.value as any)}
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                >
                  <option value="DESCRIPTIVE_KURIKULUM_MERDEKA">Kurikulum Merdeka (Descriptive & Learning Goals)</option>
                  <option value="NUMERIC_0_100">Numeric (0 - 100 Scale)</option>
                  <option value="LETTER_A_F">Letter Grade (A, B, C, D, F)</option>
                  <option value="PERCENTAGE_0_100">Percentage (0% - 100%)</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Academic Term Layout</label>
                <select
                  value={selectedTermLayout}
                  onChange={(e) => setSelectedTermLayout(e.target.value as any)}
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                >
                  <option value="SEMESTER">Semester (2 Terms per Year)</option>
                  <option value="TRIMESTER">Trimester (3 Terms per Year)</option>
                  <option value="QUARTER">Quarter (4 Terms per Year)</option>
                </select>
              </div>

              <div className="pt-4 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowSettingsModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43]"
                >
                  Apply Settings
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Register New School Modal */}
      {showRegisterModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-lg w-full p-6 shadow-2xl">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Provision & Register New School</h3>
              <button onClick={() => setShowRegisterModal(false)} className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer">✕</button>
            </div>

            <form onSubmit={handleRegisterSchool} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Tenant ID</label>
                <input
                  type="text"
                  value={regTenantId}
                  onChange={(e) => setRegTenantId(e.target.value)}
                  placeholder="e.g. tenant-islamic-boarding-01"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">School Name</label>
                <input
                  type="text"
                  value={regName}
                  onChange={(e) => setRegName(e.target.value)}
                  placeholder="e.g. Pesantren Darul Ilmi"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Institution Code (NPSN)</label>
                <input
                  type="text"
                  value={regInstitutionCode}
                  onChange={(e) => setRegInstitutionCode(e.target.value)}
                  placeholder="e.g. NPSN-30198821"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Address</label>
                <input
                  type="text"
                  value={regAddress}
                  onChange={(e) => setRegAddress(e.target.value)}
                  placeholder="Street and City"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Email</label>
                  <input
                    type="email"
                    value={regEmail}
                    onChange={(e) => setRegEmail(e.target.value)}
                    placeholder="admin@school.ac.id"
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                    required
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Phone</label>
                  <input
                    type="text"
                    value={regPhone}
                    onChange={(e) => setRegPhone(e.target.value)}
                    placeholder="+62 21..."
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                    required
                  />
                </div>
              </div>

              <div className="pt-4 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowRegisterModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43]"
                >
                  Provision School
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};
