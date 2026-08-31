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
│       └── notification_service.dart     # Haptic feedback & audio notification dispatcher
├── state/
│   └── app_state.dart                    # Central reactive state (ChangeNotifier)
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

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.19.0)
- [Dart SDK](https://dart.dev/get-dart) (>= 3.3.0)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run in Development
```bash
# Run on Web without launching a specific browser (Headless / Generic Web Server)
flutter run -d web-server --web-port=8080

# Run on Web (Chrome / Edge)
flutter run -d chrome

# Run on iOS Simulator or Device
flutter run -d ios

# Run on Android Emulator or Device
flutter run -d android

# Run on Linux Desktop
flutter run -d linux

# Run on macOS Desktop
flutter run -d macos
```

### 3. Build Production Releases
```bash
# Production Web Build
flutter build web --release --web-renderer canvaskit

# Linux Desktop Release Bundle
flutter build linux --release

# Android Release APK & App Bundle
flutter build appbundle --release

# iOS Release Archive
flutter build ipa --release
```

---

## 🧪 Testing

Run Flutter unit and widget smoke tests:
```bash
flutter test
```

---

## 📄 License
This project is licensed under the **Apache-2.0 License**. See the [LICENSE](LICENSE) file for details.
