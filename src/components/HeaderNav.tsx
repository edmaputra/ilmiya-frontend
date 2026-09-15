import React from 'react';
import { 
  Smartphone, 
  Monitor, 
  Tablet, 
  Bell, 
  MessageSquare, 
  Code2, 
  ShieldCheck,
  ChevronDown, 
  User, 
  Sliders,
  Building2,
  Calendar,
  Compass
} from 'lucide-react';
import { UserRole, DeviceView, ActiveTab, UserProfile } from '../types';
import { IlmiyaLogo } from './IlmiyaLogo';

interface HeaderNavProps {
  currentRole: UserRole;
  onRoleChange: (role: UserRole) => void;
  deviceView: DeviceView;
  onDeviceViewChange: (view: DeviceView) => void;
  activeTab: ActiveTab;
  onTabChange: (tab: ActiveTab) => void;
  currentUser: UserProfile;
  unreadNotifsCount: number;
  unreadMessagesCount: number;
  onQuickSimulateNotif: () => void;
}

export const HeaderNav: React.FC<HeaderNavProps> = ({
  currentRole,
  onRoleChange,
  deviceView,
  onDeviceViewChange,
  activeTab,
  onTabChange,
  currentUser,
  unreadNotifsCount,
  unreadMessagesCount,
  onQuickSimulateNotif,
}) => {
  return (
    <header className="bg-[#FAF9F6]/95 backdrop-blur-md border-b border-[#E9E4DB] sticky top-0 z-40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          
          {/* Brand & Open Source Badge */}
          <div className="flex items-center gap-3">
            <IlmiyaLogo variant="app-squircle" size={42} className="rounded-2xl" />
            <div>
              <div className="flex items-center gap-2">
                <span className="font-serif font-bold text-xl text-[#2C2E2A] tracking-tight">Ilmiya</span>
                <span className="text-[10px] uppercase tracking-widest font-bold px-2.5 py-0.5 rounded-full bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
                  SIS
                </span>
              </div>
              <p className="text-[11px] text-[#8C887D] hidden sm:block">School Information System • Natural Tones</p>
            </div>
          </div>

          {/* Navigation Tabs (Desktop Web) */}
          <nav className="hidden md:flex items-center gap-1.5 bg-[#E9E4DB] p-1.5 rounded-2xl border border-[#D9D1C5]">
            <button
              onClick={() => onTabChange('school_profile')}
              className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
                activeTab === 'school_profile'
                  ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-sm'
                  : 'text-[#6B6E68] hover:text-[#2C2E2A] hover:bg-[#F2EDE4]'
              }`}
            >
              <Building2 className="w-3.5 h-3.5" />
              <span>School Profile</span>
            </button>
            <button
              onClick={() => onTabChange('academic_years')}
              className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
                activeTab === 'academic_years'
                  ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-sm'
                  : 'text-[#6B6E68] hover:text-[#2C2E2A] hover:bg-[#F2EDE4]'
              }`}
            >
              <Calendar className="w-3.5 h-3.5" />
              <span>Academic Years</span>
            </button>
            <button
              onClick={() => onTabChange('iam_management')}
              className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
                activeTab === 'iam_management'
                  ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-sm'
                  : 'text-[#6B6E68] hover:text-[#2C2E2A] hover:bg-[#F2EDE4]'
              }`}
            >
              <ShieldCheck className="w-3.5 h-3.5" />
              <span>IAM Console</span>
            </button>
            <button
              onClick={() => onTabChange('preview')}
              className={`relative flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
                activeTab === 'preview'
                  ? 'bg-[#5F6F52] text-white shadow-sm'
                  : 'text-[#5F6F52] hover:bg-[#FEFAE0]'
              }`}
            >
              <Compass className="w-3.5 h-3.5" />
              <span>Feature Previews</span>
              <span className={`text-[10px] font-bold px-1.5 py-0.2 rounded-full ${
                activeTab === 'preview' ? 'bg-[#FAF9F6] text-[#5F6F52]' : 'bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]'
              }`}>
                Labs
              </span>
              {(unreadMessagesCount + unreadNotifsCount) > 0 && (
                <span className="w-2 h-2 rounded-full bg-[#D67D5B] animate-pulse" />
              )}
            </button>
          </nav>

          {/* Right Controls: Device Preview Toggle + Role Switcher */}
          <div className="flex items-center gap-3">
            
            {/* Viewport switcher */}
            <div className="hidden lg:flex items-center bg-[#E9E4DB] p-1 rounded-xl border border-[#D9D1C5]">
              <button
                onClick={() => onDeviceViewChange('responsive')}
                title="Web Dashboard View"
                className={`p-1.5 rounded-lg text-xs transition-colors cursor-pointer ${
                  deviceView === 'responsive' ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-sm' : 'text-[#6B6E68] hover:text-[#2C2E2A]'
                }`}
              >
                <Monitor className="w-4 h-4" />
              </button>
              <button
                onClick={() => onDeviceViewChange('ios')}
                title="iOS iPhone 16 Frame"
                className={`p-1.5 rounded-lg text-xs transition-colors cursor-pointer ${
                  deviceView === 'ios' ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-sm' : 'text-[#6B6E68] hover:text-[#2C2E2A]'
                }`}
              >
                <Smartphone className="w-4 h-4" />
              </button>
              <button
                onClick={() => onDeviceViewChange('android')}
                title="Android Pixel Frame"
                className={`p-1.5 rounded-lg text-xs transition-colors cursor-pointer ${
                  deviceView === 'android' ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-sm' : 'text-[#6B6E68] hover:text-[#2C2E2A]'
                }`}
              >
                <Tablet className="w-4 h-4" />
              </button>
            </div>

            {/* Quick Simulate Trigger */}
            <button
              onClick={onQuickSimulateNotif}
              className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-[#FAF9F6] hover:bg-[#F2EDE4] border border-[#D9D1C5] text-[#5F6F52] text-xs font-semibold transition-all cursor-pointer shadow-sm"
              title="Simulate incoming real-time grade & message alerts"
            >
              <Sliders className="w-3.5 h-3.5 text-[#D67D5B]" />
              <span>Simulate Alert</span>
            </button>

            {/* Role Switcher */}
            <div className="relative flex items-center gap-2 bg-[#E9E4DB] pl-2 pr-3 py-1.5 rounded-2xl border border-[#D9D1C5] text-xs cursor-pointer shadow-sm">
              <img
                src={currentUser.avatar}
                alt={currentUser.name}
                className="w-7 h-7 rounded-full object-cover border-2 border-white"
              />
              <div className="text-left">
                <p className="font-bold text-[#2C2E2A] leading-tight">{currentUser.name}</p>
                <div className="flex items-center gap-1">
                  <span className="capitalize text-[11px] text-[#5F6F52] font-semibold">{currentRole}</span>
                </div>
              </div>
              <select
                aria-label="Select User Role"
                value={currentRole}
                onChange={(e) => onRoleChange(e.target.value as UserRole)}
                className="absolute inset-0 opacity-0 cursor-pointer w-full h-full"
              >
                <option value="student">Student (Alex Rivera)</option>
                <option value="teacher">Teacher (Dr. Vance)</option>
                <option value="parent">Parent (Marco Rivera)</option>
                <option value="admin">Admin (Principal Martinez)</option>
              </select>
              <ChevronDown className="w-3.5 h-3.5 text-[#6B6E68] pointer-events-none" />
            </div>

          </div>

        </div>
      </div>

      {/* Mobile sub-bar tabs */}
      <div className="md:hidden flex items-center justify-around px-2 py-2 border-t border-[#E9E4DB] bg-[#FAF9F6]/95 overflow-x-auto text-xs">
        <button
          onClick={() => onTabChange('school_profile')}
          className={`px-3 py-1.5 rounded-xl font-medium whitespace-nowrap cursor-pointer ${
            activeTab === 'school_profile' ? 'bg-[#5F6F52] text-white font-bold' : 'text-[#6B6E68]'
          }`}
        >
          School
        </button>
        <button
          onClick={() => onTabChange('academic_years')}
          className={`px-3 py-1.5 rounded-xl font-medium whitespace-nowrap cursor-pointer ${
            activeTab === 'academic_years' ? 'bg-[#5F6F52] text-white font-bold' : 'text-[#6B6E68]'
          }`}
        >
          Calendar
        </button>
        <button
          onClick={() => onTabChange('iam_management')}
          className={`px-3 py-1.5 rounded-xl font-medium whitespace-nowrap cursor-pointer ${
            activeTab === 'iam_management' ? 'bg-[#5F6F52] text-white font-bold' : 'text-[#6B6E68]'
          }`}
        >
          IAM
        </button>
        <button
          onClick={() => onTabChange('preview')}
          className={`px-3 py-1.5 rounded-xl font-medium whitespace-nowrap flex items-center gap-1 cursor-pointer ${
            activeTab === 'preview' ? 'bg-[#5F6F52] text-white font-bold' : 'text-[#5F6F52]'
          }`}
        >
          <span>Previews</span>
          {(unreadMessagesCount + unreadNotifsCount) > 0 && (
            <span className="w-2 h-2 rounded-full bg-[#D67D5B] animate-pulse" />
          )}
        </button>
      </div>
    </header>
  );
};
