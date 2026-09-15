import React, { useState, useEffect } from 'react';
import { 
  Calendar, 
  CheckCircle2, 
  PlusCircle, 
  Clock, 
  Archive, 
  ArrowRight, 
  ChevronRight, 
  CalendarDays, 
  Layers,
  Sparkles,
  Lock
} from 'lucide-react';
import { AcademicYearResponse, AcademicTermType, AcademicTermResponse } from '../types/ilmiya';
import { academicYearService } from '../services/academicYearService';
import { useAuth } from '../context/AuthContext';

interface AcademicYearsViewProps {
  currentTenantId: string;
  onNotification: (title: string, message: string, category: 'announcement' | 'emergency') => void;
}

const TERM_TYPES: { type: AcademicTermType; label: string }[] = [
  { type: 'SEMESTER_1', label: 'Semester 1 (Ganjil / Fall)' },
  { type: 'SEMESTER_2', label: 'Semester 2 (Genap / Spring)' },
  { type: 'TRIMESTER_1', label: 'Trimester 1' },
  { type: 'TRIMESTER_2', label: 'Trimester 2' },
  { type: 'TRIMESTER_3', label: 'Trimester 3' },
  { type: 'QUARTER_1', label: 'Quarter 1' },
  { type: 'QUARTER_2', label: 'Quarter 2' },
  { type: 'QUARTER_3', label: 'Quarter 3' },
  { type: 'QUARTER_4', label: 'Quarter 4' }
];

