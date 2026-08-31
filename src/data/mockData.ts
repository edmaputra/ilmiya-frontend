import { UserProfile, Course, NotificationItem, ChatChannel, ChatMessage, SchedulePeriod } from '../types';

export const PROFILES: Record<string, UserProfile> = {
  student: {
    id: 'user_student_1',
    name: 'Alex Rivera',
    role: 'student',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
    email: 'alex.rivera@lincolnhigh.edu',
    schoolId: 'STU-2026-8941',
    gradeLevel: 'Grade 11 (Junior)',
    gpa: {
      unweighted: 3.88,
      weighted: 4.12,
      trend: 'up',
      classRank: '14 of 420 (Top 4%)'
    },
    unreadNotifications: 3,
    unreadMessages: 2
  },
  teacher: {
    id: 'user_teacher_1',
    name: 'Dr. Eleanor Vance',
    role: 'teacher',
    avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
    email: 'e.vance@lincolnhigh.edu',
    schoolId: 'FAC-2018-0412',
    department: 'STEM / Computer Science & Mathematics',
    unreadNotifications: 5,
    unreadMessages: 4
  },
  parent: {
    id: 'user_parent_1',
    name: 'Marco Rivera',
    role: 'parent',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    email: 'marco.rivera@rivera-tech.io',
    schoolId: 'PAR-8941-A',
    unreadNotifications: 2,
    unreadMessages: 1
  },
  admin: {
    id: 'user_admin_1',
    name: 'Principal Elena Martinez',
    role: 'admin',
    avatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&auto=format&fit=crop&q=80',
    email: 'e.martinez@lincolnhigh.edu',
    schoolId: 'ADM-2012-0001',
    department: 'School Administration & District Liaison',
    unreadNotifications: 8,
    unreadMessages: 6
  }
};

