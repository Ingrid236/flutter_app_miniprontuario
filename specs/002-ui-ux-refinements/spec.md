# Feature Specification: UI, UX and Functional Refinements

**Feature Branch**: `002-ui-ux-refinements`

**Created**: 2026-06-06

**Status**: Draft

**Input**: User description: "UI, UX and Functional Refinements
1. Responsive Navigation and Icon Layout
Objective
Ensure that navigation elements, action buttons, cards, and icons are displayed correctly across different mobile screen sizes without causing layout overflow or rendering exceptions.
Requirements
Navigation icons MUST always remain within screen boundaries.
Horizontal overflow errors MUST NOT occur on any supported mobile device.
Elements MUST automatically adapt to different screen widths.
Icon groups MUST reorganize themselves when insufficient horizontal space is available.
Layouts SHOULD prioritize readability and usability over fixed positioning.
Acceptance Criteria
No RenderFlex overflow warnings are displayed.
Navigation remains fully usable on small-screen devices.
All icons remain visible without clipping or overlapping.

2. Theme Management (Light/Dark Mode)
Objective
Provide automatic and manual theme switching capabilities.
Requirements
The application MUST:
Detect the device system theme on first launch.
Automatically apply Light Mode or Dark Mode based on the device configuration.
Allow users to manually override the system preference.
Persist the selected theme preference locally.
Immediately update the UI when the theme changes.
Supported Modes
System Default
Light Mode
Dark Mode
Acceptance Criteria
Theme follows system settings by default.
Manual selection overrides system behavior.
Selected theme persists after application restart.

3. Mobile Layout Optimization
Objective
Improve the arrangement of components inside forms, cards, dialogs, and information containers to provide a better mobile experience.
Requirements
Form fields MUST be properly spaced.
Labels and values MUST remain readable on small screens.
Cards MUST avoid excessive whitespace and overcrowding.
Dialogs MUST adapt to screen size.
Important actions MUST remain visible without requiring excessive scrolling.
Information hierarchy MUST be visually clear.
Acceptance Criteria
No overlapping elements.
Consistent spacing throughout the application.
Improved readability on mobile devices.

4. Input Masks and Data Formatting
Objective
Improve user experience and data consistency through automatic input formatting.
Requirements
Input masks MUST be implemented where applicable.
Required Masks
CPF: 000.000.000-00
Phone Number: (00) 00000-0000
CRO: Apply formatting according to the chosen state registration format.
Dates: DD/MM/YYYY
Additional Formatting
Currency values MUST be formatted automatically.
Procedure costs MUST display localized currency formatting.
Numeric-only fields MUST reject invalid characters.
Acceptance Criteria
Formatting occurs while typing.
Invalid characters are prevented whenever possible.

5. Validation and Error Message Improvements
Objective
Provide clear, actionable, and user-friendly feedback.
Requirements
Error messages MUST:
Explain what happened.
Explain why it happened.
Explain how to fix it.
Generic messages MUST be avoided.
Examples
❌ Avoid: Error occurred, Invalid data, Something went wrong
✅ Prefer: The CPF entered is invalid. Please verify the number and try again. This email address is already associated with another account. Procedure date cannot be in the future. Password must contain at least 8 characters.
Acceptance Criteria
All validation errors provide meaningful feedback.
Messages are understandable by non-technical users.

6. Patient Data Ownership and Isolation
Objective
Guarantee complete data isolation between healthcare professionals.
Requirements
Patients MUST belong exclusively to the professional who created them.
The system MUST enforce ownership rules across all operations.
Ownership Rules
Patient Creation: When a patient is created: Patient.userId = LoggedUser.id
Patient Listing: A professional MUST only see patients associated with their own account.
Patient Search: Search results MUST be restricted to owned patients.
Patient Editing: Only the owner professional may update patient information.
Patient Deletion: Only the owner professional may delete patient information.
Procedure Ownership: Procedures inherit ownership from their parent patient.
Acceptance Criteria
Given Professional A and Professional B, when Professional A creates Patient X, then Professional B MUST NOT: view Patient X, search Patient X, edit Patient X, delete Patient X, or view Patient X procedures.

7. Session Persistence and User Context Integrity
Objective
Ensure the application always operates under the correct authenticated user context.
Requirements
The active session MUST persist between application launches.
User identity MUST be validated before accessing protected screens.
Logout MUST clear all session information.
User context MUST be available throughout the application lifecycle.
Acceptance Criteria
Patients are always filtered by the authenticated user.
Session remains active until logout.
User data isolation remains consistent after app restarts.

