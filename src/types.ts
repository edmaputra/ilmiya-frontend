export type UserRole = 'student' | 'teacher' | 'parent' | 'admin';

export type DeviceView = 'responsive' | 'ios' | 'android' | 'tablet';

export type ActiveTab = 'dashboard' | 'grades' | 'messaging' | 'notifications' | 'schedule' | 'flutter_code' | 'settings';

export interface UserProfile {
  id: string;
  name: string;
  role: UserRole;
  avatar: string;
  email: string;
  schoolId: string;
  gradeLevel?: string;
  department?: string;
  gpa?: {
    unweighted: number;
    weighted: number;
    trend: 'up' | 'down' | 'stable';
    classRank: string;
  };
  unreadNotifications: number;
  unreadMessages: number;
}

export interface Assignment {
  id: string;
  title: string;
  category: 'Homework' | 'Quiz' | 'Exam' | 'Project' | 'Lab';
  score: number;
  maxScore: number;
  weight: number; // percentage
  dueDate: string;
  submittedDate?: string;
  status: 'graded' | 'pending' | 'missing' | 'late';
  feedback?: string;
  rubricScores?: { criterion: string; score: number; max: number }[];
}

export interface Course {
  id: string;
  code: string;
  name: string;
  teacherId: string;
  teacherName: string;
  teacherAvatar: string;
  period: string;
  room: string;
  credits: number;
  currentPercentage: number;
  letterGrade: string;
  color: string;
  iconName: string;
  assignments: Assignment[];
  categoryWeights: { category: string; weight: number; currentAvg: number }[];
  attendanceRate: number;
  officeHours: string;
}

export interface NotificationItem {
  id: string;
  title: string;
  message: string;
  timestamp: string;
  category: 'grade' | 'message' | 'announcement' | 'attendance' | 'emergency';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  read: boolean;
  actionUrl?: string;
  courseCode?: string;
  senderName?: string;
  senderAvatar?: string;
}

export interface ChatMessage {
  id: string;
  senderId: string;
  senderName: string;
  senderRole: UserRole;
  senderAvatar: string;
  content: string;
  timestamp: string;
  isEncrypted: boolean;
  status: 'sending' | 'sent' | 'delivered' | 'read';
  attachment?: {
    name: string;
    type: 'pdf' | 'image' | 'code' | 'doc';
    size: string;
    url?: string;
  };
  contextTag?: {
    type: 'assignment' | 'grade' | 'exam';
    title: string;
    id: string;
  };
}

export interface ChatChannel {
  id: string;
  name: string;
  type: 'direct' | 'class_group' | 'office_hours';
  participants: {
    id: string;
    name: string;
    role: UserRole;
    avatar: string;
    online: boolean;
  }[];
  courseCode?: string;
  lastMessage?: {
    text: string;
    timestamp: string;
    senderId: string;
  };
  unreadCount: number;
  isEncrypted: boolean;
}

export interface SchedulePeriod {
  id: string;
  period: string;
  time: string;
  courseCode: string;
  courseName: string;
  room: string;
  teacher: string;
  color: string;
  day: 'Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri';
}

export interface FlutterCodeFile {
  filename: string;
  path: string;
  language: string;
  description: string;
  content: string;
}