export const INITIAL_COURSES: Course[] = [
  {
    id: 'course_ap_cs',
    code: 'CS-301',
    name: 'AP Computer Science A',
    teacherId: 'user_teacher_1',
    teacherName: 'Dr. Eleanor Vance',
    teacherAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
    period: 'Period 1 (08:00 - 08:50 AM)',
    room: 'Lab Tech-402',
    credits: 4.0,
    currentPercentage: 96.4,
    letterGrade: 'A',
    color: '#5F6F52',
    iconName: 'Code',
    attendanceRate: 98.5,
    officeHours: 'Mon/Wed 3:15 - 4:15 PM (Room 402)',
    categoryWeights: [
      { category: 'Projects & Labs', weight: 40, currentAvg: 98.0 },
      { category: 'Unit Exams', weight: 35, currentAvg: 94.5 },
      { category: 'Quizzes & Coding Drills', weight: 15, currentAvg: 96.0 },
      { category: 'Homework & Practice', weight: 10, currentAvg: 100.0 }
    ],
    assignments: [
      {
        id: 'asg_cs_1',
        title: 'Project 4: Recursive Binary Tree Search',
        category: 'Project',
        score: 98,
        maxScore: 100,
        weight: 15,
        dueDate: '2026-03-24',
        submittedDate: '2026-03-23',
        status: 'graded',
        feedback: 'Exemplary implementation of balancing logic. Well-commented edge cases.',
        rubricScores: [
          { criterion: 'Algorithm Correctness', score: 40, max: 40 },
          { criterion: 'Time/Space Complexity', score: 30, max: 30 },
          { criterion: 'Code Cleanliness & Docs', score: 28, max: 30 }
        ]
      },
      {
        id: 'asg_cs_2',
        title: 'Midterm Exam 2: OOP & Inheritance',
        category: 'Exam',
        score: 94,
        maxScore: 100,
        weight: 20,
        dueDate: '2026-03-15',
        submittedDate: '2026-03-15',
        status: 'graded',
        feedback: 'Strong grasp of polymorphic method overriding. Minor syntax typo on Question 8.',
        rubricScores: [
          { criterion: 'Multiple Choice Concept', score: 48, max: 50 },
          { criterion: 'Free Response Problem', score: 46, max: 50 }
        ]
      },
      {
        id: 'asg_cs_3',
        title: 'Lab 8: Graph Traversal (BFS & DFS)',
        category: 'Lab',
        score: 100,
        maxScore: 100,
        weight: 10,
        dueDate: '2026-03-08',
        submittedDate: '2026-03-07',
        status: 'graded',
        feedback: 'Flawless execution! Passed all 16 hidden unit test suites.'
      },
      {
        id: 'asg_cs_4',
        title: 'Final Term Capstone: Distributed State Machine',
        category: 'Project',
        score: 0,
        maxScore: 100,
        weight: 25,
        dueDate: '2026-04-18',
        status: 'pending',
        feedback: 'In progress. Milestone 1 proposal approved.'
      }
    ]
  },
  {
    id: 'course_ap_calc',
    code: 'MATH-401',
    name: 'AP Calculus BC',
    teacherId: 'user_teacher_2',
    teacherName: 'Prof. Marcus Chen',
    teacherAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
    period: 'Period 2 (09:00 - 09:50 AM)',
    room: 'Hall B-210',
    credits: 4.0,
    currentPercentage: 92.8,
    letterGrade: 'A-',
    color: '#A9B388',
    iconName: 'Percent',
    attendanceRate: 96.0,
    officeHours: 'Tue/Thu 3:30 - 4:30 PM (Room 210)',
    categoryWeights: [
      { category: 'Exams & Midterms', weight: 50, currentAvg: 91.5 },
      { category: 'Weekly Problem Sets', weight: 30, currentAvg: 95.0 },
      { category: 'Quizzes', weight: 20, currentAvg: 92.0 }
    ],
    assignments: [
      {
        id: 'asg_calc_1',
        title: 'Taylor & Maclaurin Series Exam',
        category: 'Exam',
        score: 91,
        maxScore: 100,
        weight: 25,
        dueDate: '2026-03-22',
        submittedDate: '2026-03-22',
        status: 'graded',
        feedback: 'Great work computing the radius of convergence. Review error bound bounds.'
      },
      {
        id: 'asg_calc_2',
        title: 'Problem Set #9: Polar Coordinates & Integration',
        category: 'Homework',
        score: 96,
        maxScore: 100,
        weight: 10,
        dueDate: '2026-03-14',
        submittedDate: '2026-03-13',
        status: 'graded',
        feedback: 'Clean step-by-step calculus derivations.'
      }
    ]
  },
  {
    id: 'course_ap_physics',
    code: 'PHYS-302',
    name: 'AP Physics C: Mechanics',
    teacherId: 'user_teacher_3',
    teacherName: 'Dr. Sarah Jenkins',
    teacherAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',
    period: 'Period 3 (10:05 - 10:55 AM)',
    room: 'Sci Wing-108',
    credits: 4.0,
    currentPercentage: 88.5,
    letterGrade: 'B+',
    color: '#43423E',
    iconName: 'Zap',
    attendanceRate: 100.0,
    officeHours: 'Wednesday 3:00 - 4:30 PM (Lab 108)',
    categoryWeights: [
      { category: 'Laboratory Experiments', weight: 35, currentAvg: 92.0 },
      { category: 'Unit Tests', weight: 45, currentAvg: 85.5 },
      { category: 'Homework & Conceptual', weight: 20, currentAvg: 90.0 }
    ],
    assignments: [
      {
        id: 'asg_phys_1',
        title: 'Rotational Dynamics & Torque Lab Report',
        category: 'Lab',
        score: 92,
        maxScore: 100,
        weight: 15,
        dueDate: '2026-03-20',
        submittedDate: '2026-03-19',
        status: 'graded',
        feedback: 'Excellent error propagation analysis and video tracking telemetry.'
      },
      {
        id: 'asg_phys_2',
        title: 'Unit 5 Test: Simple Harmonic Motion & Pendulums',
        category: 'Exam',
        score: 84,
        maxScore: 100,
        weight: 20,
        dueDate: '2026-03-12',
        submittedDate: '2026-03-12',
        status: 'graded',
        feedback: 'Review damping oscillations formulas and kinetic/potential exchange graphs.'
      }
    ]
  },
  {
    id: 'course_eng_lit',
    code: 'ENG-305',
    name: 'AP English Literature',
    teacherId: 'user_teacher_4',
    teacherName: 'Ms. Clara Oswald',
    teacherAvatar: 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=150&auto=format&fit=crop&q=80',
    period: 'Period 4 (11:05 - 11:55 AM)',
    room: 'Hum-304',
    credits: 3.0,
    currentPercentage: 94.2,
    letterGrade: 'A',
    color: '#D67D5B',
    iconName: 'BookOpen',
    attendanceRate: 97.0,
    officeHours: 'Friday 2:30 - 3:30 PM (Room 304)',
    categoryWeights: [
      { category: 'Essays & Critical Analysis', weight: 50, currentAvg: 95.0 },
      { category: 'Socratic Seminars', weight: 25, currentAvg: 96.0 },
      { category: 'Reading Quizzes', weight: 25, currentAvg: 91.0 }
    ],
    assignments: [
      {
        id: 'asg_eng_1',
        title: 'Comparative Essay: Modernist Symbolism in Joyce & Woolf',
        category: 'Project',
        score: 96,
        maxScore: 100,
        weight: 25,
        dueDate: '2026-03-18',
        submittedDate: '2026-03-17',
        status: 'graded',
        feedback: 'Sophisticated thesis with compelling textual evidence.'
      }
    ]
  },
  {
    id: 'course_us_hist',
    code: 'HIST-204',
    name: 'AP United States History',
    teacherId: 'user_teacher_5',
    teacherName: 'Mr. David Miller',
    teacherAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
    period: 'Period 5 (12:45 - 01:35 PM)',
    room: 'Soc-112',
    credits: 3.0,
    currentPercentage: 91.0,
    letterGrade: 'A-',
    color: '#C28E58',
    iconName: 'Globe',
    attendanceRate: 98.0,
    officeHours: 'Mon/Thu 3:15 - 4:00 PM (Room 112)',
    categoryWeights: [
      { category: 'DBQ & LEQ Essays', weight: 40, currentAvg: 90.0 },
      { category: 'Period Exams', weight: 40, currentAvg: 91.0 },
      { category: 'Primary Source Discussions', weight: 20, currentAvg: 93.0 }
    ],
    assignments: [
      {
        id: 'asg_hist_1',
        title: 'DBQ: The Industrial Revolution & Labor Movements',
        category: 'Project',
        score: 90,
        maxScore: 100,
        weight: 20,
        dueDate: '2026-03-19',
        submittedDate: '2026-03-19',
        status: 'graded',
        feedback: 'Strong contextualization and point-of-view sourcing analysis.'
      }
    ]
  },
  {
    id: 'course_spanish_3',
    code: 'LANG-301',
    name: 'Spanish III Honors',
    teacherId: 'user_teacher_6',
    teacherName: 'Sra. Sofia Alvarez',
    teacherAvatar: 'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?w=150&auto=format&fit=crop&q=80',
    period: 'Period 6 (01:45 - 02:35 PM)',
    room: 'Lang-208',
    credits: 3.0,
    currentPercentage: 97.5,
    letterGrade: 'A+',
    color: '#8C887D',
    iconName: 'Languages',
    attendanceRate: 100.0,
    officeHours: 'Tuesday 3:15 - 4:15 PM (Room 208)',
    categoryWeights: [
      { category: 'Oral Proficiency & Dialogue', weight: 35, currentAvg: 98.0 },
      { category: 'Grammar & Writing', weight: 35, currentAvg: 97.0 },
      { category: 'Cultural Projects', weight: 30, currentAvg: 97.5 }
    ],
    assignments: [
      {
        id: 'asg_sp_1',
        title: 'Oral Presentation: Latin American Magical Realism',
        category: 'Project',
        score: 98,
        maxScore: 100,
        weight: 20,
        dueDate: '2026-03-16',
        submittedDate: '2026-03-16',
        status: 'graded',
        feedback: 'Fluidez y vocabulario avanzado impresionante. ¡Excelente trabajo!'
      }
    ]
  }
];