8. Accessibility and Usability Improvements
Objective
Improve accessibility and reduce interaction friction.
Requirements
Touch targets MUST follow mobile accessibility recommendations.
Buttons MUST remain easily tappable.
Text MUST maintain sufficient contrast in both themes.
Forms MUST support keyboard navigation.
Loading indicators MUST be displayed during long-running operations.
Acceptance Criteria
Application remains usable in both Light and Dark modes.
Forms are comfortable to complete on mobile devices.
UI remains accessible across supported screen sizes.

Remember, you always have to use clean code, especially the RSP principles. And remember that you are just the frontend, so you don't have logic, all the logistic part is in backend"

## Clarifications

### Session 2026-06-06
- Q: Backend Integration Strategy: Should the Flutter application communicate with the Spring Boot backend via HTTP REST APIs, or should it continue to operate as a standalone offline-first app using the local encrypted SQLite database? → A: Standalone offline-first app using local encrypted SQLite database (Option A)
- Q: CRO Field Formatting and Validation: How should the CRO input field format and validate the dentist's registration? → A: Dropdown to select the state (UF) + numeric-only field for the CRO number (Option A)
- Q: Localized Currency Formatting Standard: Should the currency format for procedure costs be strictly configured for Brazilian Real (BRL, e.g., R$ 150,00) with comma decimal separators, or should it automatically adapt to the device's system locale? → A: Dynamically adapt to the device system locale (Option B)

## User Scenarios & Testing *(mandatory)*

### User Story 1: Theme Auto-detection and Manual Persistence (Priority: P1)

As a dentist, I want the application to automatically adapt to my device's light/dark system mode and allow me to manually switch the theme, so that I have a comfortable viewing experience depending on my lighting conditions.

**Why this priority**: Highly visible impact on user experience, required for dark/light adaptation.
**Independent Test**: Can be verified by toggling system theme settings, confirming the app responds immediately, and verifying that manual selections persist upon restart.

**Acceptance Scenarios**:
1. **Given** the app is launched for the first time, **When** the device system theme is set to Dark Mode, **Then** the application starts in Dark Mode automatically.
2. **Given** the app is running under System Default theme, **When** the user manually selects Light Mode in settings, **Then** the app instantly switches to Light Mode.
3. **Given** the user manually overrides the theme to Light Mode, **When** the app is terminated and restarted, **Then** the app launches directly in Light Mode, ignoring the system theme settings.

---

### User Story 2: Form Input Formatting & Actionable Errors (Priority: P1)

As a dentist, I want input masks on fields like CPF, Phone, Dates, and CRO, along with clear and actionable validation error messages, so that I can accurately and easily input patient details without guessing the format.

**Why this priority**: Essential to maintain clean data records and prevent validation issues during form submission.
**Independent Test**: Type values into the Patient form, verify that masks format text dynamically, and try entering invalid values to confirm errors explain what happened, why, and how to fix.

**Acceptance Scenarios**:
1. **Given** the patient creation form is open, **When** the user types CPF digits "12345678901", **Then** the field displays "123.456.789-01" automatically.
2. **Given** the patient creation form is open, **When** the user types an invalid CPF and taps save, **Then** the application blocks submission and shows a validation message explaining why it is invalid and how to correct it.
3. **Given** a procedure cost input is active, **When** the user enters numeric values, **Then** the input dynamically formats as currency (e.g., R$ 150.00).

---

### User Story 3: Patient Data Isolation and Ownership (Priority: P1)

As a logged-in dentist, I want to ensure my patients' data and clinical histories are completely isolated from other dentists using the same app or system, so that patient privacy is fully preserved.

**Why this priority**: Legal and ethical requirement for medical/dental records privacy.
**Independent Test**: Register two distinct accounts, verify that Patients created by Account A are completely hidden and inaccessible via search/list to Account B.

**Acceptance Scenarios**:
1. **Given** Dentist A is logged in and creates Patient X, **When** Dentist A logs out and Dentist B logs in, **Then** Patient X is not listed, searchable, or accessible to Dentist B.
2. **Given** Dentist B attempts to access the detail page of Patient X directly, **When** ownership checks are performed, **Then** the application blocks access and returns a clear warning.
3. **Given** Dentist A creates Patient X and adds Procedure Y, **When** Dentist B is logged in, **Then** Dentist B cannot view Procedure Y or access any procedures associated with Patient X.

---

### User Story 4: Responsive and Overflow-free Layouts (Priority: P2)

As a dentist using a small mobile screen, I want all buttons, title bars, and patient cards to fit and adjust to my screen width without clipping or showing layout overflow errors.

**Why this priority**: Resolves the RenderFlex overflow issues observed on smaller mobile devices.
**Independent Test**: Load the app on a narrow device emulator or screen sizes, and verify that the "Add Procedure" button wraps or fits alongside the history header.

