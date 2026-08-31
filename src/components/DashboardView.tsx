import React from 'react';
import { 
  TrendingUp, 
  BookOpen, 
  Calendar, 
  CheckCircle2, 
  Clock, 
  MessageSquare, 
  Bell, 
  Calculator, 
  ShieldCheck, 
  FileText, 
  ArrowUpRight, 
  Award,
  AlertCircle,
  Users,
  Send,
  Zap,
  Sparkles
} from 'lucide-react';
import { UserProfile, Course, SchedulePeriod, NotificationItem } from '../types';

interface DashboardViewProps {
  user: UserProfile;
  courses: Course[];
  schedule: SchedulePeriod[];
  notifications: NotificationItem[];
  onNavigateTab: (tab: 'grades' | 'messaging' | 'notifications' | 'flutter_code') => void;
  onSelectCourse: (course: Course) => void;
  onOpenGpaCalc: () => void;
  onOpenTranscript: () => void;
  onTriggerQuickSimulation: () => void;
}

export const DashboardView: React.FC<DashboardViewProps> = ({
  user,
  courses,
  schedule,
  notifications,
  onNavigateTab,
  onSelectCourse,
  onOpenGpaCalc,
  onOpenTranscript,
  onTriggerQuickSimulation,
}) => {
  // Calculate average percentage
  const avgPercentage = (
    courses.reduce((acc, c) => acc + c.currentPercentage, 0) / courses.length
  ).toFixed(1);

  const pendingAssignments = courses.flatMap(c => 
    c.assignments.filter(a => a.status === 'pending').map(a => ({ ...a, courseName: c.name, courseCode: c.code }))
  );

  return (
    <div className="space-y-6">
      
      {/* Welcome Banner in Natural Tones Forest Sage */}
      <div className="relative overflow-hidden rounded-[32px] bg-[#5F6F52] text-[#FAF9F6] p-6 sm:p-8 shadow-[0_14px_40px_rgba(95,111,82,0.18)] border border-[#5F6F52]">
        <div className="absolute right-0 top-0 -mt-10 -mr-10 w-72 h-72 bg-[#A9B388]/25 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute left-1/2 bottom-0 -mb-12 w-60 h-60 bg-[#FEFAE0]/10 rounded-full blur-2xl pointer-events-none" />
        
        <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <span className="px-3 py-1 rounded-full text-[11px] font-bold uppercase tracking-widest bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
                {user.role} Portal
              </span>
              <span className="text-xs text-[#FAF9F6]/85 flex items-center gap-1">
                <ShieldCheck className="w-3.5 h-3.5 text-[#FEFAE0]" />
                FERPA Compliant • E2EE Active
              </span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-serif font-bold text-white tracking-tight">
              Welcome back, {user.name}
            </h1>
            <p className="text-xs sm:text-sm text-[#FAF9F6]/85 max-w-xl leading-relaxed">
              {user.role === 'student' && `${user.gradeLevel} • ID: ${user.schoolId} • Lincoln High STEM Academy`}
              {user.role === 'teacher' && `${user.department} • 4 Active Sections • 118 Students`}
              {user.role === 'parent' && `Viewing Academic Record for Alex Rivera (Grade 11)`}
              {user.role === 'admin' && `Lincoln District High School • Central Administrative Control`}
            </p>
          </div>

          {/* Quick Action Shortcuts */}
          <div className="flex flex-wrap items-center gap-2.5">
            <button
              onClick={onOpenGpaCalc}
              className="flex items-center gap-1.5 px-4 py-2.5 rounded-2xl bg-[#FEFAE0] hover:bg-[#F4F0D6] text-[#5F6F52] text-xs font-bold shadow-sm transition-all cursor-pointer border border-[#E9E4DB]"
            >
              <Calculator className="w-4 h-4" />
              <span>What-If GPA Calc</span>
            </button>
            <button
              onClick={onOpenTranscript}
              className="flex items-center gap-1.5 px-4 py-2.5 rounded-2xl bg-[#FAF9F6]/20 hover:bg-[#FAF9F6]/30 text-white border border-white/25 text-xs font-semibold transition-all cursor-pointer backdrop-blur-sm"
            >
              <FileText className="w-4 h-4 text-[#FEFAE0]" />
              <span>Transcript PDF</span>
            </button>
            <button
              onClick={() => onNavigateTab('messaging')}
              className="flex items-center gap-1.5 px-4 py-2.5 rounded-2xl bg-[#FAF9F6]/20 hover:bg-[#FAF9F6]/30 text-white border border-white/25 text-xs font-semibold transition-all cursor-pointer backdrop-blur-sm"
            >
              <MessageSquare className="w-4 h-4 text-[#FEFAE0]" />
              <span>Teacher Chat</span>
            </button>
          </div>
        </div>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        
        {/* GPA Metric Card */}
        <div className="bg-white rounded-[24px] p-5 border border-[#E9E4DB] shadow-sm hover:border-[#D9D1C5] transition-all">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-bold text-[#8C887D] uppercase tracking-widest">Cumulative GPA</span>
            <span className="p-2 rounded-xl bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
              <Award className="w-4 h-4" />
            </span>
          </div>
          <div className="mt-3 flex items-baseline gap-2">
            <span className="text-3xl font-serif font-bold text-[#2C2E2A]">{user.gpa?.unweighted ?? 3.88}</span>
            <span className="text-xs font-medium text-[#8C887D]">/ 4.0 Unweighted</span>
          </div>
          <div className="mt-2 flex items-center justify-between text-xs pt-2 border-t border-[#E9E4DB]">
            <span className="text-[#5F6F52] font-semibold">Weighted: {user.gpa?.weighted ?? 4.12}</span>
            <span className="text-[#5F6F52] flex items-center gap-0.5 font-bold">
              <TrendingUp className="w-3 h-3" />
              {user.gpa?.classRank ?? 'Top 4%'}
            </span>
          </div>
        </div>

        {/* Overall Academic Average */}
        <div className="bg-white rounded-[24px] p-5 border border-[#E9E4DB] shadow-sm hover:border-[#D9D1C5] transition-all">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-bold text-[#8C887D] uppercase tracking-widest">Course Average</span>
            <span className="p-2 rounded-xl bg-[#E9E4DB] text-[#5F6F52] border border-[#D9D1C5]">
              <TrendingUp className="w-4 h-4" />
            </span>
          </div>
          <div className="mt-3 flex items-baseline gap-2">
            <span className="text-3xl font-serif font-bold text-[#2C2E2A]">{avgPercentage}%</span>
            <span className="text-xs font-bold text-[#5F6F52]">Grade A Avg</span>
          </div>
          <div className="mt-2 flex items-center justify-between text-xs text-[#8C887D] pt-2 border-t border-[#E9E4DB]">
            <span>6 Active Courses</span>
            <span className="text-[#6B6E68] font-medium">21.0 Total Credits</span>
          </div>
        </div>

        {/* Attendance Rate */}
        <div className="bg-white rounded-[24px] p-5 border border-[#E9E4DB] shadow-sm hover:border-[#D9D1C5] transition-all">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-bold text-[#8C887D] uppercase tracking-widest">Attendance Rate</span>
            <span className="p-2 rounded-xl bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
              <CheckCircle2 className="w-4 h-4" />
            </span>
          </div>
          <div className="mt-3 flex items-baseline gap-2">
            <span className="text-3xl font-serif font-bold text-[#2C2E2A]">98.5%</span>
            <span className="text-xs font-bold text-[#5F6F52]">Exemplary</span>
          </div>
          <div className="mt-2 flex items-center justify-between text-xs text-[#8C887D] pt-2 border-t border-[#E9E4DB]">
            <span>100% Present this week</span>
            <span className="text-[#5F6F52] font-semibold">0 Unexcused</span>
          </div>
        </div>

        {/* Active Communications / Notifications */}
        <div className="bg-white rounded-[24px] p-5 border border-[#E9E4DB] shadow-sm hover:border-[#D9D1C5] transition-all">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-bold text-[#8C887D] uppercase tracking-widest">Real-time Hub</span>
            <span className="p-2 rounded-xl bg-[#F2EDE4] text-[#D67D5B] border border-[#E9E4DB]">
              <Zap className="w-4 h-4" />
            </span>
          </div>
          <div className="mt-3 flex items-baseline gap-2">
            <span className="text-3xl font-serif font-bold text-[#2C2E2A]">{notifications.filter(n => !n.read).length}</span>
            <span className="text-xs font-bold text-[#D67D5B]">Unread Alerts</span>
          </div>
          <div className="mt-2 flex items-center justify-between text-xs pt-2 border-t border-[#E9E4DB]">
            <button
              onClick={() => onNavigateTab('notifications')}
              className="text-[#5F6F52] hover:text-[#2C2E2A] font-bold flex items-center gap-1 cursor-pointer"
            >
              <span>View alerts</span>
              <ArrowUpRight className="w-3 h-3" />
            </button>
            <span className="text-[#8C887D]">WebSocket Live</span>
          </div>
        </div>

      </div>

      {/* Main Split Grid: Courses & Today's Schedule */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Left 2 Cols: Course Grade Roster */}
        <div className="lg:col-span-2 space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <BookOpen className="w-5 h-5 text-[#5F6F52]" />
              <h2 className="text-lg font-serif font-bold text-[#2C2E2A] tracking-tight">Active Academic Courses</h2>
            </div>
            <button
              onClick={() => onNavigateTab('grades')}
              className="text-xs text-[#5F6F52] hover:text-[#2C2E2A] font-bold flex items-center gap-1 cursor-pointer"
            >
              <span>View full gradebook</span>
              <ArrowUpRight className="w-3.5 h-3.5" />
            </button>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
            {courses.map((course) => (
              <div
                key={course.id}
                onClick={() => onSelectCourse(course)}
                className="group relative bg-white hover:bg-[#FAF9F6] border border-[#E9E4DB] hover:border-[#D9D1C5] rounded-[24px] p-5 transition-all duration-200 cursor-pointer shadow-sm hover:shadow-md"
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    <div
                      className="w-10 h-10 rounded-2xl flex items-center justify-center font-bold text-xs text-white shadow-sm"
                      style={{ backgroundColor: course.color }}
                    >
                      {course.code.split('-')[0]}
                    </div>
                    <div>
                      <h3 className="text-sm font-bold text-[#2C2E2A] group-hover:text-[#5F6F52] transition-colors line-clamp-1">
                        {course.name}
                      </h3>
                      <p className="text-xs text-[#8C887D]">{course.teacherName} • {course.period.split(' ')[0]}</p>
                    </div>
                  </div>
                  
                  {/* Grade Badge */}
                  <div className="text-right">
                    <span
                      className="text-base font-serif font-bold px-2.5 py-0.5 rounded-xl border"
                      style={{
                        backgroundColor: `${course.color}15`,
                        borderColor: `${course.color}35`,
                        color: course.color
                      }}
                    >
                      {course.letterGrade}
                    </span>
                    <p className="text-[11px] text-[#8C887D] mt-1 font-mono font-medium">{course.currentPercentage}%</p>
                  </div>
                </div>

                {/* Progress bar */}
                <div className="mt-4">
                  <div className="w-full bg-[#E9E4DB] h-2 rounded-full overflow-hidden">
                    <div
                      className="h-full rounded-full transition-all duration-500"
                      style={{
                        width: `${Math.min(course.currentPercentage, 100)}%`,
                        backgroundColor: course.color
                      }}
                    />
                  </div>
                </div>

                <div className="mt-3.5 flex items-center justify-between text-[11px] text-[#8C887D] pt-2.5 border-t border-[#E9E4DB]">
                  <span>Room: {course.room}</span>
                  <span className="text-[#6B6E68] font-medium">{course.assignments.length} assignments</span>
                </div>
              </div>
            ))}
          </div>

          {/* Pending Deadlines Banner */}
          {pendingAssignments.length > 0 && (
            <div className="bg-[#FEFAE0] border border-[#D9D1C5] rounded-[24px] p-4.5 flex items-center justify-between gap-4 shadow-sm">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-[#E9E4DB] text-[#D67D5B] flex items-center justify-center shrink-0 border border-[#D9D1C5]">
                  <Clock className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="text-xs font-bold uppercase tracking-wider text-[#D67D5B]">Upcoming Submission Pending</h4>
                  <p className="text-xs text-[#2C2E2A] mt-0.5 font-medium">
                    {pendingAssignments[0].title} ({pendingAssignments[0].courseCode}) • Due {pendingAssignments[0].dueDate}
                  </p>
                </div>
              </div>
              <button
                onClick={() => onNavigateTab('grades')}
                className="px-3.5 py-2 bg-[#5F6F52] hover:bg-[#4E5C43] text-white text-xs font-bold rounded-xl transition-colors whitespace-nowrap cursor-pointer shadow-sm"
              >
                View Rubric
              </button>
            </div>
          )}
        </div>

        {/* Right Col: Today's Schedule & Live Stream */}
        <div className="space-y-6">
          
          {/* Today's Schedule Card */}
          <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-5 shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Calendar className="w-4 h-4 text-[#5F6F52]" />
                <h3 className="text-sm font-serif font-bold text-[#2C2E2A]">Today's Class Schedule</h3>
              </div>
              <span className="text-[10px] font-bold uppercase tracking-wider px-2.5 py-1 bg-[#FEFAE0] text-[#5F6F52] rounded-full border border-[#E9E4DB]">
                Period 3 Active
              </span>
            </div>

            <div className="space-y-2.5">
              {schedule.map((item, idx) => {
                const isActive = idx === 2; // Simulated active period
                return (
                  <div
                    key={item.id}
                    className={`flex items-center justify-between p-3 rounded-2xl border transition-all ${
                      isActive 
                        ? 'bg-[#FEFAE0] border-[#5F6F52]/40 shadow-sm' 
                        : 'bg-[#FAF9F6] border-[#E9E4DB] hover:border-[#D9D1C5]'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <div
                        className="w-3 h-3 rounded-full shrink-0"
                        style={{ backgroundColor: item.color }}
                      />
                      <div>
                        <p className={`text-xs font-bold ${isActive ? 'text-[#5F6F52]' : 'text-[#2C2E2A]'}`}>
                          {item.courseName}
                        </p>
                        <p className="text-[11px] text-[#8C887D]">{item.time} • {item.room}</p>
                      </div>
                    </div>
                    <span className="text-[11px] text-[#6B6E68] font-medium">{item.teacher}</span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Real-time Notifications Feed */}
          <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-5 shadow-sm">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <Bell className="w-4 h-4 text-[#5F6F52]" />
                <h3 className="text-sm font-serif font-bold text-[#2C2E2A]">Live Academic Stream</h3>
              </div>
              <button
                onClick={onTriggerQuickSimulation}
                className="text-[11px] text-[#5F6F52] hover:text-[#2C2E2A] font-bold flex items-center gap-1 cursor-pointer"
              >
                <Sparkles className="w-3 h-3 text-[#D67D5B]" />
                <span>Simulate</span>
              </button>
            </div>

            <div className="space-y-2.5">
              {notifications.slice(0, 3).map((notif) => (
                <div
                  key={notif.id}
                  onClick={() => onNavigateTab(notif.category === 'message' ? 'messaging' : 'notifications')}
                  className={`p-3 rounded-2xl border transition-all cursor-pointer ${
                    !notif.read
                      ? 'bg-[#FAF9F6] border-[#D9D1C5] border-l-4 border-l-[#5F6F52]'
                      : 'bg-[#FAF9F6]/60 border-[#E9E4DB] opacity-85'
                  }`}
                >
                  <div className="flex items-center justify-between gap-1">
                    <span className="text-xs font-bold text-[#2C2E2A] line-clamp-1">{notif.title}</span>
                    <span className="text-[10px] text-[#8C887D] shrink-0">{notif.timestamp}</span>
                  </div>
                  <p className="text-[11px] text-[#6B6E68] mt-1 line-clamp-2 leading-relaxed">{notif.message}</p>
                </div>
              ))}
            </div>
          </div>

        </div>

      </div>

    </div>
  );
};