export const INITIAL_NOTIFICATIONS: NotificationItem[] = [
  {
    id: 'notif_1',
    title: 'New Grade Posted: AP CS Project 4',
    message: 'Dr. Eleanor Vance graded "Recursive Binary Tree Search" with 98/100 (A+). Rubric feedback available.',
    timestamp: '12 mins ago',
    category: 'grade',
    priority: 'high',
    read: false,
    courseCode: 'CS-301',
    senderName: 'Dr. Eleanor Vance',
    senderAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80'
  },
  {
    id: 'notif_2',
    title: 'Secure Message from Dr. Vance',
    message: 'Regarding your inquiry on Binary Tree complexity: "Feel free to stop by office hours at 3:15 PM."',
    timestamp: '45 mins ago',
    category: 'message',
    priority: 'medium',
    read: false,
    courseCode: 'CS-301',
    senderName: 'Dr. Eleanor Vance',
    senderAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80'
  },
  {
    id: 'notif_3',
    title: 'AP Physics C Midterm Review Session',
    message: 'Dr. Sarah Jenkins scheduled a live review session for Wednesday 3:00 PM in Room 108.',
    timestamp: '2 hours ago',
    category: 'announcement',
    priority: 'medium',
    read: false,
    courseCode: 'PHYS-302',
    senderName: 'Dr. Sarah Jenkins',
    senderAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80'
  },
  {
    id: 'notif_4',
    title: 'District Notice: Q3 Progress Reports Published',
    message: 'Official Q3 report cards and GPA transcripts are now accessible in your SIS portal.',
    timestamp: '1 day ago',
    category: 'announcement',
    priority: 'high',
    read: true,
    senderName: 'Lincoln High Administration'
  },
  {
    id: 'notif_5',
    title: 'Attendance Verified: 100% On-Time This Week',
    message: 'Great job maintaining perfect attendance for all 6 scheduled periods.',
    timestamp: '2 days ago',
    category: 'attendance',
    priority: 'low',
    read: true
  }
];