export const AcademicYearsView: React.FC<AcademicYearsViewProps> = ({
  currentTenantId,
  onNotification
}) => {
  const { hasPermission } = useAuth();
  const canWriteAcademic = hasPermission('academic:year:write');

  const [academicYears, setAcademicYears] = useState<AcademicYearResponse[]>([]);
  const [activeYear, setActiveYear] = useState<AcademicYearResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Modals
  const [showCreateYearModal, setShowCreateYearModal] = useState(false);
  const [showAddTermModal, setShowAddTermModal] = useState(false);
  const [selectedYearForTerm, setSelectedYearForTerm] = useState<string | null>(null);

  // Form states
  const [newYearName, setNewYearName] = useState('');
  const [newYearStart, setNewYearStart] = useState('');
  const [newYearEnd, setNewYearEnd] = useState('');

  const [termName, setTermName] = useState('');
  const [termType, setTermType] = useState<AcademicTermType>('SEMESTER_1');
  const [termDisplayName, setTermDisplayName] = useState('');
  const [termStart, setTermStart] = useState('');
  const [termEnd, setTermEnd] = useState('');

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [list, active] = await Promise.all([
        academicYearService.listAcademicYears(),
        academicYearService.getActiveAcademicYear()
      ]);
      setAcademicYears(list);
      setActiveYear(active);
    } catch (err: any) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [currentTenantId]);

  const handleCreateYear = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const created = await academicYearService.createAcademicYear({
        name: newYearName,
        startDate: newYearStart,
        endDate: newYearEnd
      });
      setShowCreateYearModal(false);
      setNewYearName('');
      setNewYearStart('');
      setNewYearEnd('');
      await loadData();
      onNotification('Academic Year Created', `New academic year ${created.name} scheduled.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error creating academic year');
    }
  };

  const handleActivateYear = async (yearId: string, name: string) => {
    if (!confirm(`Are you sure you want to activate "${name}"? Any other active academic year will be archived.`)) {
      return;
    }
    try {
      await academicYearService.activateYear(yearId);
      await loadData();
      onNotification('Academic Year Activated', `${name} is now the primary active academic calendar.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error activating academic year');
    }
  };

  const handleOpenAddTerm = (yearId: string) => {
    setSelectedYearForTerm(yearId);
    setTermName('Semester 1 (Ganjil)');
    setTermType('SEMESTER_1');
    setTermDisplayName('Semester Ganjil');
    setTermStart('');
    setTermEnd('');
    setShowAddTermModal(true);
  };

  const handleAddTermSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedYearForTerm) return;
    try {
      const newTerm = await academicYearService.addTerm(selectedYearForTerm, {
        name: termName,
        type: termType,
        displayName: termDisplayName,
        startDate: termStart,
        endDate: termEnd
      });
      setShowAddTermModal(false);
      await loadData();
      onNotification('Term Added', `${newTerm.displayName} added to academic schedule.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error adding term');
    }
  };

  const handleActivateTerm = async (yearId: string, termId: string, termName: string) => {
    try {
      await academicYearService.activateTerm(yearId, termId);
      await loadData();
      onNotification('Term Activated', `${termName} marked as active teaching term.`, 'announcement');
    } catch (err: any) {
      alert(err.message || 'Error activating term');
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-12 text-sm text-[#6B6E68]">
        <Calendar className="w-5 h-5 animate-pulse text-[#5F6F52] mr-2" />
        Loading academic calendar and terms...
      </div>
    );
  }

  return (
    <div className="space-y-6">
      
      {/* View Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-serif font-bold text-[#2C2E2A]">Academic Years & Terms</h1>
            <span className="text-xs uppercase tracking-wider font-semibold px-2.5 py-0.5 rounded-full bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
              Phase 1 Academic
            </span>
          </div>
          <p className="text-xs text-[#6B6E68] mt-1">
            Configure institutional academic years, term boundaries (semesters/quarters), and rollover states.
          </p>
        </div>

        <button
          onClick={() => setShowCreateYearModal(true)}
          disabled={!canWriteAcademic}
          title={!canWriteAcademic ? "Requires permission: academic:year:write" : "Create new academic calendar year"}
          className={`flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold transition-colors shadow-sm ${
            canWriteAcademic
              ? 'bg-[#5F6F52] text-white hover:bg-[#4E5C43] cursor-pointer'
              : 'bg-gray-200 text-gray-500 opacity-60 cursor-not-allowed'
          }`}
        >
          {canWriteAcademic ? <PlusCircle className="w-4 h-4" /> : <Lock className="w-4 h-4" />}
          <span>New Academic Year</span>
        </button>
      </div>

      {/* Active Academic Year Hero Card */}
      {activeYear && (
        <div className="bg-white rounded-[24px] border-2 border-[#5F6F52]/30 p-6 shadow-sm relative overflow-hidden">
          <div className="absolute top-0 right-0 w-32 h-32 bg-[#FEFAE0] rounded-full blur-2xl -mr-10 -mt-10 pointer-events-none" />
          
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-4 border-b border-[#E9E4DB]">
            <div className="flex items-center gap-3">
              <div className="p-3 rounded-2xl bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]">
                <Sparkles className="w-6 h-6" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <span className="text-[10px] font-bold uppercase tracking-widest px-2 py-0.5 rounded bg-emerald-100 text-emerald-800">
                    Currently Active Calendar
                  </span>
                  <span className="text-xs text-[#8C887D] font-mono">ID: {activeYear.id}</span>
                </div>
                <h2 className="text-xl font-serif font-bold text-[#2C2E2A] mt-0.5">{activeYear.name}</h2>
              </div>
            </div>

            <div className="flex items-center gap-3 text-xs">
              <div className="px-3 py-1.5 rounded-xl bg-[#FAF9F6] border border-[#E9E4DB] text-[#6B6E68]">
                <span className="font-semibold text-[#2C2E2A]">Duration:</span> {activeYear.startDate} to {activeYear.endDate}
              </div>
              <button
                onClick={() => handleOpenAddTerm(activeYear.id)}
                disabled={!canWriteAcademic}
                title={!canWriteAcademic ? "Requires permission: academic:year:write" : "Add academic term to calendar"}
                className={`flex items-center gap-1 px-3 py-1.5 rounded-xl font-semibold transition-colors ${
                  canWriteAcademic
                    ? 'bg-[#5F6F52] text-white hover:bg-[#4E5C43] cursor-pointer'
                    : 'bg-gray-200 text-gray-500 opacity-60 cursor-not-allowed'
                }`}
              >
                {canWriteAcademic ? <PlusCircle className="w-3.5 h-3.5" /> : <Lock className="w-3.5 h-3.5" />}
                <span>Add Term</span>
              </button>
            </div>
          </div>

          {/* Active Terms Breakdown */}
          <div className="pt-4">
            <h4 className="text-xs font-semibold text-[#2C2E2A] mb-3 flex items-center gap-1.5">
              <Layers className="w-3.5 h-3.5 text-[#5F6F52]" />
              Academic Terms & Semesters
            </h4>

            {activeYear.terms.length === 0 ? (
              <p className="text-xs text-[#8C887D] italic">No terms configured yet. Click "Add Term" above.</p>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                {activeYear.terms.map((term: AcademicTermResponse) => {
                  const isTermActive = term.status === 'ACTIVE';
                  return (
                    <div
                      key={term.id}
                      className={`p-4 rounded-2xl border transition-all ${
                        isTermActive
                          ? 'border-[#5F6F52] bg-[#FAF9F6] shadow-xs'
                          : 'border-[#E9E4DB] bg-white'
                      }`}
                    >
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-xs font-bold font-serif text-[#2C2E2A]">{term.name}</span>
                        <span
                          className={`text-[9px] font-bold uppercase px-2 py-0.5 rounded-full ${
                            isTermActive
                              ? 'bg-[#5F6F52] text-white'
                              : term.status === 'CONCLUDED'
                              ? 'bg-gray-100 text-gray-700'
                              : 'bg-amber-100 text-amber-800'
                          }`}
                        >
                          {term.status}
                        </span>
                      </div>

                      <div className="text-[11px] text-[#6B6E68] space-y-1 mb-3">
                        <div><span className="text-[#8C887D]">Display:</span> {term.displayName}</div>
                        <div><span className="text-[#8C887D]">Dates:</span> {term.startDate} → {term.endDate}</div>
                        <div><span className="text-[#8C887D]">Type:</span> {term.type}</div>
                      </div>

                      {!isTermActive && term.status !== 'CONCLUDED' && (
                        <button
                          onClick={() => handleActivateTerm(activeYear.id, term.id, term.name)}
                          disabled={!canWriteAcademic}
                          title={!canWriteAcademic ? "Requires permission: academic:year:write" : "Activate this academic term"}
                          className={`w-full py-1 text-[11px] font-semibold rounded-lg border transition-colors flex items-center justify-center gap-1 ${
                            canWriteAcademic
                              ? 'text-[#5F6F52] hover:bg-[#FEFAE0] border-[#D9D1C5] cursor-pointer'
                              : 'text-gray-400 bg-gray-50 border-gray-200 cursor-not-allowed'
                          }`}
                        >
                          {!canWriteAcademic && <Lock className="w-3 h-3" />}
                          <span>Activate Term</span>
                        </button>
                      )}
                    </div>
                  );
                })}
              </div>
            )}
          </div>

        </div>
      )}

      {/* All Academic Years Catalog */}
      <div className="bg-white rounded-[24px] border border-[#D9D1C5] p-6 shadow-sm">
        <h3 className="text-base font-serif font-bold text-[#2C2E2A] mb-4 flex items-center gap-2">
          <CalendarDays className="w-4 h-4 text-[#5F6F52]" />
          All Academic Years
        </h3>

        <div className="space-y-4">
          {academicYears.map((ay) => {
            const isActive = ay.status === 'ACTIVE';
            return (
              <div
                key={ay.id}
                className={`p-4 rounded-2xl border transition-all ${
                  isActive
                    ? 'border-[#5F6F52] bg-[#FAF9F6]'
                    : 'border-[#E9E4DB] hover:border-[#D9D1C5]'
                }`}
              >
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className="text-sm font-serif font-bold text-[#2C2E2A]">{ay.name}</h4>
                      <span
                        className={`text-[10px] font-bold uppercase px-2 py-0.5 rounded ${
                          isActive
                            ? 'bg-emerald-100 text-emerald-800'
                            : ay.status === 'ARCHIVED'
                            ? 'bg-gray-100 text-gray-700'
                            : 'bg-blue-100 text-blue-800'
                        }`}
                      >
                        {ay.status}
                      </span>
                    </div>
                    <p className="text-xs text-[#6B6E68] mt-0.5">
                      Period: {ay.startDate} to {ay.endDate} • {ay.terms.length} Terms
                    </p>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => handleOpenAddTerm(ay.id)}
                      disabled={!canWriteAcademic}
                      title={!canWriteAcademic ? "Requires permission: academic:year:write" : "Add term"}
                      className={`px-2.5 py-1 text-xs rounded-xl border font-medium flex items-center gap-1 ${
                        canWriteAcademic
                          ? 'border-[#D9D1C5] text-[#2C2E2A] hover:bg-[#FAF9F6] cursor-pointer'
                          : 'border-gray-200 text-gray-400 bg-gray-50 cursor-not-allowed'
                      }`}
                    >
                      {canWriteAcademic ? '+ Add Term' : <><Lock className="w-3 h-3" /> + Add Term</>}
                    </button>
                    {!isActive && (
                      <button
                        onClick={() => handleActivateYear(ay.id, ay.name)}
                        disabled={!canWriteAcademic}
                        title={!canWriteAcademic ? "Requires permission: academic:year:write" : "Activate this academic year"}
                        className={`px-3 py-1 text-xs rounded-xl font-semibold transition-colors flex items-center gap-1 ${
                          canWriteAcademic
                            ? 'bg-[#5F6F52] text-white hover:bg-[#4E5C43] cursor-pointer'
                            : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                        }`}
                      >
                        {!canWriteAcademic && <Lock className="w-3 h-3" />}
                        <span>Activate</span>
                      </button>
                    )}
                  </div>
                </div>

                {/* Terms preview chips */}
                {ay.terms.length > 0 && (
                  <div className="mt-3 pt-3 border-t border-[#E9E4DB]/60 flex flex-wrap gap-2">
                    {ay.terms.map((t) => (
                      <span
                        key={t.id}
                        className="text-[11px] px-2.5 py-1 rounded-lg bg-white border border-[#E9E4DB] text-[#2C2E2A] flex items-center gap-1.5"
                      >
                        <span className={`w-1.5 h-1.5 rounded-full ${t.status === 'ACTIVE' ? 'bg-emerald-500' : 'bg-gray-400'}`} />
                        {t.displayName} ({t.startDate} - {t.endDate})
                      </span>
                    ))}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Create Academic Year Modal */}
      {showCreateYearModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-md w-full p-6 shadow-2xl">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Create Academic Year</h3>
              <button onClick={() => setShowCreateYearModal(false)} className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer">✕</button>
            </div>

            <form onSubmit={handleCreateYear} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Academic Year Name</label>
                <input
                  type="text"
                  value={newYearName}
                  onChange={(e) => setNewYearName(e.target.value)}
                  placeholder="e.g. Academic Year 2027/2028"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Start Date</label>
                  <input
                    type="date"
                    value={newYearStart}
                    onChange={(e) => setNewYearStart(e.target.value)}
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                    required
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">End Date</label>
                  <input
                    type="date"
                    value={newYearEnd}
                    onChange={(e) => setNewYearEnd(e.target.value)}
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                    required
                  />
                </div>
              </div>

              <div className="pt-4 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowCreateYearModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43]"
                >
                  Save Academic Year
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add Academic Term Modal */}
      {showAddTermModal && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-[24px] border border-[#D9D1C5] max-w-md w-full p-6 shadow-2xl">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-serif font-bold text-[#2C2E2A]">Add Academic Term / Semester</h3>
              <button onClick={() => setShowAddTermModal(false)} className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer">✕</button>
            </div>

            <form onSubmit={handleAddTermSubmit} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Term Name</label>
                <input
                  type="text"
                  value={termName}
                  onChange={(e) => setTermName(e.target.value)}
                  placeholder="e.g. Semester 1 (Ganjil)"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Term Type</label>
                <select
                  value={termType}
                  onChange={(e) => setTermType(e.target.value as any)}
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                >
                  {TERM_TYPES.map(tt => (
                    <option key={tt.type} value={tt.type}>{tt.label}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Display Name</label>
                <input
                  type="text"
                  value={termDisplayName}
                  onChange={(e) => setTermDisplayName(e.target.value)}
                  placeholder="e.g. Semester Ganjil 2026/2027"
                  className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">Start Date</label>
                  <input
                    type="date"
                    value={termStart}
                    onChange={(e) => setTermStart(e.target.value)}
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                    required
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-[#2C2E2A] mb-1">End Date</label>
                  <input
                    type="date"
                    value={termEnd}
                    onChange={(e) => setTermEnd(e.target.value)}
                    className="w-full px-3 py-2 text-xs rounded-xl border border-[#D9D1C5] bg-[#FAF9F6]"
                    required
                  />
                </div>
              </div>

              <div className="pt-4 flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setShowAddTermModal(false)}
                  className="px-4 py-2 text-xs rounded-xl border border-[#D9D1C5] text-[#6B6E68]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-xs rounded-xl bg-[#5F6F52] text-white font-semibold hover:bg-[#4E5C43]"
                >
                  Add Term
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};
