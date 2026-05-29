# Data Model

## Entities

### Dentist (User)
The authenticated professional.
- `id` (String, UUID, Primary Key)
- `name` (String, Required)
- `email` (String, Required, Unique)
- `password_hash` (String, Required)
- `cpf` (String, Required, Unique)
- `cro` (String, Required)
- `phone` (String, Required)
- `created_at` (DateTime, Required)

### Patient
A client receiving treatment.
- `id` (String, UUID, Primary Key)
- `dentist_id` (String, UUID, Foreign Key to Dentist)
- `name` (String, Required)
- `birth_date` (DateTime, Required)
- `cpf` (String, Required, Unique per dentist_id)
- `phone` (String, Required)
- `allergies` (String, Optional)
- `medications` (String, Optional)
- `chronic_diseases` (String, Optional)
- `created_at` (DateTime, Required)
- `updated_at` (DateTime, Required)

### Procedure
A clinical intervention.
- `id` (String, UUID, Primary Key)
- `patient_id` (String, UUID, Foreign Key to Patient)
- `type` (String, Required) // Either from predefined list or custom text
- `date` (DateTime, Required)
- `tooth` (String, Optional) // E.g., '14', '36'
- `observations` (String, Optional)
- `status` (String, Required) // E.g., 'Planned', 'Completed'
- `cost` (Decimal, Optional)
- `created_at` (DateTime, Required)

## Database Schema Constraints
- SQLite Foreign Keys MUST be enabled.
- On Delete CASCADE for Patients when Dentist is deleted.
- On Delete CASCADE for Procedures when Patient is deleted.
