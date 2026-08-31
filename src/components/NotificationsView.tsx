import React, { useState } from 'react';
import { 
  Bell, 
  CheckCheck, 
  Sparkles, 
  Send, 
  Volume2, 
  VolumeX, 
  AlertTriangle, 
  Award, 
  MessageSquare, 
  Radio, 
  ShieldAlert, 
  CheckCircle2,
  Clock,
  Trash2,
  Filter
} from 'lucide-react';
import { NotificationItem, UserRole, UserProfile } from '../types';

interface NotificationsViewProps {
  notifications: NotificationItem[];
  currentUser: UserProfile;
  currentRole: UserRole;
  onMarkAllAsRead: () => void;
  onMarkAsRead: (id: string) => void;
  onDeleteNotification: (id: string) => void;
  onSimulateNotification: (preset: 'grade' | 'announcement' | 'message' | 'emergency') => void;
  onBroadcastAnnouncement: (title: string, message: string, priority: 'medium' | 'high' | 'urgent', target: string) => void;
}

export const NotificationsView: React.FC<NotificationsViewProps> = ({
  notifications,
  currentUser,
  currentRole,
  onMarkAllAsRead,
  onMarkAsRead,
  onDeleteNotification,
  onSimulateNotification,
  onBroadcastAnnouncement,
}) => {
  const [selectedFilter, setSelectedFilter] = useState<'all' | 'grade' | 'message' | 'announcement' | 'emergency'>('all');
  const [soundEnabled, setSoundEnabled] = useState(true);

  // Broadcast Composer State
  const [broadcastTitle, setBroadcastTitle] = useState('');
  const [broadcastMessage, setBroadcastMessage] = useState('');
  const [broadcastPriority, setBroadcastPriority] = useState<'medium' | 'high' | 'urgent'>('high');
  const [broadcastTarget, setBroadcastTarget] = useState('All School (Students & Parents)');

  const filteredNotifications = notifications.filter(n => {
    if (selectedFilter === 'all') return true;
    return n.category === selectedFilter;
  });

  const handleBroadcastSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!broadcastTitle.trim() || !broadcastMessage.trim()) return;

    onBroadcastAnnouncement(
      broadcastTitle.trim(),
      broadcastMessage.trim(),
      broadcastPriority,
      broadcastTarget
    );

    setBroadcastTitle('');
    setBroadcastMessage('');
  };

  return (
    <div className="space-y-6">
      
      {/* Header & Simulator Bar */}
      <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-6 shadow-sm space-y-6">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-4 border-b border-[#E9E4DB]">
          <div>
            <div className="flex items-center gap-2">
              <span className="px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB] flex items-center gap-1.5">
                <Radio className="w-3 h-3 animate-pulse" />
                Live WebSocket Stream
              </span>
              <span className="text-xs text-[#8C887D]">Instant APNs & FCM Push Bridge</span>
            </div>
            <h1 className="text-2xl font-serif font-bold text-[#2C2E2A] mt-1.5">Real-Time Notification Center</h1>
            <p className="text-xs text-[#6B6E68] mt-0.5">Multiplatform event dispatcher for academic grades, emergency notices, and teacher DMs</p>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => setSoundEnabled(!soundEnabled)}
              className={`p-2.5 rounded-xl border text-xs font-semibold flex items-center gap-1.5 transition-colors cursor-pointer ${
                soundEnabled
                  ? 'bg-[#FEFAE0] border-[#E9E4DB] text-[#5F6F52]'
                  : 'bg-[#FAF9F6] border-[#E9E4DB] text-[#8C887D]'
              }`}
              title={soundEnabled ? 'Push Chime Sound Active' : 'Sound Muted'}
            >
              {soundEnabled ? <Volume2 className="w-4 h-4" /> : <VolumeX className="w-4 h-4" />}
              <span>{soundEnabled ? 'Chime ON' : 'Muted'}</span>
            </button>

            <button
              onClick={onMarkAllAsRead}
              className="px-3.5 py-2.5 rounded-xl bg-[#FAF9F6] hover:bg-[#F2EDE4] text-[#2C2E2A] border border-[#D9D1C5] text-xs font-bold flex items-center gap-1.5 transition-colors cursor-pointer"
            >
              <CheckCheck className="w-4 h-4 text-[#5F6F52]" />
              <span>Mark All Read</span>
            </button>
          </div>
        </div>

        {/* Real-time Simulator Panel */}
        <div className="bg-[#FAF9F6] border border-[#E9E4DB] rounded-2xl p-4.5 space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold uppercase tracking-wider text-[#2C2E2A] flex items-center gap-1.5">
              <Sparkles className="w-3.5 h-3.5 text-[#5F6F52]" />
              Interactive Push Dispatch Simulator
            </span>
            <span className="text-[11px] text-[#8C887D]">Click to trigger instant live notification</span>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
            <button
              onClick={() => onSimulateNotification('grade')}
              className="p-3 bg-white hover:bg-[#F2EDE4] border border-[#E9E4DB] hover:border-[#D9D1C5] text-left rounded-xl transition-all cursor-pointer group shadow-xs"
            >
              <div className="flex items-center gap-2">
                <Award className="w-4 h-4 text-[#5F6F52] group-hover:scale-110 transition-transform" />
                <span className="text-xs font-bold text-[#2C2E2A]">Grade Posted</span>
              </div>
              <p className="text-[10px] text-[#6B6E68] mt-1 line-clamp-1">AP Physics Exam (94/100)</p>
            </button>

            <button
              onClick={() => onSimulateNotification('announcement')}
              className="p-3 bg-white hover:bg-[#F2EDE4] border border-[#E9E4DB] hover:border-[#D9D1C5] text-left rounded-xl transition-all cursor-pointer group shadow-xs"
            >
              <div className="flex items-center gap-2">
                <Bell className="w-4 h-4 text-[#5F6F52] group-hover:scale-110 transition-transform" />
                <span className="text-xs font-bold text-[#2C2E2A]">Class Notice</span>
              </div>
              <p className="text-[10px] text-[#6B6E68] mt-1 line-clamp-1">Lab Session Rescheduled</p>
            </button>

            <button
              onClick={() => onSimulateNotification('message')}
              className="p-3 bg-white hover:bg-[#F2EDE4] border border-[#E9E4DB] hover:border-[#D9D1C5] text-left rounded-xl transition-all cursor-pointer group shadow-xs"
            >
              <div className="flex items-center gap-2">
                <MessageSquare className="w-4 h-4 text-[#5F6F52] group-hover:scale-110 transition-transform" />
                <span className="text-xs font-bold text-[#2C2E2A]">Teacher DM</span>
              </div>
              <p className="text-[10px] text-[#6B6E68] mt-1 line-clamp-1">Office hours invitation</p>
            </button>

            <button
              onClick={() => onSimulateNotification('emergency')}
              className="p-3 bg-white hover:bg-[#F2EDE4] border border-[#E9E4DB] hover:border-[#D9D1C5] text-left rounded-xl transition-all cursor-pointer group shadow-xs"
            >
              <div className="flex items-center gap-2">
                <AlertTriangle className="w-4 h-4 text-[#D67D5B] group-hover:scale-110 transition-transform" />
                <span className="text-xs font-bold text-[#2C2E2A]">Urgent Alert</span>
              </div>
              <p className="text-[10px] text-[#6B6E68] mt-1 line-clamp-1">Inclement Weather Notice</p>
            </button>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        
        {/* Left Col: Notification Feed */}
        <div className="lg:col-span-8 space-y-4">
          
          {/* Category Filter Chips */}
          <div className="flex items-center gap-2 overflow-x-auto pb-1 text-xs">
            <button
              onClick={() => setSelectedFilter('all')}
              className={`px-3.5 py-1.5 rounded-xl font-bold transition-all cursor-pointer ${
                selectedFilter === 'all' ? 'bg-[#5F6F52] text-white shadow-xs' : 'bg-white border border-[#E9E4DB] text-[#6B6E68] hover:text-[#2C2E2A]'
              }`}
            >
              All Notifications ({notifications.length})
            </button>
            <button
              onClick={() => setSelectedFilter('grade')}
              className={`px-3.5 py-1.5 rounded-xl font-bold transition-all cursor-pointer ${
                selectedFilter === 'grade' ? 'bg-[#5F6F52] text-white shadow-xs' : 'bg-white border border-[#E9E4DB] text-[#6B6E68] hover:text-[#2C2E2A]'
              }`}
            >
              Academic Grades
            </button>
            <button
              onClick={() => setSelectedFilter('message')}
              className={`px-3.5 py-1.5 rounded-xl font-bold transition-all cursor-pointer ${
                selectedFilter === 'message' ? 'bg-[#5F6F52] text-white shadow-xs' : 'bg-white border border-[#E9E4DB] text-[#6B6E68] hover:text-[#2C2E2A]'
              }`}
            >
              Messages
            </button>
            <button
              onClick={() => setSelectedFilter('announcement')}
              className={`px-3.5 py-1.5 rounded-xl font-bold transition-all cursor-pointer ${
                selectedFilter === 'announcement' ? 'bg-[#5F6F52] text-white shadow-xs' : 'bg-white border border-[#E9E4DB] text-[#6B6E68] hover:text-[#2C2E2A]'
              }`}
            >
              Announcements
            </button>
            <button
              onClick={() => setSelectedFilter('emergency')}
              className={`px-3.5 py-1.5 rounded-xl font-bold transition-all cursor-pointer ${
                selectedFilter === 'emergency' ? 'bg-[#D67D5B] text-white shadow-xs' : 'bg-white border border-[#E9E4DB] text-[#6B6E68] hover:text-[#2C2E2A]'
              }`}
            >
              Urgent & Emergency
            </button>
          </div>

          {/* List of Notification items */}
          <div className="space-y-3">
            {filteredNotifications.length === 0 ? (
              <div className="bg-white border border-[#E9E4DB] rounded-[24px] p-8 text-center text-[#8C887D] text-xs">
                <CheckCircle2 className="w-8 h-8 text-[#5F6F52] mx-auto mb-2" />
                <p>No notifications in this category.</p>
              </div>
            ) : (
              filteredNotifications.map((notif) => {
                return (
                  <div
                    key={notif.id}
                    className={`p-4.5 rounded-2xl border transition-all ${
                      !notif.read
                        ? notif.priority === 'urgent'
                          ? 'bg-[#FEFAE0] border-[#D67D5B]/50 shadow-sm'
                          : 'bg-[#FEFAE0]/40 border-[#5F6F52]/40 shadow-xs'
                        : 'bg-white border-[#E9E4DB] opacity-85'
                    }`}
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="flex items-start gap-3.5">
                        <div className="mt-0.5">
                          {notif.category === 'grade' && (
                            <div className="w-9 h-9 rounded-xl bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB] flex items-center justify-center">
                              <Award className="w-4 h-4" />
                            </div>
                          )}
                          {notif.category === 'message' && (
                            <div className="w-9 h-9 rounded-xl bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB] flex items-center justify-center">
                              <MessageSquare className="w-4 h-4" />
                            </div>
                          )}
                          {notif.category === 'announcement' && (
                            <div className="w-9 h-9 rounded-xl bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB] flex items-center justify-center">
                              <Bell className="w-4 h-4" />
                            </div>
                          )}
                          {notif.category === 'emergency' && (
                            <div className="w-9 h-9 rounded-xl bg-[#FEFAE0] text-[#D67D5B] border border-[#E9E4DB] flex items-center justify-center animate-pulse">
                              <AlertTriangle className="w-4 h-4" />
                            </div>
                          )}
                        </div>

                        <div>
                          <div className="flex items-center gap-2">
                            <h4 className="text-sm font-serif font-bold text-[#2C2E2A]">{notif.title}</h4>
                            {notif.courseCode && (
                              <span className="text-[10px] font-mono px-2 py-0.5 bg-[#E9E4DB] rounded-md text-[#2C2E2A] font-bold">
                                {notif.courseCode}
                              </span>
                            )}
                          </div>
                          <p className="text-xs text-[#6B6E68] mt-1 leading-relaxed">{notif.message}</p>
                          <div className="flex items-center gap-3 text-[11px] text-[#8C887D] mt-2 font-medium">
                            <span>{notif.timestamp}</span>
                            {notif.senderName && <span>From: {notif.senderName}</span>}
                          </div>
                        </div>
                      </div>

                      <div className="flex items-center gap-1 shrink-0">
                        {!notif.read && (
                          <button
                            onClick={() => onMarkAsRead(notif.id)}
                            className="p-2 text-[#8C887D] hover:text-[#5F6F52] rounded-xl hover:bg-[#F2EDE4] transition-colors cursor-pointer"
                            title="Mark as read"
                          >
                            <CheckCircle2 className="w-4 h-4" />
                          </button>
                        )}
                        <button
                          onClick={() => onDeleteNotification(notif.id)}
                          className="p-2 text-[#8C887D] hover:text-[#D67D5B] rounded-xl hover:bg-[#F2EDE4] transition-colors cursor-pointer"
                          title="Delete notification"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>

        {/* Right Col: Teacher / Admin Broadcast Composer */}
        <div className="lg:col-span-4 space-y-4">
          <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-6 space-y-4 shadow-sm">
            <div className="flex items-center gap-2">
              <Radio className="w-4 h-4 text-[#5F6F52]" />
              <h3 className="text-sm font-serif font-bold text-[#2C2E2A]">Broadcast Announcement</h3>
            </div>
            <p className="text-xs text-[#6B6E68] leading-relaxed">
              Send instant high-priority push notifications to selected classes, grade levels, or the entire school body.
            </p>

            <form onSubmit={handleBroadcastSubmit} className="space-y-3.5 text-xs">
              <div>
                <label className="block text-[#2C2E2A] font-bold mb-1">Target Audience</label>
                <select
                  value={broadcastTarget}
                  onChange={(e) => setBroadcastTarget(e.target.value)}
                  className="w-full bg-[#FAF9F6] border border-[#D9D1C5] rounded-xl px-3 py-2 text-[#2C2E2A] font-medium focus:outline-none focus:border-[#5F6F52]"
                >
                  <option value="All School (Students & Parents)">All School (Students & Parents)</option>
                  <option value="Grade 11 (Juniors)">Grade 11 (Juniors)</option>
                  <option value="AP Computer Science A - Period 1">AP Computer Science A - Period 1</option>
                  <option value="AP Physics C - Period 3">AP Physics C - Period 3</option>
                </select>
              </div>

              <div>
                <label className="block text-[#2C2E2A] font-bold mb-1">Priority Level</label>
                <select
                  value={broadcastPriority}
                  onChange={(e) => setBroadcastPriority(e.target.value as any)}
                  className="w-full bg-[#FAF9F6] border border-[#D9D1C5] rounded-xl px-3 py-2 text-[#2C2E2A] font-medium focus:outline-none focus:border-[#5F6F52]"
                >
                  <option value="medium">Standard Notice</option>
                  <option value="high">High Academic Priority</option>
                  <option value="urgent">Urgent / Emergency Alert</option>
                </select>
              </div>

              <div>
                <label className="block text-[#2C2E2A] font-bold mb-1">Broadcast Headline</label>
                <input
                  type="text"
                  placeholder="e.g. Schedule Change for Period 4"
                  value={broadcastTitle}
                  onChange={(e) => setBroadcastTitle(e.target.value)}
                  className="w-full bg-[#FAF9F6] border border-[#D9D1C5] rounded-xl px-3 py-2 text-[#2C2E2A] placeholder-[#8C887D] focus:outline-none focus:border-[#5F6F52]"
                />
              </div>

              <div>
                <label className="block text-[#2C2E2A] font-bold mb-1">Message Content</label>
                <textarea
                  rows={3}
                  placeholder="Type broadcast description..."
                  value={broadcastMessage}
                  onChange={(e) => setBroadcastMessage(e.target.value)}
                  className="w-full bg-[#FAF9F6] border border-[#D9D1C5] rounded-xl px-3 py-2 text-[#2C2E2A] placeholder-[#8C887D] focus:outline-none focus:border-[#5F6F52] resize-none"
                />
              </div>

              <button
                type="submit"
                disabled={!broadcastTitle.trim() || !broadcastMessage.trim()}
                className="w-full py-2.5 rounded-xl bg-[#5F6F52] hover:bg-[#4E5C43] disabled:opacity-40 text-white font-bold text-xs flex items-center justify-center gap-1.5 shadow-sm transition-all cursor-pointer"
              >
                <Send className="w-3.5 h-3.5" />
                <span>Dispatch Instant Push Broadcast</span>
              </button>
            </form>
          </div>
        </div>

      </div>

    </div>
  );
};
