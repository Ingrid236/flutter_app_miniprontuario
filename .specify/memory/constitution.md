<!--
Sync Impact Report:
- Version change: 0.1.0 -> 0.2.0
- List of modified principles:
  - Expanded Clean Architecture enforcement
  - Added SOLID enforcement
  - Added Git & Commit conventions
  - Added API & Backend standards
  - Added Database & Persistence standards
  - Added Documentation requirements
  - Added Performance & Maintainability rules
  - Added Security & Secret Management rules
- Added sections:
  - VI. SOLID Principles Enforcement
  - VII. API & Backend Standards
  - VIII. Database & Persistence
  - IX. Git Workflow & Conventional Commits
  - X. Documentation Standards
  - XI. Performance & Scalability
  - XII. Security & Secret Management
- Removed sections: None
- Templates requiring updates:
  - .specify/templates/plan-template.md: ✅ No updates needed
  - .specify/templates/spec-template.md: ✅ No updates needed
  - .specify/templates/tasks-template.md: ✅ No updates needed
- Follow-up TODOs: None
-->

# MiniProntuario Constitution

## Core Principles

### I. Clean Architecture & State Separation

All business logic, API requests, and state management operations MUST be kept strictly separate from the UI layer (Widgets). Widgets MUST remain declarative, presenting visual state and dispatching user interaction events.

The project MUST follow Clean Architecture principles with clear separation between:

* Presentation Layer
* Domain Layer
* Data Layer

Dependencies MUST always point inward toward abstractions rather than implementations.

---

### II. Component-Driven Design

UI components MUST be built in a modular, reusable, and single-purpose manner.

Large, nested widget trees MUST be refactored and extracted into stateless or stateful sub-widgets.

Reusable UI patterns MUST be centralized whenever possible.

Widgets MUST avoid side effects and direct business logic manipulation.

---

### III. Platform & Screen Responsiveness

The user interface MUST adapt gracefully to varying screen ratios, viewport sizes, and orientations.

Hardcoded dimensions MUST be avoided, favoring:

* LayoutBuilder
* MediaQuery
* Flexible
* Expanded
* Responsive constraints

The application MUST provide acceptable usability on:

* Mobile devices
* Tablets
* Web browsers

---

### IV. Testing & Code Quality Assurance

Unit tests for logic classes and widget tests for key UI flows MUST be implemented.

The codebase MUST:

* Compile without errors
* Pass static analysis
* Pass formatting checks
* Follow flutter_lints rules
* Avoid dead code
* Avoid duplicated logic

Critical business flows MUST include automated tests.

Pull requests containing failing tests MUST NOT be merged.

---

### V. Secure & Offline-First State Management

Sensitive data MUST be secured locally using secure storage libraries.

Local databases MUST handle:

* Read/write failures
* Corrupted data recovery
* Offline synchronization preparation

Network layers MUST gracefully manage:

* Connection timeouts
* Retry strategies
* API failures
* Offline states

Secrets, tokens, and credentials MUST NEVER be hardcoded.

---

### VI. SOLID Principles Enforcement

The project MUST strictly follow SOLID principles.

#### Single Responsibility Principle

Classes and services MUST have only one responsibility.

#### Open/Closed Principle

Components MUST be extendable without requiring modification of stable code.

#### Liskov Substitution Principle

Abstractions and implementations MUST remain interchangeable.

#### Interface Segregation Principle

Interfaces MUST remain small and focused.

#### Dependency Inversion Principle

High-level modules MUST depend on abstractions instead of concrete implementations.

---

### VII. API & Backend Standards

The backend architecture MUST follow:

* RESTful conventions
* DTO pattern
* Repository pattern
* Service layer pattern
* Dependency Injection

Controllers MUST:

* Handle request/response only
* Never contain business logic

Services MUST:

* Encapsulate all business rules

Repositories MUST:

* Handle only persistence responsibilities

API responses MUST use:

* Proper HTTP status codes
* Structured error responses
* Consistent JSON formatting

Swagger/OpenAPI documentation SHOULD be maintained and updated.

---

### VIII. Database & Persistence

Persistence layers MUST remain isolated from UI concerns.

The project MUST support:

* Local SQLite persistence
* Future synchronization capabilities

Database migrations MUST be versioned and reproducible.

Direct SQL execution inside Widgets or UI logic is strictly prohibited.

---

### IX. Git Workflow & Conventional Commits

The repository MUST follow a standardized Git workflow.

Recommended branches:

```text
main
develop
feature/*
fix/*
hotfix/*
```

Commits MUST follow Conventional Commits.

Examples:

```text
feat: add patient registration flow
fix: correct login validation
refactor: improve dependency injection setup
test: add widget tests for appointment screen
```

Force pushes to protected branches MUST be avoided.

---

### X. Documentation Standards

The project MUST maintain updated documentation for:

* Setup instructions
* Architecture decisions
* API contracts
* Environment configuration
* Important workflows

A README file MUST exist and remain updated.

Complex business rules SHOULD be documented.

---

### XI. Performance & Scalability

The application MUST prioritize maintainability and scalability over premature optimization.

The codebase SHOULD:

* Avoid unnecessary widget rebuilds
* Avoid excessive database queries
* Use lazy loading where appropriate
* Use pagination for large datasets
* Minimize memory waste

Large files and oversized classes MUST be refactored.

---

### XII. Security & Secret Management

Sensitive information MUST NEVER be committed into version control.

The following MUST be protected:

* API keys
* JWT secrets
* Environment variables
* Authentication tokens

Input validation MUST exist for all external data sources.

Stack traces and internal exceptions MUST NOT be exposed to end users in production environments.

---

## Technical Stack & Constraints

The application is built using:

* Flutter SDK
* Dart
* Java Backend
* SQLite Local Persistence
* REST APIs

The chosen state management solution MUST remain consistent across the project.

External packages MUST NOT be added without technical validation and architectural justification.

---

## Development & Review Gates

Every Pull Request MUST contain:

* Approved implementation plan
* Manual verification evidence
* Required automated tests
* Passing CI/CD pipeline
* Code review approval

The following checks are mandatory before merge:

* Static analysis
* Formatting validation
* Unit tests
* Widget tests
* Build verification

---

## Governance

This constitution defines the development standards and non-negotiable engineering rules for the project.

All contributors MUST comply with these principles.

Any amendment to this constitution requires:

1. Team consensus
2. Documentation update
3. Semantic version increment
4. Updated Sync Impact Report

---

**Version**: 0.2.0
**Ratified**: 2026-05-29
**Last Amended**: 2026-05-29
