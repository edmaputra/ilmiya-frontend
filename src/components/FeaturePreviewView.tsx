import React, { useState } from 'react';
import { 
  Sparkles, 
  Award, 
  MessageSquare, 
  Bell, 
  Code2, 
  LayoutDashboard, 
  Layers, 
  Compass 
} from 'lucide-react';
import { DashboardView } from './DashboardView';
import { GradesView } from './GradesView';
import { MessagingView } from './MessagingView';
import { NotificationsView } from './NotificationsView';
import { FlutterCodeHub } from './FlutterCodeHub';
import { 
  Course, 
  Assignment, 
  NotificationItem, 
  ChatMessage, 
  ChatChannel, 
  SchedulePeriod, 
  UserProfile, 
  UserRole,
  ActiveTab
} from '../types';

interface FeaturePreviewViewProps {
  currentUser: UserProfile;
  currentRole: UserRole;
  courses: Course[];
  schedule: SchedulePeriod[];
  notifications: NotificationItem[];
  channels: ChatChannel[];
  messages: Record<string, ChatMessage[]>;
  activeChannelId: string;
  pendingInquiryContext: { course: Course; assignment: Assignment } | null;
  onSelectChannel: (channelId: string) => void;
  onSendMessage: (
    channelId: string,
    content: string,
    contextTag?: { type: 'assignment' | 'grade' | 'exam'; title: string; id: string },
    attachment?: { name: string; type: 'pdf' | 'image' | 'code' | 'doc'; size: string }
  ) => void;
  onClearInquiryContext: () => void;
  onInquireAssignment: (course: Course, assignment: Assignment) => void;
  onMarkAllAsRead: () => void;
  onMarkAsRead: (id: string) => void;
  onDeleteNotification: (id: string) => void;
  onSimulateNotification: (preset: 'grade' | 'announcement' | 'message' | 'emergency') => void;
  onBroadcastAnnouncement: (title: string, message: string, priority: 'medium' | 'high' | 'urgent', target: string) => void;
  onNavigateTab: (tab: ActiveTab) => void;
}

type PreviewSubTab = 'grades' | 'messaging' | 'notifications' | 'dashboard' | 'flutter';

