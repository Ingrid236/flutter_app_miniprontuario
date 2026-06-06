# Data Model

## Entities

### DentistSession
Persists local authentication state.
- `activeDentistId`: String (UUID)
- `isAuthenticated`: Boolean

### AppSettings
Persists application settings.
- `themeMode`: String (Enum: System, Light, Dark)

### Patient
Patient details owned by a specific dentist.
- `id`: String (UUID)
- `dentistId`: String (UUID, Foreign Key) - Represents ownership
- `name`: String
- `birthDate`: Date
- `cpf`: String
- `phone`: String
- `croState`: String
- `croNumber`: String

### Procedure
Clinical event under a patient.
- `id`: String (UUID)
- `patientId`: String (UUID, Foreign Key)
- `description`: String
- `cost`: Double
- `date`: Date
