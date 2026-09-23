# Ilmiya 🎓

> **Multiplatform School Information System (SIS)** built with **Flutter 3.19+** and **Dart 3.3+**, featuring real-time grade tracking, interactive "What-If" GPA simulation, end-to-end contextual teacher-student-parent messaging, live push notification broadcasts, and adaptive UI for iOS, Android, Web, and Desktop.

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

---

## 📌 Overview

**Ilmiya** is an institutional-grade School Information System (SIS) engineered for modern educational environments. Designed with an archival natural tones aesthetic (Forest Sage, Soft Khaki, Warm Sand, Earthy Terra, Natural Parchment) and adaptive multiplatform responsiveness, Ilmiya seamlessly connects students, educators, parents, and school administrators into a unified digital campus.

---

## ✨ Key Features

### 1. 📊 Real-Time Grade Tracking & "What-If" Calculator
- **Weighted Category Breakdowns**: Detailed visibility into homework, quizzes, exams, projects, and lab weights.
- **Interactive "What-If" Simulator**: Simulate future assignment and exam scores in real time to project final course percentages and GPA impact.
- **Rubric-Level Feedback**: Transparent scoring with criterion-by-criterion rubric evaluations and direct instructor feedback.
- **Official Academic Transcript**: View and export comprehensive academic transcripts with weighted (5.0 scale) and unweighted (4.0 scale) GPA metrics.

### 2. 💬 Secure Contextual Messaging
- **Assignment-Linked Inquiries**: Initiate targeted discussions directly from any grade or assignment card—automatically embedding context tags into the chat thread.
- **Role-Based Channels**: Direct 1-on-1 channels, class group chats, and virtual office hours.
- **Encrypted & Safe Communication**: E2EE visual validation (AES-256-GCM / ECDH Curve25519), document/PDF attachments, and live presence indicators.

### 3. 🔔 Push Notifications & Broadcast Dispatcher
- **Interactive Notification Center**: Categorized streams for grades, messages, school announcements, attendance, and emergency alerts.
- **Live Sound Alerts & Simulator**: Dispatch simulated push alerts for instant testing.
- **Administrative Broadcast Dispatcher**: Teachers and administrators can broadcast targeted alerts to students, parents, or specific cohorts with customizable priority levels (`Low`, `Medium`, `High`, `Urgent`).

### 4. 👥 Multi-Role Campus Experience
Switch instantaneously between 4 distinct campus roles to preview tailored interfaces and permissions:
- **Student**: Track grades, view upcoming schedules, simulate GPAs, and submit inquiries.
- **Teacher**: Manage class rosters, broadcast announcements, edit gradebooks inline, and host office hours.
- **Parent**: Monitor student progress, attendance rates, grade alerts, and communicate with instructors.
- **Administrator**: Oversee institutional metrics, trigger school-wide emergency broadcasts, and manage academic terms.

---

## 🎨 Natural Tones Design System

| Color Token | Hex Code | Usage |
|---|---|---|
| **Forest Sage** | `#5F6F52` | Primary brand color, headers, active tabs, buttons |
| **Soft Khaki** | `#A9B388` | Secondary highlights, badges, borders |
| **Warm Sand** | `#FEFAE0` | Background surfaces, light highlights, toast popovers |
| **Earthy Terra** | `#D67D5B` | Warm indicators, category markers, urgent alerts |
| **Natural Parchment** | `#FAF9F6` | Primary canvas & app background |
| **Deep Forest Gray** | `#2C2E2A` | Primary typography & high-contrast elements |

---

## 📂 Project Architecture

```
lib/
├── main.dart                             # Application entry point with ProviderScope
├── core/
│   ├── constants/
│   │   └── app_colors.dart               # Natural tones palette color tokens
│   ├── theme/
│   │   └── app_theme.dart                # Material 3 Adaptive Light and Dark ThemeData
│   ├── models/
│   │   ├── user_profile.dart             # User roles & profiles
│   │   ├── course.dart                   # Courses, assignments, rubrics, category weights
│   │   ├── notification_item.dart        # Real-time notifications model
│   │   ├── chat_message.dart             # E2EE chat messages, attachments, context tags
│   │   └── schedule_period.dart          # Daily schedule periods & timetable
│   ├── data/
│   │   └── mock_data.dart                # Comprehensive initial dataset
│   └── services/
│       ├── api_client.dart               # HTTP client (base URL, auth headers, token refresh)
│       ├── iam_service.dart              # IAM: login, RBAC, groups, scopes, tenant switch
│       ├── school_service.dart           # School profile & settings CRUD
│       ├── academic_year_service.dart    # Academic years & terms CRUD
│       ├── mock_storage_service.dart     # In-memory mock backend (used in Mock mode)
│       └── notification_service.dart     # Haptic feedback & audio notification dispatcher
├── state/
│   ├── app_state.dart                    # Central reactive state (ChangeNotifier)
│   └── auth_notifier.dart               # Auth state: login, logout, tenant switch, RBAC
├── shared_widgets/
│   ├── ilmiya_logo.dart                  # Custom vector brand logo & squircle widget
│   ├── header_nav_bar.dart               # Adaptive header bar & role switcher
│   ├── toast_popover.dart                # Animated live push notification toast
│   └── adaptive_scaffold.dart            # Multiplatform responsive layout wrapper
└── features/
    ├── dashboard/                        # Welcome banner, KPI cards, course list, schedule
    ├── grades/                           # Grade tracking, What-If simulator, transcript
    ├── messaging/                        # E2EE chat, channels, attachments, security audit
    ├── notifications/                    # Notification center, simulator, broadcast composer
    └── flutter_code/                     # Multiplatform architecture viewer & CLI guide
```

