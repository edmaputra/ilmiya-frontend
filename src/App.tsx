/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState } from 'react';
import { HeaderNav } from './components/HeaderNav';
import { DashboardView } from './components/DashboardView';
import { GradesView } from './components/GradesView';
import { MessagingView } from './components/MessagingView';
import { NotificationsView } from './components/NotificationsView';
import { FlutterCodeHub } from './components/FlutterCodeHub';
import { DeviceFrameWrapper } from './components/DeviceFrameWrapper';
import { 
  PROFILES, 
  INITIAL_COURSES, 
  INITIAL_NOTIFICATIONS, 
  INITIAL_CHANNELS, 
  INITIAL_MESSAGES, 
  WEEKLY_SCHEDULE 
} from './data/mockData';
import { UserRole, DeviceView, ActiveTab, Course, Assignment, NotificationItem, ChatMessage } from './types';
import { Bell, Award, MessageSquare, AlertTriangle, X } from 'lucide-react';

export default function App() {
  const [currentRole, setCurrentRole] = useState<UserRole>('student');
  const [deviceView, setDeviceView] = useState<DeviceView>('responsive');
  const [activeTab, setActiveTab] = useState<ActiveTab>('dashboard');
  
  const [courses, setCourses] = useState<Course[]>(INITIAL_COURSES);
  const [notifications, setNotifications] = useState<NotificationItem[]>(INITIAL_NOTIFICATIONS);
  const [channels, setChannels] = useState(INITIAL_CHANNELS);
  const [messages, setMessages] = useState<Record<string, ChatMessage[]>>(INITIAL_MESSAGES);
  const [activeChannelId, setActiveChannelId] = useState<string>('chan_vance_direct');

  // Passing contextual assignment inquiry from Grades view to Chat view
  const [pendingInquiryContext, setPendingInquiryContext] = useState<{ course: Course; assignment: Assignment } | null>(null);

  // Active Real-time Toast Popover
  const [activeToast, setActiveToast] = useState<NotificationItem | null>(null);

  const currentUser = PROFILES[currentRole];

  const unreadNotifsCount = notifications.filter(n => !n.read).length;
  const unreadMessagesCount = channels.reduce((acc, c) => acc + c.unreadCount, 0);

  // Play audio chime simulation
  const playNotificationSound = () => {
    try {
      const audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(587.33, audioCtx.currentTime); // D5
      osc.frequency.exponentialRampToValueAtTime(880, audioCtx.currentTime + 0.15); // A5
      gain.gain.setValueAtTime(0.2, audioCtx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.3);
      osc.connect(gain);
      gain.connect(audioCtx.destination);
      osc.start();
      osc.stop(audioCtx.currentTime + 0.3);
    } catch (e) {
      // AudioContext unavailable or restricted
    }
  };

  const showToastNotification = (notif: NotificationItem) => {
    playNotificationSound();
    setActiveToast(notif);
    setTimeout(() => {
      setActiveToast(prev => (prev?.id === notif.id ? null : prev));
    }, 4500);
  };

  // Real-time Push Simulation Handler
  const handleSimulateNotification = (preset: 'grade' | 'announcement' | 'message' | 'emergency') => {
    const timestamp = 'Just now';
    let newNotif: NotificationItem;

    if (preset === 'grade') {
      newNotif = {
        id: `notif_${Date.now()}`,
        title: 'New Grade Posted: AP Physics Exam',
        message: 'Dr. Sarah Jenkins graded "Unit 5 Test: Simple Harmonic Motion" with 92/100 (A-). Feedback rubric available.',
        timestamp,
        category: 'grade',
        priority: 'high',
        read: false,
        courseCode: 'PHYS-302',
        senderName: 'Dr. Sarah Jenkins',
        senderAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80'
      };
    } else if (preset === 'message') {
      newNotif = {
        id: `notif_${Date.now()}`,
        title: 'Secure Message from Dr. Vance',
        message: '"I reviewed your recursive tree rotation test cases. Looks solid for the capstone proposal!"',
        timestamp,
        category: 'message',
        priority: 'medium',
        read: false,
        courseCode: 'CS-301',
        senderName: 'Dr. Eleanor Vance',
        senderAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80'
      };
    } else if (preset === 'emergency') {
      newNotif = {
        id: `notif_${Date.now()}`,
        title: 'URGENT: Weather Alert & Early Dismissal',
        message: 'All after-school laboratory sessions and athletics rescheduled due to regional storm advisory.',
        timestamp,
        category: 'emergency',
        priority: 'urgent',
        read: false,
        senderName: 'Lincoln High Administration'
      };
    } else {
      newNotif = {
        id: `notif_${Date.now()}`,
        title: 'Class Notice: AP Calculus BC Study Session',
        message: 'Prof. Marcus Chen announced extra office hours this Thursday at 3:30 PM in Hall B-210.',
        timestamp,
        category: 'announcement',
        priority: 'medium',
        read: false,
        courseCode: 'MATH-401',
        senderName: 'Prof. Marcus Chen'
      };
    }

    setNotifications(prev => [newNotif, ...prev]);
    showToastNotification(newNotif);
  };

  // Broadcast announcement
  const handleBroadcastAnnouncement = (
    title: string,
    message: string,
    priority: 'medium' | 'high' | 'urgent',
    target: string
  ) => {
    const newNotif: NotificationItem = {
      id: `notif_${Date.now()}`,
      title: `[Broadcast to ${target}] ${title}`,
      message,
      timestamp: 'Just now',
      category: 'announcement',
      priority,
      read: false,
      senderName: currentUser.name,
      senderAvatar: currentUser.avatar
    };

    setNotifications(prev => [newNotif, ...prev]);
    showToastNotification(newNotif);
  };

  // Send message in E2EE Chat
  const handleSendMessage = (
    channelId: string,
    content: string,
    contextTag?: { type: 'assignment' | 'grade' | 'exam'; title: string; id: string },
    attachment?: { name: string; type: 'pdf' | 'image' | 'code' | 'doc'; size: string }
  ) => {
    const newMsg: ChatMessage = {
      id: `msg_${Date.now()}`,
      senderId: currentUser.id,
      senderName: currentUser.name,
      senderRole: currentRole,
      senderAvatar: currentUser.avatar,
      content,
      timestamp: 'Just now',
      isEncrypted: true,
      status: 'delivered',
      contextTag,
      attachment
    };

    setMessages(prev => ({
      ...prev,
      [channelId]: [...(prev[channelId] || []), newMsg]
    }));

    // Update last message in channel list
    setChannels(prev =>
      prev.map(c =>
        c.id === channelId
          ? {
              ...c,
              lastMessage: {
                text: content,
                timestamp: 'Just now',
                senderId: currentUser.id
              }
            }
          : c
      )
    );

    // Auto-reply simulation if current user is student
    if (currentRole === 'student') {
      setTimeout(() => {
        const autoReply: ChatMessage = {
          id: `reply_${Date.now()}`,
          senderId: 'user_teacher_1',
          senderName: 'Dr. Eleanor Vance',
          senderRole: 'teacher',
          senderAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
          content: 'Thank you for following up, Alex! I’ve reviewed your note and logged it into the grade tracking portal.',
          timestamp: 'Just now',
          isEncrypted: true,
          status: 'delivered'
        };

        setMessages(p => ({
          ...p,
          [channelId]: [...(p[channelId] || []), autoReply]
        }));

        const notif: NotificationItem = {
          id: `notif_${Date.now()}`,
          title: 'Dr. Vance replied to your message',
          message: 'Thank you for following up, Alex! I’ve reviewed your note and logged it into the portal.',
          timestamp: 'Just now',
          category: 'message',
          priority: 'medium',
          read: false,
          courseCode: 'CS-301',
          senderName: 'Dr. Eleanor Vance',
          senderAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80'
        };
        setNotifications(p => [notif, ...p]);
        showToastNotification(notif);
      }, 1800);
    }
  };

  const handleInquireAssignment = (course: Course, assignment: Assignment) => {
    setPendingInquiryContext({ course, assignment });
    setActiveTab('messaging');
  };

  return (
    <div className="min-h-screen bg-[#FAF9F6] text-[#2C2E2A] flex flex-col font-['Plus_Jakarta_Sans',sans-serif]">
      
      {/* Real-time Toast Popover */}
      {activeToast && (
        <div className="fixed top-20 right-4 sm:right-6 z-50 max-w-sm w-full bg-white/95 border border-[#D9D1C5] rounded-[24px] p-4 shadow-[0_12px_36px_rgba(95,111,82,0.12)] backdrop-blur-md animate-bounce-short">
          <div className="flex items-start justify-between gap-3">
            <div className="flex items-start gap-3">
              <div className="p-2.5 rounded-2xl bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB] mt-0.5">
                {activeToast.category === 'grade' && <Award className="w-4 h-4 text-[#5F6F52]" />}
                {activeToast.category === 'message' && <MessageSquare className="w-4 h-4 text-[#A9B388]" />}
                {activeToast.category === 'emergency' && <AlertTriangle className="w-4 h-4 text-[#D67D5B]" />}
                {activeToast.category === 'announcement' && <Bell className="w-4 h-4 text-[#5F6F52]" />}
              </div>
              <div>
                <div className="flex items-center gap-1.5">
                  <span className="text-[10px] font-bold uppercase tracking-widest text-[#D67D5B]">Push Alert</span>
                  <span className="text-[10px] text-[#8C887D]">• {activeToast.timestamp}</span>
                </div>
                <h4 className="text-xs font-serif font-bold text-[#2C2E2A] mt-0.5">{activeToast.title}</h4>
                <p className="text-[11px] text-[#6B6E68] mt-0.5 line-clamp-2 leading-relaxed">{activeToast.message}</p>
              </div>
            </div>
            <button
              onClick={() => setActiveToast(null)}
              className="text-[#8C887D] hover:text-[#2C2E2A] p-1 rounded-lg cursor-pointer"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}

      {/* Main Navigation Bar */}
      <HeaderNav
        currentRole={currentRole}
        onRoleChange={setCurrentRole}
        deviceView={deviceView}
        onDeviceViewChange={setDeviceView}
        activeTab={activeTab}
        onTabChange={setActiveTab}
        currentUser={currentUser}
        unreadNotifsCount={unreadNotifsCount}
        unreadMessagesCount={unreadMessagesCount}
        onQuickSimulateNotif={() => handleSimulateNotification('grade')}
      />

      {/* Main Body */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <DeviceFrameWrapper deviceView={deviceView}>
          <div className="space-y-6">
            
            {activeTab === 'dashboard' && (
              <DashboardView
                user={currentUser}
                courses={courses}
                schedule={WEEKLY_SCHEDULE}
                notifications={notifications}
                onNavigateTab={(tab) => setActiveTab(tab)}
                onSelectCourse={() => setActiveTab('grades')}
                onOpenGpaCalc={() => setActiveTab('grades')}
                onOpenTranscript={() => setActiveTab('grades')}
                onTriggerQuickSimulation={() => handleSimulateNotification('grade')}
              />
            )}

            {activeTab === 'grades' && (
              <GradesView
                courses={courses}
                user={currentUser}
                currentRole={currentRole}
                onInquireAssignment={handleInquireAssignment}
                onUpdateCourseGrade={() => {}}
              />
            )}

            {activeTab === 'messaging' && (
              <MessagingView
                channels={channels}
                messages={messages}
                currentUser={currentUser}
                currentRole={currentRole}
                courses={courses}
                activeChannelId={activeChannelId}
                onSelectChannel={setActiveChannelId}
                onSendMessage={handleSendMessage}
                pendingInquiryContext={pendingInquiryContext}
                onClearInquiryContext={() => setPendingInquiryContext(null)}
              />
            )}

            {activeTab === 'notifications' && (
              <NotificationsView
                notifications={notifications}
                currentUser={currentUser}
                currentRole={currentRole}
                onMarkAllAsRead={() => setNotifications(prev => prev.map(n => ({ ...n, read: true })))}
                onMarkAsRead={(id) => setNotifications(prev => prev.map(n => n.id === id ? { ...n, read: true } : n))}
                onDeleteNotification={(id) => setNotifications(prev => prev.filter(n => n.id !== id))}
                onSimulateNotification={handleSimulateNotification}
                onBroadcastAnnouncement={handleBroadcastAnnouncement}
              />
            )}

            {activeTab === 'flutter_code' && (
              <FlutterCodeHub />
            )}

          </div>
        </DeviceFrameWrapper>
      </main>

      {/* Footer */}
      <footer className="bg-[#E9E4DB]/80 border-t border-[#D9D1C5] py-6 mt-12 text-center text-xs text-[#6B6E68]">
        <div className="max-w-7xl mx-auto px-4 flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="font-medium">© 2026 ILMIYA • Natural Tones Edition • School Information System</p>
          <div className="flex items-center gap-4 text-[#6B6E68]">
            <button onClick={() => setActiveTab('flutter_code')} className="hover:text-[#5F6F52] font-semibold transition-colors cursor-pointer">
              Flutter Architecture
            </button>
            <span>•</span>
            <button onClick={() => setCurrentRole(currentRole === 'student' ? 'teacher' : 'student')} className="hover:text-[#5F6F52] font-semibold transition-colors cursor-pointer">
              Switch to {currentRole === 'student' ? 'Teacher' : 'Student'} Role
            </button>
            <span>•</span>
            <span className="text-[#8C887D]">FERPA / COPPA Compliant</span>
          </div>
        </div>
      </footer>

    </div>
  );
}
