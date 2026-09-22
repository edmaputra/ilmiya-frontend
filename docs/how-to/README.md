# How-To Guides (Operational Runbooks)

This section provides task-oriented, step-by-step operational runbooks for developing with, configuring, and deploying the **Ilmiya Frontend** multiplatform application. Each guide addresses a specific objective from start to finish.

---

## Guides by Objective

```
docs/how-to/
├── 01-local-dev-and-environment-modes.md           # Mock Simulation vs Live REST API & runtime flags
├── 02-backend-api-integration-and-cors.md          # Backend API contract, CORS headers & RFC 9457 errors
├── 03-auth-tokens-and-tenant-switching.md          # Bearer tokens, silent 401 refresh & tenant switching
├── 04-iam-and-rbac-administration.md               # User provisioning, RBAC roles, scopes & directory groups
├── 05-school-profile-and-academic-calendar-setup.md # School settings, academic terms & calendar lifecycle
└── 06-production-build-and-deployment.md           # Web CanvasKit release, Nginx SPA hosting & packaging
```

### 1. Environment & Runtime Configuration
- **[01. Local Development & Environment Modes](01-local-dev-and-environment-modes.md)**: How to run the application in zero-dependency Mock mode, pass compile-time flags (`--dart-define`), toggle between Mock and Live REST API modes at runtime, and target Web, Desktop, and Mobile environments.

### 2. Backend & API Connectivity
- **[02. Backend API Integration & CORS Configuration](02-backend-api-integration-and-cors.md)**: How to connect the Flutter client to downstream backend microservices, configure required headers (`X-Tenant-ID`, `Authorization`), set up CORS policies on Spring Boot, Node.js, and reverse proxies, and handle RFC 9457 Problem Details.

### 3. Identity, Security & Multi-Tenancy
- **[03. Authentication, Token Lifecycle & Dynamic Tenant Switching](03-auth-tokens-and-tenant-switching.md)**: How to log in with custom credentials, handle automatic 401 token refresh loops, switch active tenants on-the-fly, and enforce isolated state re-mounting across tenant partitions.

### 4. Campus Administration & Institutional Operations
- **[04. IAM Administration & Role-Based Access Control (RBAC)](04-iam-and-rbac-administration.md)**: How to provision users, assign roles, toggle account statuses, manage fine-grained permission scopes, organize directory groups, and test multi-role campus perspectives.
- **[05. School Profile & Academic Calendar Setup](05-school-profile-and-academic-calendar-setup.md)**: How to configure institutional branding, operational working days and hours, establish academic years and terms, and execute active academic year switches.

### 5. Build & Production Deployment
- **[06. Production Build & Multiplatform Deployment](06-production-build-and-deployment.md)**: How to compile optimized Flutter Web releases with CanvasKit, deploy to Docker and Nginx with SPA history routing, build Desktop (macOS/Linux) and Mobile (Android/iOS) packages, and run production readiness checks.

---

## Related Documentation
- [Project Overview & Architectural Summary](../../README.md)
- [Design Tokens & Natural Tones Palette](../../lib/core/constants/app_colors.dart)
- [API Client Implementation](../../lib/core/services/api_client.dart)
- [Central Application State](../../lib/state/app_state.dart)
- [Authentication State Notifier](../../lib/state/auth_notifier.dart)