---

## 📖 Operational Runbooks & How-To Guides

For step-by-step operational runbooks on local development, backend integration, authentication, campus administration, and production deployments, consult the **[How-To Guides Portal](docs/how-to/README.md)**:

| Runbook | Summary |
|---|---|
| **[01. Local Dev & Environment Modes](docs/how-to/01-local-dev-and-environment-modes.md)** | Run in Mock vs Live REST mode, configure `--dart-define`, and toggle environments at runtime. |
| **[02. Backend API & CORS Integration](docs/how-to/02-backend-api-integration-and-cors.md)** | Connect downstream microservices, configure CORS policies, and handle RFC 9457 errors. |
| **[03. Auth & Dynamic Tenant Switching](docs/how-to/03-auth-tokens-and-tenant-switching.md)** | Sign in, automate 401 token refresh loops, and switch tenant partitions with clean state isolation. |
| **[04. IAM & RBAC Administration](docs/how-to/04-iam-and-rbac-administration.md)** | Provision users, manage custom roles, configure scope permission trees, and test multi-role perspectives. |
| **[05. School Profile & Academic Calendar](docs/how-to/05-school-profile-and-academic-calendar-setup.md)** | Configure institutional branding, operational hours, grading scales, academic years, and terms. |
| **[06. Production Build & Deployment](docs/how-to/06-production-build-and-deployment.md)** | Compile optimized Web CanvasKit releases, deploy with Docker/Nginx SPA routing, and package native binaries. |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.19.0)
- [Dart SDK](https://dart.dev/get-dart) (>= 3.3.0)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run in Development (Mock Mode — no backend required)

By default the app starts in **Mock In-Memory Simulation** mode. No backend is needed.

```bash
# Web (Chrome / Edge)
flutter run -d chrome

# Web server on custom port (headless / server deployment)
flutter run -d web-server --web-port=8080

# iOS Simulator or Device
flutter run -d ios

# Android Emulator or Device
flutter run -d android

# Linux Desktop
flutter run -d linux

# macOS Desktop
flutter run -d macos
```

---

## 🔌 Connecting to an Actual Backend Service

Ilmiya ships with a **dual-mode API client** (`lib/core/services/api_client.dart`):

| Mode | Description |
|---|---|
| **Mock Simulation** | All data is served from in-memory mock storage. No backend required. |
| **Live REST API** | All requests are forwarded to a real backend running on a configurable port. Requires a valid backend service with a compatible API contract. |

### Step 1: Copy and Configure the Environment File

```bash
cp .env.example .env
```

Edit `.env` and set your backend base URL:

```env
# Base URL of your backend service (no trailing slash)
# Example: local backend on port 9090
ILMIYA_API_BASE_URL=http://localhost:9090

# Default tenant ID to use for multi-tenant environments
ILMIYA_DEFAULT_TENANT_ID=tenant-lincoln-high-001
```

> **Note:** Flutter web runs in the browser and has no direct access to `.env` files.  
> Pass the backend URL at runtime using `--dart-define`:

```bash
# Run against a local backend on port 9090
flutter run -d chrome \
  --dart-define=ILMIYA_API_BASE_URL=http://localhost:9090 \
  --dart-define=ILMIYA_DEFAULT_TENANT_ID=tenant-lincoln-high-001
```

```bash
# Build production web with a real backend
flutter build web --release \
  --dart-define=ILMIYA_API_BASE_URL=https://api.yourschool.com \
  --dart-define=ILMIYA_DEFAULT_TENANT_ID=tenant-yourschool-001
```

These values are read in `lib/core/services/api_client.dart`:

```dart
// api_client.dart
String _baseUrl = const String.fromEnvironment(
  'ILMIYA_API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
```

### Step 2: Switch to Live REST API Mode In-App

Once the app is running, open the header bar and click the **mode pill** (shows `Mock Simulation` or `Live REST API`):

- Tap it to toggle between Mock and Live modes.
- In **Live REST API** mode all service calls are forwarded to the configured `baseUrl` with the `X-Tenant-ID` header automatically applied.

### Step 3: Log In with Real Credentials

When in Live mode, click the **user avatar → Sign In with Custom Credentials** to authenticate against your backend and receive a JWT token. The client automatically:

1. Attaches `Authorization: Bearer <token>` to every request.
2. Silently refreshes the token via `POST /api/v1/auth/refresh` on a 401 response.
3. Logs you out and shows a session-expired message if the refresh also fails.

---

## 🌐 Backend API Contract

The following REST endpoints are expected by the Flutter client. Implement them in your backend service (Spring Boot, Django, Node, etc.) at the configured `ILMIYA_API_BASE_URL`.

All requests include:
- `Content-Type: application/json`
- `X-Tenant-ID: <tenantId>` header
- `Authorization: Bearer <token>` (when authenticated)

Error responses should follow [RFC 9457 Problem Details](https://www.rfc-editor.org/rfc/rfc9457):
```json
{ "status": 403, "title": "Forbidden", "detail": "Insufficient permissions." }
```

### Authentication

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/auth/login` | Login with email + password. Returns `accessToken`, `refreshToken`, `tenantId`, `roles`, `permissions`. |
| `POST` | `/api/v1/auth/refresh` | Refresh expired access token. Body: `{ "refreshToken": "..." }`. |
| `POST` | `/api/v1/auth/logout` | Invalidate the current session token. |
| `POST` | `/api/v1/auth/switch-tenant` | Switch active tenant. Body: `{ "tenantId": "..." }`. Returns new tokens + roles. |

### IAM — Users

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/iam/users/me` | Get current authenticated user profile. |
| `GET` | `/api/v1/iam/users` | List all users in the current tenant. |
| `POST` | `/api/v1/iam/users` | Create a new user. |
| `PATCH` | `/api/v1/iam/users/{userId}/status` | Update user status (`ACTIVE`, `SUSPENDED`, etc.). |
| `POST` | `/api/v1/iam/users/{userId}/roles` | Assign a role to a user. |
| `DELETE` | `/api/v1/iam/users/{userId}` | Delete a user. |

### IAM — Roles, Groups & Scopes

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/iam/roles` | List all RBAC roles in the current tenant. |
| `POST` | `/api/v1/iam/roles` | Create a new role. |
| `DELETE` | `/api/v1/iam/roles/{roleId}` | Delete a role. |
| `GET` | `/api/v1/iam/groups` | List all directory groups. |
| `POST` | `/api/v1/iam/groups` | Create a new group. |
| `POST` | `/api/v1/iam/groups/{groupId}/members` | Add a user to a group. |
| `DELETE` | `/api/v1/iam/groups/{groupId}` | Delete a group. |
| `GET` | `/api/v1/iam/scopes` | Get the full permission scope tree. |

### School Profile

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/school-profile` | Get school profile. |
| `PUT` | `/api/v1/school-profile` | Update school profile. |
| `GET` | `/api/v1/school-profile/settings` | Get operational settings (working days, hours, etc.). |
| `PUT` | `/api/v1/school-profile/settings` | Update operational settings. |

### Academic Years & Terms

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/academic-years` | List all academic years for the current tenant. |
| `POST` | `/api/v1/academic-years` | Create a new academic year. |
| `POST` | `/api/v1/academic-years/{yearId}/activate` | Set an academic year as active. |
| `POST` | `/api/v1/academic-years/{yearId}/terms` | Add a term to an academic year. |

---

## 🔒 CORS Configuration (Backend Side)

When running the Flutter web app on `localhost:8080` against a backend on a different port (e.g., `localhost:9090`), you must enable CORS on the backend.

### Spring Boot Example

```java
@Configuration
public class CorsConfig {
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        // Flutter web dev origins
        config.setAllowedOrigins(List.of(
            "http://localhost:8080",
            "http://localhost:3000",
            "https://yourdomain.com"
        ));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of(
            "Authorization", "Content-Type", "Accept", "X-Tenant-ID"
        ));
        config.setExposedHeaders(List.of("Authorization"));
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", config);
        return source;
    }
}
```

### Node.js / Express Example

```js
const cors = require('cors');
app.use(cors({
  origin: ['http://localhost:8080', 'https://yourdomain.com'],
  allowedHeaders: ['Authorization', 'Content-Type', 'X-Tenant-ID'],
  credentials: true,
}));
```

> **Key header to allow:** `X-Tenant-ID` — the Flutter client sends this on every request to identify the active tenant.

---

## 🧪 Testing

```bash
# Run all unit and widget tests
flutter test

# Run with verbose output
flutter test --reporter expanded

# Static analysis (zero warnings)
flutter analyze
```

---

## 🏗️ Build Production Releases

```bash
# Production Web Build
flutter build web --release --web-renderer canvaskit \
  --dart-define=ILMIYA_API_BASE_URL=https://api.yourschool.com \
  --dart-define=ILMIYA_DEFAULT_TENANT_ID=tenant-yourschool-001

# Linux Desktop Release Bundle
flutter build linux --release

# Android Release APK & App Bundle
flutter build appbundle --release

# iOS Release Archive
flutter build ipa --release
```

---

## 📄 License
This project is licensed under the **Apache-2.0 License**. See the [LICENSE](LICENSE) file for details.

