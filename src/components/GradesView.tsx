import React, { useState } from 'react';
import { 
  Award, 
  TrendingUp, 
  Calculator, 
  FileText, 
  Search, 
  CheckCircle2, 
  Clock, 
  AlertCircle, 
  MessageSquare, 
  Sliders, 
  Printer, 
  Download, 
  ChevronRight, 
  HelpCircle,
  Plus,
  ArrowUpDown,
  BookOpen,
  Sparkles,
  Save
} from 'lucide-react';
import confetti from 'canvas-confetti';
import { Course, Assignment, UserRole, UserProfile } from '../types';

interface GradesViewProps {
  courses: Course[];
  user: UserProfile;
  currentRole: UserRole;
  onInquireAssignment: (course: Course, assignment: Assignment) => void;
  onUpdateCourseGrade: (courseId: string, assignmentId: string, newScore: number) => void;
}

export const GradesView: React.FC<GradesViewProps> = ({
  courses,
  user,
  currentRole,
  onInquireAssignment,
  onUpdateCourseGrade,
}) => {
  const [selectedCourse, setSelectedCourse] = useState<Course>(courses[0]);
  const [activeSubTab, setActiveSubTab] = useState<'roster' | 'calculator' | 'transcript' | 'teacher_gradebook'>('roster');
  const [semester, setSemester] = useState('Spring 2026');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('All');
  
  // What-If Calculator Simulation State
  const [simulatedAssignments, setSimulatedAssignments] = useState<{ id: string; name: string; courseId: string; weight: number; simulatedScore: number }[]>([
    { id: 'sim_1', name: 'AP CS Term Final Project', courseId: 'course_ap_cs', weight: 25, simulatedScore: 96 },
    { id: 'sim_2', name: 'AP Physics Final Exam', courseId: 'course_ap_physics', weight: 30, simulatedScore: 92 },
    { id: 'sim_3', name: 'AP Calc BC AP Mock Test', courseId: 'course_ap_calc', weight: 25, simulatedScore: 95 }
  ]);

  // Calculate Cumulative Stats
  const calculateGPA = (courseList: Course[]) => {
    let totalUnweightedPoints = 0;
    let totalWeightedPoints = 0;
    let totalCredits = 0;

    const gradePointsMap: Record<string, { unweighted: number; weighted: number }> = {
      'A+': { unweighted: 4.0, weighted: 5.0 },
      'A':  { unweighted: 4.0, weighted: 5.0 },
      'A-': { unweighted: 3.7, weighted: 4.7 },
      'B+': { unweighted: 3.3, weighted: 4.3 },
      'B':  { unweighted: 3.0, weighted: 4.0 },
      'B-': { unweighted: 2.7, weighted: 3.7 },
      'C+': { unweighted: 2.3, weighted: 3.3 },
      'C':  { unweighted: 2.0, weighted: 3.0 },
      'F':  { unweighted: 0.0, weighted: 0.0 }
    };

    courseList.forEach(c => {
      const pts = gradePointsMap[c.letterGrade] || { unweighted: 3.0, weighted: 4.0 };
      totalUnweightedPoints += pts.unweighted * c.credits;
      totalWeightedPoints += pts.weighted * c.credits;
      totalCredits += c.credits;
    });

    return {
      unweighted: totalCredits ? (totalUnweightedPoints / totalCredits).toFixed(2) : '3.88',
      weighted: totalCredits ? (totalWeightedPoints / totalCredits).toFixed(2) : '4.12'
    };
  };

  const gpa = calculateGPA(courses);

  const handleSimulateChange = (id: string, newScore: number) => {
    setSimulatedAssignments(prev =>
      prev.map(item => item.id === id ? { ...item, simulatedScore: newScore } : item)
    );
  };

  const triggerCelebration = () => {
    confetti({
      particleCount: 80,
      spread: 70,
      origin: { y: 0.6 }
    });
  };

  return (
    <div className="space-y-6">
      
      {/* Top GPA Header & Sub-navigation */}
      <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-6 shadow-sm">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-6 border-b border-[#E9E4DB]">
          <div>
            <div className="flex items-center gap-2">
              <span className="px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
                Official Records
              </span>
              <span className="text-xs text-[#8C887D]">Spring 2026 Academic Term</span>
            </div>
            <h1 className="text-2xl font-serif font-bold text-[#2C2E2A] mt-1.5">Grade Tracking & Academic Performance</h1>
            <p className="text-xs text-[#6B6E68] mt-0.5">Real-time GPA computation, weighted category breakdowns, and feedback rubrics</p>
          </div>

          <div className="flex items-center gap-4 bg-[#FAF9F6] p-3.5 rounded-[20px] border border-[#D9D1C5]">
            <div className="text-center px-3.5 border-r border-[#E9E4DB]">
              <span className="text-[10px] font-bold text-[#8C887D] uppercase tracking-wider">Unweighted GPA</span>
              <p className="text-2xl font-serif font-bold text-[#2C2E2A]">{gpa.unweighted}</p>
              <span className="text-[10px] text-[#8C887D]">4.0 Scale</span>
            </div>
            <div className="text-center px-3.5">
              <span className="text-[10px] font-bold text-[#8C887D] uppercase tracking-wider">Weighted GPA</span>
              <p className="text-2xl font-serif font-bold text-[#5F6F52]">{gpa.weighted}</p>
              <span className="text-[10px] text-[#5F6F52] font-bold">Top 4% Rank #14</span>
            </div>
          </div>
        </div>

        {/* Sub-tab Switcher */}
        <div className="flex flex-wrap items-center gap-2 pt-4">
          <button
            onClick={() => setActiveSubTab('roster')}
            className={`px-4 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
              activeSubTab === 'roster'
                ? 'bg-[#5F6F52] text-white shadow-sm'
                : 'bg-[#E9E4DB] text-[#6B6E68] hover:text-[#2C2E2A] hover:bg-[#F2EDE4]'
            }`}
          >
            Course Grades & Rubrics
          </button>
          <button
            onClick={() => setActiveSubTab('calculator')}
            className={`px-4 py-2 rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5 cursor-pointer ${
              activeSubTab === 'calculator'
                ? 'bg-[#5F6F52] text-white shadow-sm'
                : 'bg-[#E9E4DB] text-[#6B6E68] hover:text-[#2C2E2A] hover:bg-[#F2EDE4]'
            }`}
          >
            <Calculator className="w-3.5 h-3.5" />
            <span>GPA What-If Simulator</span>
          </button>
          <button
            onClick={() => setActiveSubTab('transcript')}
            className={`px-4 py-2 rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5 cursor-pointer ${
              activeSubTab === 'transcript'
                ? 'bg-[#5F6F52] text-white shadow-sm'
                : 'bg-[#E9E4DB] text-[#6B6E68] hover:text-[#2C2E2A] hover:bg-[#F2EDE4]'
            }`}
          >
            <FileText className="w-3.5 h-3.5" />
            <span>Report Card & Transcript</span>
          </button>
          {currentRole === 'teacher' && (
            <button
              onClick={() => setActiveSubTab('teacher_gradebook')}
              className={`px-4 py-2 rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5 cursor-pointer ${
                activeSubTab === 'teacher_gradebook'
                  ? 'bg-[#5F6F52] text-white shadow-sm'
                  : 'bg-[#E9E4DB] text-[#5F6F52] hover:text-[#2C2E2A] hover:bg-[#F2EDE4]'
              }`}
            >
              <Award className="w-3.5 h-3.5" />
              <span>Teacher Gradebook Editor</span>
            </button>
          )}
        </div>
      </div>

      {/* Sub-Tab 1: Course Breakdown View */}
      {activeSubTab === 'roster' && (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          
          {/* Left Course Sidebar */}
          <div className="lg:col-span-4 space-y-3">
            <h3 className="text-[11px] font-bold uppercase tracking-widest text-[#8C887D] px-1">Enrolled Courses (6)</h3>
            <div className="space-y-2.5">
              {courses.map((course) => {
                const isSelected = selectedCourse.id === course.id;
                return (
                  <div
                    key={course.id}
                    onClick={() => setSelectedCourse(course)}
                    className={`p-3.5 rounded-2xl border transition-all cursor-pointer ${
                      isSelected
                        ? 'bg-[#FEFAE0] border-[#5F6F52]/50 shadow-sm ring-1 ring-[#5F6F52]/30'
                        : 'bg-white border-[#E9E4DB] hover:bg-[#FAF9F6] hover:border-[#D9D1C5]'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div
                          className="w-9 h-9 rounded-xl flex items-center justify-center font-bold text-xs text-white shadow-sm"
                          style={{ backgroundColor: course.color }}
                        >
                          {course.code.split('-')[0]}
                        </div>
                        <div>
                          <p className="text-xs font-bold text-[#2C2E2A] line-clamp-1">{course.name}</p>
                          <p className="text-[11px] text-[#8C887D]">{course.teacherName}</p>
                        </div>
                      </div>

                      <div className="text-right">
                        <span className="text-base font-serif font-bold text-[#2C2E2A]">{course.letterGrade}</span>
                        <p className="text-[11px] text-[#5F6F52] font-mono font-medium">{course.currentPercentage}%</p>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Right Detailed Assignment & Rubric Panel */}
          <div className="lg:col-span-8 space-y-6">
            
            {/* Course Header Banner */}
            <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-6 shadow-sm">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-2">
                    <span
                      className="px-2.5 py-0.5 rounded-md text-xs font-bold text-white shadow-sm"
                      style={{ backgroundColor: selectedCourse.color }}
                    >
                      {selectedCourse.code}
                    </span>
                    <span className="text-xs text-[#8C887D]">{selectedCourse.period}</span>
                  </div>
                  <h2 className="text-xl font-serif font-bold text-[#2C2E2A] mt-1.5">{selectedCourse.name}</h2>
                  <p className="text-xs text-[#6B6E68] mt-0.5">
                    Instructor: <span className="font-bold text-[#2C2E2A]">{selectedCourse.teacherName}</span> • Room: {selectedCourse.room} • Office Hours: {selectedCourse.officeHours}
                  </p>
                </div>

                <div className="flex items-center gap-3">
                  <div className="text-right">
                    <p className="text-[10px] uppercase font-bold text-[#8C887D] tracking-wider">Current Grade</p>
                    <span
                      className="text-3xl font-serif font-bold px-3.5 py-1 rounded-2xl inline-block border"
                      style={{
                        backgroundColor: `${selectedCourse.color}15`,
                        borderColor: `${selectedCourse.color}35`,
                        color: selectedCourse.color
                      }}
                    >
                      {selectedCourse.letterGrade}
                    </span>
                  </div>
                </div>
              </div>

              {/* Category Weights Breakdown Bar */}
              <div className="mt-5 pt-4 border-t border-[#E9E4DB]">
                <p className="text-xs font-bold uppercase tracking-wider text-[#8C887D] mb-2.5">Weighted Category Breakdown</p>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
                  {selectedCourse.categoryWeights.map((cat, idx) => (
                    <div key={idx} className="bg-[#FAF9F6] p-3 rounded-2xl border border-[#E9E4DB] text-center">
                      <p className="text-[11px] text-[#8C887D] truncate font-medium">{cat.category}</p>
                      <p className="text-sm font-serif font-bold text-[#2C2E2A] mt-0.5">{cat.currentAvg}%</p>
                      <p className="text-[10px] text-[#5F6F52] font-semibold">Weight: {cat.weight}%</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Assignments List */}
            <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-6 space-y-4 shadow-sm">
              <div className="flex items-center justify-between">
                <h3 className="text-sm font-serif font-bold text-[#2C2E2A]">Graded Assignments & Tasks</h3>
                <span className="text-xs text-[#8C887D] font-medium">{selectedCourse.assignments.length} total entries</span>
              </div>

              <div className="space-y-3.5">
                {selectedCourse.assignments.map((asg) => {
                  const percentage = ((asg.score / asg.maxScore) * 100).toFixed(0);
                  const isGraded = asg.status === 'graded';

                  return (
                    <div
                      key={asg.id}
                      className="bg-[#FAF9F6] border border-[#E9E4DB] rounded-2xl p-4.5 space-y-3 hover:border-[#D9D1C5] transition-all"
                    >
                      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider bg-[#E9E4DB] text-[#2C2E2A] border border-[#D9D1C5]">
                              {asg.category}
                            </span>
                            <span className="text-xs text-[#8C887D]">Due: {asg.dueDate}</span>
                            {asg.submittedDate && (
                              <span className="text-[10px] text-[#5F6F52] font-semibold">Submitted on {asg.submittedDate}</span>
                            )}
                          </div>
                          <h4 className="text-sm font-bold text-[#2C2E2A] mt-1">{asg.title}</h4>
                        </div>

                        <div className="flex items-center gap-3">
                          {isGraded ? (
                            <div className="text-right">
                              <span className="text-base font-serif font-bold text-[#2C2E2A] font-mono">{asg.score} / {asg.maxScore}</span>
                              <span className="ml-2 text-xs font-bold text-[#5F6F52]">({percentage}%)</span>
                            </div>
                          ) : (
                            <span className="px-2.5 py-1 bg-[#FEFAE0] text-[#D67D5B] border border-[#D9D1C5] rounded-xl text-xs font-bold">
                              Pending Grading
                            </span>
                          )}
                        </div>
                      </div>

                      {/* Rubric Feedback Comments */}
                      {asg.feedback && (
                        <div className="bg-[#FEFAE0]/80 p-3.5 rounded-xl border border-[#E9E4DB] text-xs">
                          <p className="text-[#2C2E2A] font-medium leading-relaxed">
                            <span className="text-[#5F6F52] font-bold">Instructor Feedback: </span>
                            "{asg.feedback}"
                          </p>

                          {asg.rubricScores && asg.rubricScores.length > 0 && (
                            <div className="mt-2.5 pt-2 border-t border-[#E9E4DB] space-y-1.5">
                              <p className="text-[10px] font-bold uppercase tracking-widest text-[#8C887D]">Scoring Rubric Breakdown</p>
                              <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
                                {asg.rubricScores.map((rub, rIdx) => (
                                  <div key={rIdx} className="bg-white p-2.5 rounded-xl border border-[#E9E4DB] text-[11px]">
                                    <span className="text-[#8C887D] block truncate">{rub.criterion}</span>
                                    <span className="font-bold text-[#5F6F52]">{rub.score} / {rub.max} pts</span>
                                  </div>
                                ))}
                              </div>
                            </div>
                          )}
                        </div>
                      )}

                      {/* Action to Inquire with Teacher directly */}
                      <div className="flex items-center justify-end gap-2 pt-1">
                        <button
                          onClick={() => onInquireAssignment(selectedCourse, asg)}
                          className="flex items-center gap-1.5 text-xs text-[#5F6F52] hover:text-[#2C2E2A] font-bold px-3 py-1.5 rounded-xl hover:bg-[#E9E4DB] transition-colors cursor-pointer"
                        >
                          <MessageSquare className="w-3.5 h-3.5" />
                          <span>Inquire with {selectedCourse.teacherName.split(' ')[0]}</span>
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

          </div>

        </div>
      )}

      {/* Sub-Tab 2: What-If GPA Calculator */}
      {activeSubTab === 'calculator' && (
        <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-6 space-y-6 shadow-sm">
          <div className="flex items-center justify-between pb-4 border-b border-[#E9E4DB]">
            <div>
              <h2 className="text-xl font-serif font-bold text-[#2C2E2A] flex items-center gap-2">
                <Calculator className="w-5 h-5 text-[#5F6F52]" />
                GPA What-If Scenario Prediction Studio
              </h2>
              <p className="text-xs text-[#6B6E68] mt-0.5">
                Simulate upcoming midterm, final exam, and project scores to calculate their exact impact on your final course letter grade and cumulative GPA.
              </p>
            </div>
            <button
              onClick={triggerCelebration}
              className="px-4 py-2 rounded-xl bg-[#5F6F52] hover:bg-[#4E5C43] text-white text-xs font-bold flex items-center gap-1.5 shadow-sm transition-all cursor-pointer"
            >
              <Sparkles className="w-3.5 h-3.5 text-[#FEFAE0]" />
              <span>Celebrate Target!</span>
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {simulatedAssignments.map((sim) => (
              <div key={sim.id} className="bg-[#FAF9F6] border border-[#E9E4DB] rounded-2xl p-4.5 space-y-3.5">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-[#5F6F52]">Weight: {sim.weight}%</span>
                  <span className="text-sm font-serif font-bold text-[#2C2E2A] font-mono">{sim.simulatedScore}%</span>
                </div>
                <h4 className="text-sm font-bold text-[#2C2E2A]">{sim.name}</h4>
                
                {/* Score Slider */}
                <div>
                  <input
                    type="range"
                    min="50"
                    max="100"
                    value={sim.simulatedScore}
                    onChange={(e) => handleSimulateChange(sim.id, parseInt(e.target.value))}
                    className="w-full h-2 bg-[#E9E4DB] rounded-lg appearance-none cursor-pointer accent-[#5F6F52]"
                  />
                  <div className="flex justify-between text-[10px] text-[#8C887D] mt-1 font-medium">
                    <span>50%</span>
                    <span>75%</span>
                    <span>100%</span>
                  </div>
                </div>

                <p className="text-[11px] text-[#5F6F52] font-semibold">
                  {sim.simulatedScore >= 90 ? 'Maintains Grade A (4.0)' : 'Impact: Drops to B+ (3.3)'}
                </p>
              </div>
            ))}
          </div>

          <div className="bg-[#FEFAE0] border border-[#D9D1C5] rounded-[24px] p-6 flex flex-col sm:flex-row items-center justify-between gap-4 shadow-sm">
            <div>
              <h3 className="text-sm font-serif font-bold text-[#2C2E2A]">Target Cumulative GPA Outcome</h3>
              <p className="text-xs text-[#6B6E68] mt-0.5">With these simulated scores, your semester GPA will adjust to:</p>
            </div>
            <div className="flex items-center gap-6">
              <div className="text-center">
                <span className="text-[10px] text-[#8C887D] uppercase font-bold tracking-wider">Simulated Unweighted</span>
                <p className="text-3xl font-serif font-bold text-[#5F6F52]">3.92</p>
              </div>
              <div className="text-center">
                <span className="text-[10px] text-[#8C887D] uppercase font-bold tracking-wider">Simulated Weighted</span>
                <p className="text-3xl font-serif font-bold text-[#D67D5B]">4.18</p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Sub-Tab 3: Official Transcript & Report Card */}
      {activeSubTab === 'transcript' && (
        <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-6 space-y-6 shadow-sm">
          <div className="flex items-center justify-between pb-4 border-b border-[#E9E4DB]">
            <div>
              <h2 className="text-xl font-serif font-bold text-[#2C2E2A] flex items-center gap-2">
                <FileText className="w-5 h-5 text-[#5F6F52]" />
                Official Academic Transcript & Q3 Report Card
              </h2>
              <p className="text-xs text-[#6B6E68] mt-0.5">Lincoln High School • Office of the Registrar & Academic Advising</p>
            </div>
            <button
              onClick={() => window.print()}
              className="px-4 py-2 rounded-xl bg-[#5F6F52] hover:bg-[#4E5C43] text-white text-xs font-bold flex items-center gap-2 cursor-pointer transition-colors shadow-sm"
            >
              <Printer className="w-4 h-4 text-[#FEFAE0]" />
              <span>Print / Save PDF</span>
            </button>
          </div>

          {/* Printable Document Box */}
          <div className="bg-[#FAF9F6] text-[#2C2E2A] rounded-[24px] p-8 shadow-md border border-[#D9D1C5] space-y-6 max-w-4xl mx-auto font-sans">
            <div className="flex items-start justify-between border-b border-[#D9D1C5] pb-4">
              <div>
                <h3 className="text-xl font-serif font-bold tracking-tight text-[#2C2E2A]">LINCOLN HIGH STEM ACADEMY</h3>
                <p className="text-xs text-[#6B6E68]">1200 Innovation Parkway, Silicon Valley, CA 94025</p>
                <p className="text-xs text-[#6B6E68]">Official Student Academic Record • Accredited WASC</p>
              </div>
              <div className="text-right">
                <span className="text-xs font-bold px-3 py-1 bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB] rounded-full">
                  HONOR ROLL • DEAN'S LIST
                </span>
                <p className="text-xs text-[#8C887D] mt-1.5">Date Issued: March 30, 2026</p>
              </div>
            </div>

            {/* Student Info Table */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 text-xs bg-white p-4.5 rounded-2xl border border-[#E9E4DB]">
              <div>
                <span className="text-[#8C887D] font-bold block">STUDENT NAME</span>
                <span className="font-bold text-[#2C2E2A] mt-0.5 block">{user.name}</span>
              </div>
              <div>
                <span className="text-[#8C887D] font-bold block">STUDENT ID</span>
                <span className="font-bold text-[#2C2E2A] mt-0.5 block">{user.schoolId}</span>
              </div>
              <div>
                <span className="text-[#8C887D] font-bold block">GRADE LEVEL</span>
                <span className="font-bold text-[#2C2E2A] mt-0.5 block">{user.gradeLevel || 'Grade 11'}</span>
              </div>
              <div>
                <span className="text-[#8C887D] font-bold block">ACADEMIC TERM</span>
                <span className="font-bold text-[#2C2E2A] mt-0.5 block">Spring 2026 (Q3)</span>
              </div>
            </div>

            {/* Grades Table */}
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="border-b-2 border-[#D9D1C5] bg-[#E9E4DB] text-[#2C2E2A]">
                  <th className="py-2.5 px-3 font-bold">COURSE CODE</th>
                  <th className="py-2.5 px-3 font-bold">COURSE TITLE</th>
                  <th className="py-2.5 px-3 font-bold">INSTRUCTOR</th>
                  <th className="py-2.5 px-3 text-center font-bold">CREDITS</th>
                  <th className="py-2.5 px-3 text-center font-bold">PCT</th>
                  <th className="py-2.5 px-3 text-center font-bold">GRADE</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#E9E4DB]">
                {courses.map((course) => (
                  <tr key={course.id} className="hover:bg-white transition-colors">
                    <td className="py-3 px-3 font-mono font-semibold text-[#2C2E2A]">{course.code}</td>
                    <td className="py-3 px-3 font-semibold text-[#2C2E2A]">{course.name}</td>
                    <td className="py-3 px-3 text-[#6B6E68]">{course.teacherName}</td>
                    <td className="py-3 px-3 text-center text-[#2C2E2A]">{course.credits.toFixed(1)}</td>
                    <td className="py-3 px-3 text-center font-mono text-[#6B6E68]">{course.currentPercentage}%</td>
                    <td className="py-3 px-3 text-center font-serif font-bold text-[#5F6F52] text-sm">{course.letterGrade}</td>
                  </tr>
                ))}
              </tbody>
            </table>

            {/* GPA Summary in Transcript */}
            <div className="flex items-center justify-between pt-4 border-t-2 border-[#D9D1C5] text-xs">
              <div>
                <p className="font-semibold text-[#2C2E2A]">Cumulative Credits Earned: 48.0</p>
                <p className="text-[#8C887D]">Attendance: 98.5% • Conduct: Exemplary</p>
              </div>
              <div className="text-right space-y-0.5">
                <p className="text-[#6B6E68]">Unweighted Cumulative GPA: <strong className="text-[#2C2E2A] font-serif font-bold">{gpa.unweighted}</strong></p>
                <p className="text-[#6B6E68]">Weighted Honors/AP GPA: <strong className="text-[#5F6F52] text-sm font-serif font-bold">{gpa.weighted}</strong></p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Sub-Tab 4: Teacher Gradebook (when teacher role is active) */}
      {activeSubTab === 'teacher_gradebook' && currentRole === 'teacher' && (
        <div className="bg-white border border-[#E9E4DB] rounded-[28px] p-6 space-y-5 shadow-sm">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-[#E9E4DB]">
            <div>
              <h2 className="text-xl font-serif font-bold text-[#2C2E2A]">Teacher Gradebook & Roster Editor</h2>
              <p className="text-xs text-[#6B6E68] mt-0.5">Class: AP Computer Science A • Period 1 • 28 Enrolled Students</p>
            </div>
            <button
              onClick={() => alert('Scores saved and real-time push notifications dispatched to 28 students!')}
              className="px-4 py-2 bg-[#5F6F52] hover:bg-[#4E5C43] text-white text-xs font-bold rounded-xl flex items-center gap-1.5 shadow-sm transition-all cursor-pointer"
            >
              <Save className="w-4 h-4" />
              <span>Publish Grades & Notify</span>
            </button>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="border-b border-[#E9E4DB] bg-[#FAF9F6] text-[#2C2E2A]">
                  <th className="py-3 px-3 font-bold">STUDENT NAME</th>
                  <th className="py-3 px-3 font-bold">STUDENT ID</th>
                  <th className="py-3 px-3 text-center font-bold">PROJECT 4 (100)</th>
                  <th className="py-3 px-3 text-center font-bold">MIDTERM 2 (100)</th>
                  <th className="py-3 px-3 text-center font-bold">OVERALL PCT</th>
                  <th className="py-3 px-3 text-center font-bold">GRADE</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#E9E4DB]">
                <tr className="hover:bg-[#FAF9F6]">
                  <td className="py-3 px-3 font-semibold text-[#2C2E2A]">Alex Rivera (You)</td>
                  <td className="py-3 px-3 text-[#8C887D]">STU-2026-8941</td>
                  <td className="py-3 px-3 text-center">
                    <input
                      type="number"
                      defaultValue="98"
                      className="w-16 bg-white border border-[#D9D1C5] rounded-lg px-2 py-1 text-center text-[#2C2E2A] font-medium"
                    />
                  </td>
                  <td className="py-3 px-3 text-center">
                    <input
                      type="number"
                      defaultValue="94"
                      className="w-16 bg-white border border-[#D9D1C5] rounded-lg px-2 py-1 text-center text-[#2C2E2A] font-medium"
                    />
                  </td>
                  <td className="py-3 px-3 text-center font-bold text-[#5F6F52]">96.4%</td>
                  <td className="py-3 px-3 text-center font-serif font-bold text-[#5F6F52]">A</td>
                </tr>
                <tr className="hover:bg-[#FAF9F6]">
                  <td className="py-3 px-3 font-semibold text-[#2C2E2A]">Jordan Hayes</td>
                  <td className="py-3 px-3 text-[#8C887D]">STU-2026-8942</td>
                  <td className="py-3 px-3 text-center">
                    <input
                      type="number"
                      defaultValue="92"
                      className="w-16 bg-white border border-[#D9D1C5] rounded-lg px-2 py-1 text-center text-[#2C2E2A] font-medium"
                    />
                  </td>
                  <td className="py-3 px-3 text-center">
                    <input
                      type="number"
                      defaultValue="88"
                      className="w-16 bg-white border border-[#D9D1C5] rounded-lg px-2 py-1 text-center text-[#2C2E2A] font-medium"
                    />
                  </td>
                  <td className="py-3 px-3 text-center font-bold text-[#5F6F52]">90.2%</td>
                  <td className="py-3 px-3 text-center font-serif font-bold text-[#5F6F52]">A-</td>
                </tr>
                <tr className="hover:bg-[#FAF9F6]">
                  <td className="py-3 px-3 font-semibold text-[#2C2E2A]">Samantha Lee</td>
                  <td className="py-3 px-3 text-[#8C887D]">STU-2026-8943</td>
                  <td className="py-3 px-3 text-center">
                    <input
                      type="number"
                      defaultValue="100"
                      className="w-16 bg-white border border-[#D9D1C5] rounded-lg px-2 py-1 text-center text-[#2C2E2A] font-medium"
                    />
                  </td>
                  <td className="py-3 px-3 text-center">
                    <input
                      type="number"
                      defaultValue="96"
                      className="w-16 bg-white border border-[#D9D1C5] rounded-lg px-2 py-1 text-center text-[#2C2E2A] font-medium"
                    />
                  </td>
                  <td className="py-3 px-3 text-center font-bold text-[#5F6F52]">98.0%</td>
                  <td className="py-3 px-3 text-center font-serif font-bold text-[#5F6F52]">A+</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      )}

    </div>
  );
};