export const INITIAL_CHANNELS: ChatChannel[] = [
  {
    id: 'chan_vance_direct',
    name: 'Dr. Eleanor Vance (AP CS)',
    type: 'direct',
    isEncrypted: true,
    courseCode: 'CS-301',
    unreadCount: 1,
    participants: [
      {
        id: 'user_student_1',
        name: 'Alex Rivera',
        role: 'student',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
        online: true
      },
      {
        id: 'user_teacher_1',
        name: 'Dr. Eleanor Vance',
        role: 'teacher',
        avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
        online: true
      }
    ],
    lastMessage: {
      text: 'Yes, stop by during Period 7 office hours and we can review the balance factor.',
      timestamp: '10:42 AM',
      senderId: 'user_teacher_1'
    }
  },
  {
    id: 'chan_physics_jenkins',
    name: 'Dr. Sarah Jenkins (AP Physics)',
    type: 'direct',
    isEncrypted: true,
    courseCode: 'PHYS-302',
    unreadCount: 0,
    participants: [
      {
        id: 'user_student_1',
        name: 'Alex Rivera',
        role: 'student',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
        online: true
      },
      {
        id: 'user_teacher_3',
        name: 'Dr. Sarah Jenkins',
        role: 'teacher',
        avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',
        online: false
      }
    ],
    lastMessage: {
      text: 'Lab 5 corrections have been received and updated in your grade sheet.',
      timestamp: 'Yesterday',
      senderId: 'user_teacher_3'
    }
  },
  {
    id: 'chan_cs_study_group',
    name: 'AP CS A - Class Discussion & Q&A',
    type: 'class_group',
    isEncrypted: true,
    courseCode: 'CS-301',
    unreadCount: 0,
    participants: [
      {
        id: 'user_teacher_1',
        name: 'Dr. Eleanor Vance',
        role: 'teacher',
        avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
        online: true
      },
      {
        id: 'user_student_1',
        name: 'Alex Rivera',
        role: 'student',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
        online: true
      }
    ],
    lastMessage: {
      text: 'Don’t forget the unit test harness requires Java 17 compatibility!',
      timestamp: 'Mar 24',
      senderId: 'user_teacher_1'
    }
  }
];

