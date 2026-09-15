/**
 * Ilmiya School & Academic Year Domain Models & DTOs
 * Matching backend: io.github.edmaputra.ilmiya
 */

export type GradingPreference =
  | 'NUMERIC_0_100'
  | 'LETTER_A_F'
  | 'PERCENTAGE_0_100'
  | 'DESCRIPTIVE_KURIKULUM_MERDEKA';

export type TermLayout = 'SEMESTER' | 'TRIMESTER' | 'QUARTER';

export type SchoolStatus = 'ACTIVE' | 'PROVISIONING' | 'SUSPENDED' | 'ARCHIVED';

export type AcademicYearStatus = 'UPCOMING' | 'ACTIVE' | 'ARCHIVED';

export type AcademicTermType =
  | 'SEMESTER_1'
  | 'SEMESTER_2'
  | 'TRIMESTER_1'
  | 'TRIMESTER_2'
  | 'TRIMESTER_3'
  | 'QUARTER_1'
  | 'QUARTER_2'
  | 'QUARTER_3'
  | 'QUARTER_4';

export type AcademicTermStatus = 'PENDING' | 'ACTIVE' | 'CONCLUDED';

export interface Accreditation {
  status: string;
  accreditingBody?: string | null;
  validUntil?: string | null;
}

export interface OperationalSettings {
  workingDays: string[];
  gradingPreference: GradingPreference;
  termLayout: TermLayout;
}

export interface SchoolResponse {
  id: string;
  tenantId: string;
  name: string;
  institutionCode: string;
  governmentRegistrationNumber?: string | null;
  registrationType?: string | null;
  address: string;
  contactEmail: string;
  contactPhone: string;
  logoUrl?: string | null;
  accreditationStatus: string;
  accreditationBody?: string | null;
  accreditationValidUntil?: string | null;
  workingDays: string[];
  gradingPreference: GradingPreference;
  termLayout: TermLayout;
  status: SchoolStatus | string;
  createdAt: string;
  updatedAt: string;
}

export interface RegisterSchoolRequest {
  tenantId: string;
  name: string;
  institutionCode: string;
  governmentRegistrationNumber?: string | null;
  registrationType?: string | null;
  address: string;
  contactEmail: string;
  contactPhone: string;
  logoUrl?: string | null;
  accreditationStatus?: string;
  accreditationBody?: string | null;
  accreditationValidUntil?: string | null;
  workingDays?: string[];
  gradingPreference?: GradingPreference;
  termLayout?: TermLayout;
}

export interface UpdateSchoolRequest {
  name: string;
  address: string;
  contactEmail: string;
  contactPhone: string;
  logoUrl?: string | null;
  governmentRegistrationNumber?: string | null;
  registrationType?: string | null;
  accreditationStatus?: string;
  accreditationBody?: string | null;
  accreditationValidUntil?: string | null;
}

export interface ConfigureSchoolSettingsRequest {
  workingDays: string[];
  gradingPreference: GradingPreference;
  termLayout: TermLayout;
}

export interface AcademicTermResponse {
  id: string;
  name: string;
  type: AcademicTermType;
  displayName: string;
  startDate: string;
  endDate: string;
  status: AcademicTermStatus | string;
}

export interface AcademicYearResponse {
  id: string;
  tenantId: string;
  name: string;
  startDate: string;
  endDate: string;
  status: AcademicYearStatus | string;
  terms: AcademicTermResponse[];
  createdAt: string;
  updatedAt: string;
}

export interface CreateAcademicYearRequest {
  name: string;
  startDate: string;
  endDate: string;
}

export interface AddAcademicTermRequest {
  name: string;
  type: AcademicTermType;
  displayName: string;
  startDate: string;
  endDate: string;
}
