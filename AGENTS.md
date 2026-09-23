# Agent Guide: ilmiya-frontend

Multiplatform School Information System (SIS) built with Flutter and Dart, featuring real-time grade tracking, interactive "What-If" GPA simulation, contextual messaging, live push notification broadcasts, and adaptive UI for iOS, Android, Web, and Desktop.

---

## Stack & Versions
- **Framework**: Flutter (Stable channel, >= 3.19.0)
- **Language**: Dart (>= 3.3.0) with sound null safety
- **State Management**: Provider / ChangeNotifier (`ChangeNotifierProvider`)
- **Standards**: Inherited from [`.agents/rules/flutter/`](.agents/rules/flutter/) and [`.agents/rules/shared/`](.agents/rules/shared/)

---

## Architecture: Feature-First Clean Architecture

```
lib/
├── core/                                 # Shared foundation, theme, models, and network services
│   ├── constants/                        # Natural tones palette color tokens
│   ├── theme/                            # Material 3 Adaptive Light and Dark ThemeData
│   ├── models/                           # Domain and data models (JSON serialization, immutability)
│   ├── services/                         # Dual-mode API client, IAM, school, and academic year services
│   └── data/                             # Mock dataset for offline simulation
├── state/                                # Central reactive application and authentication state
├── shared_widgets/                       # Cross-feature adaptive UI components and layouts
└── features/                             # Modular feature domains
    ├── dashboard/                        # Welcome banner, KPI cards, course list, schedule
    ├── grades/                           # Grade tracking, What-If simulator, transcript
    ├── messaging/                        # E2EE chat, channels, attachments, security audit
    ├── notifications/                    # Notification center, simulator, broadcast composer
    ├── iam_management/                   # Users, roles, groups, and scope administration
    ├── school_profile/                   # School metadata and operational settings
    ├── academic_years/                   # Academic years, semesters, and terms management
    ├── auth/                             # Custom credential login dialog
    ├── search/                           # Global command palette
    └── flutter_code/                     # Multiplatform architecture viewer & CLI guide
```

---

## Key Commands
- Install Dependencies: `flutter pub get`
- Code Formatting: `dart format .`
- Verify Formatting: `dart format --output=none --set-exit-if-changed .`
- Static Analysis: `flutter analyze --fatal-infos --fatal-warnings`
- Run Tests with Coverage: `flutter test --coverage`
- Parse Coverage Summary: `python3 .agents/scripts/coverage/generate-lcov-summary.py coverage/lcov.info target/coverage-summary.md --title "Flutter Code Coverage Summary"`
- Refresh Structure Map: `python3 .agents/scripts/scan-structure.py --force`

---

## Agent Guidelines & Critical Rules
- 🔴 **MUST**: Always inspect [`.agents/project-structure.json`](.agents/project-structure.json) for fast directory and module mapping.
- 🔴 **MUST**: Adhere to coding and architectural rules in `.agents/rules/flutter/` and `.agents/rules/shared/`.
- 🔴 **MUST**: Maintain a minimum of **80% line coverage** on core domain and data logic.
- 🔴 **MUST**: Follow Conventional Commits format (`feat`, `fix`, `chore`, etc.) as defined in [`.agents/rules/shared/git-and-ci-standards.md`](.agents/rules/shared/git-and-ci-standards.md).
- 🔴 **MUST**: Ensure zero formatting violations before committing (`dart format --output=none --set-exit-if-changed .`).
- 🔴 **MUST**: Ensure zero analysis warnings (`flutter analyze --fatal-infos --fatal-warnings`).
- 🔴 **MUST**: Ensure `project-structure.json` is ignored by Git and kept out of commits.

---

## Rule Reference Index
- [Flutter Standards](.agents/rules/flutter/flutter-standards.md)
- [Git & CI/CD Standards](.agents/rules/shared/git-and-ci-standards.md)
- [Project Structure & Agent Discovery Standards](.agents/rules/shared/project-structure-standards.md)