export const FeaturePreviewView: React.FC<FeaturePreviewViewProps> = ({
  currentUser,
  currentRole,
  courses,
  schedule,
  notifications,
  channels,
  messages,
  activeChannelId,
  pendingInquiryContext,
  onSelectChannel,
  onSendMessage,
  onClearInquiryContext,
  onInquireAssignment,
  onMarkAllAsRead,
  onMarkAsRead,
  onDeleteNotification,
  onSimulateNotification,
  onBroadcastAnnouncement,
  onNavigateTab
}) => {
  const [subTab, setSubTab] = useState<PreviewSubTab>('grades');

  const unreadMessagesCount = channels.reduce((acc, c) => acc + c.unreadCount, 0);
  const unreadNotifsCount = notifications.filter(n => !n.read).length;

  return (
    <div className="space-y-6">
      
      {/* Roadmap & Feature Preview Notice Banner */}
      <div className="bg-[#FEFAE0]/80 border border-[#E9E4DB] rounded-[24px] p-5 shadow-xs flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div className="flex items-start gap-3">
          <div className="p-2.5 rounded-2xl bg-[#5F6F52] text-white shrink-0 mt-0.5">
            <Compass className="w-5 h-5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-sm font-serif font-bold text-[#2C2E2A]">
                Feature Preview & Prototype Labs
              </h2>
              <span className="text-[10px] uppercase font-bold px-2 py-0.5 rounded-full bg-[#5F6F52] text-white">
                Roadmap Preview
              </span>
            </div>
            <p className="text-xs text-[#6B6E68] mt-1 leading-relaxed max-w-3xl">
              These interactive prototype components represent upcoming modules in subsequent roadmap phases (Curriculum, Student PPDB, Timetables, and Grading). They are preserved here for user experience testing and design validation.
            </p>
          </div>
        </div>

        {/* Sub-tab Switcher inside Preview */}
        <div className="flex flex-wrap items-center gap-1 bg-[#E9E4DB] p-1 rounded-2xl border border-[#D9D1C5]">
          <button
            onClick={() => setSubTab('grades')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
              subTab === 'grades' ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-xs' : 'text-[#6B6E68] hover:text-[#2C2E2A]'
            }`}
          >
            <Award className="w-3.5 h-3.5" />
            <span>Grades & GPA</span>
          </button>

          <button
            onClick={() => setSubTab('messaging')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
              subTab === 'messaging' ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-xs' : 'text-[#6B6E68] hover:text-[#2C2E2A]'
            }`}
          >
            <MessageSquare className="w-3.5 h-3.5" />
            <span>Messaging</span>
            {unreadMessagesCount > 0 && (
              <span className="bg-[#D67D5B] text-white text-[9px] font-bold px-1.5 py-0.2 rounded-full">
                {unreadMessagesCount}
              </span>
            )}
          </button>

          <button
            onClick={() => setSubTab('notifications')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
              subTab === 'notifications' ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-xs' : 'text-[#6B6E68] hover:text-[#2C2E2A]'
            }`}
          >
            <Bell className="w-3.5 h-3.5" />
            <span>Alerts</span>
            {unreadNotifsCount > 0 && (
              <span className="bg-[#D67D5B] text-white text-[9px] font-bold px-1.5 py-0.2 rounded-full">
                {unreadNotifsCount}
              </span>
            )}
          </button>

          <button
            onClick={() => setSubTab('dashboard')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
              subTab === 'dashboard' ? 'bg-[#FAF9F6] text-[#5F6F52] shadow-xs' : 'text-[#6B6E68] hover:text-[#2C2E2A]'
            }`}
          >
            <LayoutDashboard className="w-3.5 h-3.5" />
            <span>Role Portal</span>
          </button>

          <button
            onClick={() => setSubTab('flutter')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
              subTab === 'flutter' ? 'bg-[#5F6F52] text-white shadow-xs' : 'text-[#5F6F52] hover:bg-[#F2EDE4]'
            }`}
          >
            <Code2 className="w-3.5 h-3.5" />
            <span>Flutter Code</span>
          </button>
        </div>
      </div>

      {/* Render Selected Preview Sub-tab */}
      <div>
        {subTab === 'grades' && (
          <GradesView
            courses={courses}
            user={currentUser}
            currentRole={currentRole}
            onInquireAssignment={(c, a) => {
              onInquireAssignment(c, a);
              setSubTab('messaging');
            }}
            onUpdateCourseGrade={() => {}}
          />
        )}

        {subTab === 'messaging' && (
          <MessagingView
            channels={channels}
            messages={messages}
            currentUser={currentUser}
            currentRole={currentRole}
            courses={courses}
            activeChannelId={activeChannelId}
            onSelectChannel={onSelectChannel}
            onSendMessage={onSendMessage}
            pendingInquiryContext={pendingInquiryContext}
            onClearInquiryContext={onClearInquiryContext}
          />
        )}

        {subTab === 'notifications' && (
          <NotificationsView
            notifications={notifications}
            currentUser={currentUser}
            currentRole={currentRole}
            onMarkAllAsRead={onMarkAllAsRead}
            onMarkAsRead={onMarkAsRead}
            onDeleteNotification={onDeleteNotification}
            onSimulateNotification={onSimulateNotification}
            onBroadcastAnnouncement={onBroadcastAnnouncement}
          />
        )}

        {subTab === 'dashboard' && (
          <DashboardView
            user={currentUser}
            courses={courses}
            schedule={schedule}
            notifications={notifications}
            onNavigateTab={(tab) => {
              if (tab === 'grades') setSubTab('grades');
              else if (tab === 'messaging') setSubTab('messaging');
              else if (tab === 'notifications') setSubTab('notifications');
              else if (tab === 'flutter_code') setSubTab('flutter');
              else onNavigateTab(tab);
            }}
            onSelectCourse={() => setSubTab('grades')}
            onOpenGpaCalc={() => setSubTab('grades')}
            onOpenTranscript={() => setSubTab('grades')}
            onTriggerQuickSimulation={() => onSimulateNotification('grade')}
          />
        )}

        {subTab === 'flutter' && (
          <FlutterCodeHub />
        )}
      </div>

    </div>
  );
};
