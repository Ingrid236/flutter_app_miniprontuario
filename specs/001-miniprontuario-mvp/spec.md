# Feature Specification: MiniProntuário Odontológico MVP

**Feature Branch**: `001-miniprontuario-mvp`

**Created**: 2026-05-29

**Status**: Draft

**Input**: User description: "MiniProntuário Odontológico — Full Project Specification"

## Clarifications
### Session 2026-05-29
- Q: How should we handle local SQLite database encryption? → A: Full database encryption (Encrypted SQLite, e.g., SQLCipher) to protect patient records.
- Q: Is CPF mandatory and strictly unique for patients? → A: Mandatory & Unique (Every patient MUST have a valid, unique CPF).
- Q: How should the "Type" field for procedures be handled? → A: Predefined List + Custom (select from common list or input custom text).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Professional Registration and Authentication (Priority: P1)

A dentist needs to create a professional account and log in so that their clinical data remains secure and isolated from other users.

**Why this priority**: Without authentication, patient data isolation is impossible. This is the foundation of the app's security.

**Independent Test**: Can be fully tested by creating a new account, logging out, and successfully logging back in with the created credentials. The session must persist locally.

**Acceptance Scenarios**:

1. **Given** a new dentist, **When** they provide valid registration details (name, email, password, CPF, CRO, phone), **Then** their account is created and they are logged in.
2. **Given** a registered dentist, **When** they enter correct credentials, **Then** they access the dashboard and their session is persisted.
3. **Given** an authenticated dentist, **When** they choose to log out, **Then** their session is cleared and they are redirected to the login screen.

---

### User Story 2 - Patient Management (Priority: P1)

A dentist needs to register, view, edit, and delete patients to maintain an organized client base.

**Why this priority**: Patient records are the core entity of the system. Without patients, no procedures can be tracked.

**Independent Test**: Can be fully tested by creating a patient, viewing their details, editing their clinical observations, and deleting the record.

**Acceptance Scenarios**:

1. **Given** an authenticated dentist, **When** they fill out the required patient info (Name, Birth date, CPF, Phone), **Then** a new patient is added to their list.
2. **Given** a patient list, **When** the dentist searches for a name, **Then** matching patients are displayed immediately.
3. **Given** an existing patient, **When** the dentist updates their allergies or medications, **Then** the clinical record is successfully updated.

---

### User Story 3 - Procedure Registration and History (Priority: P2)

A dentist needs to record dental procedures for a selected patient to track their treatment history over time.

**Why this priority**: While patients are required, procedures are the main value proposition of tracking clinical history.

**Independent Test**: Can be fully tested by selecting a patient, adding a new procedure (e.g., Dental cleaning), and verifying it appears correctly in the patient's chronological history.

**Acceptance Scenarios**:

1. **Given** a selected patient, **When** the dentist registers a procedure with type, date, tooth, and status, **Then** the procedure is saved to the patient's history.
2. **Given** a patient with previous procedures, **When** the dentist views their profile, **Then** they see a chronological timeline of all past treatments.
3. **Given** an offline environment, **When** the dentist adds a procedure, **Then** the data is saved locally in SQLite without errors.

### Edge Cases

- What happens when a professional tries to register an account with a CPF that is already in use?
- If a dentist tries to register a patient with a CPF that already exists in their patient list, the system MUST block the registration and show an error message.
- How does the system handle searching for patients when the database grows large (e.g., pagination)?
- What happens if the device storage is full when trying to save a new procedure?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow professional registration with name, email, password, CPF, CRO, and phone.
- **FR-002**: System MUST authenticate users using email and password, utilizing secure local storage for session management.
- **FR-003**: System MUST provide full CRUD (Create, Read, Update, Delete) operations for Patients.
- **FR-004**: System MUST allow creating and editing Procedures linked to a specific Patient.
- **FR-005**: System MUST operate completely offline, reading and writing all data to an encrypted local database (e.g., SQLCipher) to protect patient health data.
- **FR-006**: System MUST isolate data so a logged-in dentist only sees their own patients and procedures.

### Key Entities

- **Dentist (User)**: The authenticated professional. Owns patients. Attributes: Name, Email, Password Hash, CPF, CRO, Phone.
- **Patient**: A client receiving treatment. Belongs to a Dentist. Attributes: Name, Birth date, CPF (Mandatory and strictly unique per dentist), Phone, Allergies, Medications, Chronic diseases.
- **Procedure**: A clinical intervention. Belongs to a Patient. Attributes: Type (predefined list with custom text option), Date, Tooth involved, Observations, Status, Cost (optional).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A professional can complete the registration process in under 2 minutes.
- **SC-002**: A dentist can register a new patient in under 1 minute.
- **SC-003**: The app functions 100% locally without any network requests during the entire user journey.
- **SC-004**: Searching the patient list returns results visually instantly (under 200ms).

## Assumptions

- Target users (dentists) have their own personal devices and do not share the local app installation with other professionals.
- The MVP focuses exclusively on single-device local usage. Cloud synchronization and conflict resolution are out of scope.
- Password hashing is handled locally, and the entire local database is encrypted at rest (e.g., SQLCipher) to protect user and patient data.