**Acceptance Scenarios**:
1. **Given** the Patient Detail Screen is viewed on a small mobile device (320dp width), **When** the "Histórico de Procedimentos" section is displayed, **Then** the header and the "+ Adicionar" action button adapt/wrap dynamically to prevent horizontal scroll or layout overflow.
2. **Given** a list card contains long names, **When** displayed on small screens, **Then** text wraps or truncates gracefully without pushing action icons out of screen boundaries.

---

### User Story 5: Mobile Usability & Accessibility (Priority: P3)

As a dentist who uses the application on the go, I want easily tappable touch targets, readable text contrast, and full keyboard navigation, so that I can comfortably use the application in any physical setting.

**Why this priority**: Optimizes general user ergonomics and accessibility compliance.
**Independent Test**: Verify that touch targets are at least 48x48 dp and that text contrast ratios meet accessibility standards in both Light and Dark modes.

**Acceptance Scenarios**:
1. **Given** a form field is selected, **When** keyboard navigation is used, **Then** the focus shifts sequentially to the next logical input field.
2. **Given** the app is in Light Mode or Dark Mode, **When** viewing text labels, **Then** the text remains readable with high-contrast color pairings.

---

### Edge Cases

- **System Theme Changed While App in Background**: When the user changes system theme settings in the OS while the app is minimized, the app must adapt instantly upon returning to the foreground, provided no manual override is active.
- **Incomplete Mask Submissions**: When a user inputs partial numbers in a masked field (e.g., partial CPF "123.456") and submits, the validation error must clearly request the full length.
- **Session Expiration or Logout Context Clearing**: When a user logs out, the entire local context (active dentist ID, cached patients) must be cleared immediately to prevent subsequent logins from leaking views of previous patients.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001 (System Theme Detection)**: The application MUST detect the device's default theme mode (Light or Dark) on first run and set the initial UI theme mode to match.
- **FR-002 (Manual Theme Switching)**: The application MUST provide a setting or button allowing the user to select between System default, Light, and Dark modes.
- **FR-003 (Theme State Persistence)**: The manual theme selection MUST be saved to persistent local storage and applied on subsequent launches.
- **FR-004 (CPF Format Mask)**: Input fields for CPF MUST format the entry as `000.000.000-00` and reject non-numeric characters.
- **FR-005 (Phone Number Mask)**: Input fields for Phone Number MUST format dynamically as `(00) 00000-0000` or `(00) 0000-0000` depending on input length.
- **FR-006 (CRO Formatting)**: CRO input MUST consist of a dropdown to select the state (UF) and a numeric-only field for the registration number, formatting the combination dynamically as `CRO-[UF] [number]`.
- **FR-007 (Procedure Cost Mask)**: Procedure cost inputs MUST automatically format to represent currency based on the device's default system locale settings.
- **FR-008 (User Context & Patient Isolation)**: The patient repository and service queries MUST append the logged dentist ID as a filter parameter on all database operations (create, read, update, delete).
- **FR-009 (Session Persistence)**: The user authentication token or session indicator MUST persist securely across application restarts until explicit logout.
- **FR-010 (Responsive Layout Controls)**: Page headers, text blocks, and button rows MUST wrap, scale, or use flexboxes to prevent any RenderFlex layout overflows on device widths down to 320dp.
- **FR-011 (Actionable Error Messaging)**: Form validation error messages MUST present three elements: what occurred, why it occurred, and how the user can resolve it.
- **FR-012 (Accessibility Touch Targets)**: Buttons and clickable elements MUST maintain a minimum size of 48x48 dp to satisfy touch screen guidelines.

### Key Entities

- **DentistSession**: Persists local authentication state. Key attributes: `activeDentistId`, `isAuthenticated`.
- **AppSettings**: Persists settings such as `themeMode` (System, Light, Dark).
- **Patient**: Patient details. Key attributes: `id`, `dentistId` (owner reference), `name`, `birthDate`, `cpf`, `phone`, `croState`, `croNumber`.
- **Procedure**: Clinical event under a patient. Key attributes: `id`, `patientId` (inherits ownership context), `description`, `cost`, `date`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero RenderFlex horizontal overflow warnings are encountered across all screens on devices with widths >= 320dp.
- **SC-002**: Active theme changes (light/dark manual switch) take effect within <100ms.
- **SC-003**: 100% of masked fields enforce format validation during entry and block invalid character typing.
- **SC-004**: System successfully restricts access such that an authenticated Dentist cannot query or manipulate another Dentist's Patient records, verifying complete data isolation.
- **SC-005**: 100% of validation errors present clear, non-technical instructions for resolving the error.
- **SC-006**: Session persistence retains authorization on 100% of app restarts, eliminating the login step for active sessions.

## Assumptions

- The app uses local SQLite storage (secured via SQLCipher) to store dentist, patient, and procedure records.
- Input masks format strings dynamically in the user interface to ensure clean inputs reach the storage layer.
- Local storage remains uncorrupted, and security permissions permit writing configuration files.