export const INITIAL_MESSAGES: Record<string, ChatMessage[]> = {
  chan_vance_direct: [
    {
      id: 'm1',
      senderId: 'user_student_1',
      senderName: 'Alex Rivera',
      senderRole: 'student',
      senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
      content: 'Hello Dr. Vance! Thank you for the quick grading on Project 4.',
      timestamp: '10:30 AM',
      isEncrypted: true,
      status: 'read'
    },
    {
      id: 'm2',
      senderId: 'user_student_1',
      senderName: 'Alex Rivera',
      senderRole: 'student',
      senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
      content: 'I had a quick question regarding the balance factor calculation in `AVLTree.java` on line 142. Should we handle the double rotation in the same recursive pass?',
      timestamp: '10:32 AM',
      isEncrypted: true,
      status: 'read',
      contextTag: {
        type: 'assignment',
        title: 'Project 4: Recursive Binary Tree Search',
        id: 'asg_cs_1'
      }
    },
    {
      id: 'm3',
      senderId: 'user_teacher_1',
      senderName: 'Dr. Eleanor Vance',
      senderRole: 'teacher',
      senderAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
      content: 'Great inquiry, Alex! You can either rotate right-then-left or perform the single helper. Your approach in the submission was mathematically sound.',
      timestamp: '10:38 AM',
      isEncrypted: true,
      status: 'read'
    },
    {
      id: 'm4',
      senderId: 'user_teacher_1',
      senderName: 'Dr. Eleanor Vance',
      senderRole: 'teacher',
      senderAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
      content: 'Yes, stop by during Period 7 office hours and we can review the balance factor visualization together on the lab screen.',
      timestamp: '10:42 AM',
      isEncrypted: true,
      status: 'delivered'
    }
  ],
  chan_physics_jenkins: [
    {
      id: 'pm1',
      senderId: 'user_student_1',
      senderName: 'Alex Rivera',
      senderRole: 'student',
      senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
      content: 'Dr. Jenkins, I have submitted the revised rotational inertia lab data with the photogate sensor timestamps.',
      timestamp: 'Yesterday',
      isEncrypted: true,
      status: 'read',
      attachment: {
        name: 'Rotational_Inertia_Lab5_Data.pdf',
        type: 'pdf',
        size: '1.4 MB'
      }
    },
    {
      id: 'pm2',
      senderId: 'user_teacher_3',
      senderName: 'Dr. Sarah Jenkins',
      senderRole: 'teacher',
      senderAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',
      content: 'Lab 5 corrections have been received and updated in your grade sheet. Keep up the thorough experimental work!',
      timestamp: 'Yesterday',
      isEncrypted: true,
      status: 'read'
    }
  ],
  chan_cs_study_group: [
    {
      id: 'cg1',
      senderId: 'user_teacher_1',
      senderName: 'Dr. Eleanor Vance',
      senderRole: 'teacher',
      senderAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
      content: 'Welcome everyone! Use this encrypted channel for homework hints and algorithm questions.',
      timestamp: 'Mar 20',
      isEncrypted: true,
      status: 'read'
    },
    {
      id: 'cg2',
      senderId: 'user_teacher_1',
      senderName: 'Dr. Eleanor Vance',
      senderRole: 'teacher',
      senderAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
      content: 'Don’t forget the unit test harness requires Java 17 compatibility for the tree traversal benchmarks!',
      timestamp: 'Mar 24',
      isEncrypted: true,
      status: 'read'
    }
  ]
};

export const WEEKLY_SCHEDULE: SchedulePeriod[] = [
  { id: 's1', period: 'Period 1', time: '08:00 - 08:50', courseCode: 'CS-301', courseName: 'AP Computer Science A', room: 'Lab Tech-402', teacher: 'Dr. Vance', color: '#5F6F52', day: 'Mon' },
  { id: 's2', period: 'Period 2', time: '09:00 - 09:50', courseCode: 'MATH-401', courseName: 'AP Calculus BC', room: 'Hall B-210', teacher: 'Prof. Chen', color: '#A9B388', day: 'Mon' },
  { id: 's3', period: 'Period 3', time: '10:05 - 10:55', courseCode: 'PHYS-302', courseName: 'AP Physics C', room: 'Sci Wing-108', teacher: 'Dr. Jenkins', color: '#43423E', day: 'Mon' },
  { id: 's4', period: 'Period 4', time: '11:05 - 11:55', courseCode: 'ENG-305', courseName: 'AP English Lit', room: 'Hum-304', teacher: 'Ms. Oswald', color: '#D67D5B', day: 'Mon' },
  { id: 's5', period: 'Period 5', time: '12:45 - 01:35', courseCode: 'HIST-204', courseName: 'AP US History', room: 'Soc-112', teacher: 'Mr. Miller', color: '#C28E58', day: 'Mon' },
  { id: 's6', period: 'Period 6', time: '01:45 - 02:35', courseCode: 'LANG-301', courseName: 'Spanish III Honors', room: 'Lang-208', teacher: 'Sra. Alvarez', color: '#8C887D', day: 'Mon' }
];
