# Ilmiya 🎓

> **Multiplatform School Information System (SIS)** featuring real-time grade tracking, what-if academic simulation, end-to-end contextual teacher-student-parent messaging, live push notification broadcasts, and cross-platform mobile architecture.

[![React](https://img.shields.io/badge/React-19.0-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Vite](https://img.shields.io/badge/Vite-6.2-646CFF?logo=vite&logoColor=white)](https://vitejs.dev/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4.1-38B2AC?logo=tailwindcss&logoColor=white)](https://tailwindcss.com/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

---

## 📌 Overview

**Ilmiya** is an institutional-grade School Information System (SIS) engineered for modern educational environments. Designed with a natural, human-centric aesthetic and mobile-first responsiveness, Ilmiya seamlessly connects students, educators, parents, and school administrators into a unified digital campus.

The frontend application serves both as an interactive, production-ready web portal and as a live companion workspace showcasing Flutter cross-platform architecture for native iOS and Android deployments.

---

## ✨ Key Features

### 1. 📊 Real-Time Grade Tracking & "What-If" Calculator
- **Weighted Category Breakdowns**: Detailed visibility into homework, quizzes, exams, projects, and lab performance.
- **Interactive "What-If" Simulator**: Students can simulate future assignment and exam scores in real time to project final course percentages and GPA impact.
- **Rubric-Level Feedback**: Transparent scoring with criterion-by-criterion rubric evaluations and direct instructor feedback.
- **Official Transcript Generation**: View and export comprehensive academic transcripts with weighted and unweighted GPA metrics.

### 2. 💬 Secure Contextual Messaging
- **Assignment-Linked Inquiries**: Initiate targeted discussions directly from any grade or assignment card—automatically embedding context tags into the chat thread.
- **Role-Based Channels**: Direct 1-on-1 channels, class group chats, and virtual office hours.
- **Encrypted & Safe Communication**: E2EE visual validation, rich media attachments (PDFs, code snippets, documents), and live presence indicators.

### 3. 🔔 Push Notifications & Broadcast Dispatcher
- **Interactive Notification Center**: Categorized streams for grades, messages, school announcements, attendance, and emergency alerts.
- **Live Sound Alerts**: Synthesized Web Audio API chimes and animated toast notifications.
- **Administrative Broadcast Dispatcher**: Teachers and administrators can broadcast targeted alerts to students, parents, or specific cohorts with customizable priority levels (`Low`, `Medium`, `High`, `Urgent`).

### 4. 👥 Multi-Role Campus Experience
Switch instantaneously between 4 distinct campus roles to preview tailored interfaces and permissions:
- **Student**: Track grades, view upcoming schedules, simulate GPAs, and submit inquiries.
- **Teacher**: Manage class rosters, broadcast announcements, review student submissions, and host office hours.
- **Parent**: Monitor student progress, attendance rates, grade alerts, and communicate with instructors.
- **Administrator**: Oversee institutional metrics, trigger school-wide emergency broadcasts, and manage academic terms.

### 5. 📱 Device Frame Simulator
Preview the application across multiple standard hardware form factors:
- **Responsive Desktop / Web**
- **iPhone 16 Pro (iOS)**
- **Google Pixel 9 (Android)**
- **iPad Pro (Tablet)**

### 6. 🛠️ Flutter Multiplatform Code Hub
A built-in code repository browser providing complete, ready-to-use Flutter / Dart source code matching the frontend architecture:
- Data models & JSON serialization
- State management with BLoC / Repository pattern
- Encryption and secure messaging services
- Push notification handlers
- Native UI widgets and screen implementations

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Core Framework** | [React 19](https://react.dev/) + [TypeScript 5.8](https://www.typescriptlang.org/) |
| **Build & Tooling** | [Vite 6](https://vitejs.dev/) |
| **Styling** | [Tailwind CSS v4](https://tailwindcss.com/) with custom natural color palette |
| **Typography** | Plus Jakarta Sans, Lora, Newsreader, JetBrains Mono |
| **Icons & Visuals** | [Lucide React](https://lucide.dev/), [Canvas Confetti](https://www.npmjs.com/package/canvas-confetti) |
| **Animations** | [Motion (Framer Motion)](https://motion.dev/) |
| **AI Integration** | [@google/genai](https://www.npmjs.com/package/@google/genai) |
| **Package Manager** | [Bun](https://bun.sh/) / [npm](https://www.npmjs.com/) / [pnpm](https://pnpm.io/) |

---

## 🎨 Design System & Palette

Ilmiya utilizes an earthy, distraction-free natural palette inspired by archival academic materials:

| Color Token | Hex Code | Usage |
|---|---|---|
| **Forest Sage** | `#5F6F52` | Primary brand color, header accents, active states |
| **Soft Khaki** | `#A9B388` | Secondary highlights, badges, borders |
| **Warm Sand** | `#FEFAE0` | Background surfaces, light highlights |
| **Earthy Terra** | `#B99470` | Warm indicators, category markers |
| **Natural Parchment** | `#FAF9F6` | Primary canvas & app background |
| **Deep Forest Gray** | `#2C2E2A` | Primary typography & high-contrast elements |

---

## 🚀 Getting Started

### Prerequisites

Ensure you have one of the following runtimes installed:
- **Node.js**: `v18.0.0` or later (Node 20+ recommended)
- **Bun**: `v1.0.0` or later (Optional, recommended for faster installs)

### 1. Installation

Clone the repository and install dependencies:

```bash
# Clone the repository
git clone https://github.com/edmaputra/ilmiya-frontend.git
cd ilmiya-frontend

# Install dependencies using npm
npm install

# Or using Bun
bun install
```

### 2. Environment Configuration

Copy the example environment file:

```bash
cp .env.example .env
```

Configure your `.env` variables if integrating with Gemini AI capabilities or deploying:

```ini
# Required for server-side Gemini AI features (if enabled)
GEMINI_API_KEY="your_api_key_here"

# App public host URL
APP_URL="http://localhost:3000"
```

### 3. Running the Development Server

Start the local development server:

```bash
# Using npm
npm run dev

# Or using Bun
bun dev
```

The application will be accessible at:
👉 **`http://localhost:3000`** (or `http://localhost:5173` depending on available ports)

---

## 📜 Available Scripts

| Command | Description |
|---|---|
| `npm run dev` | Starts Vite development server at `http://0.0.0.0:3000` with hot reloading |
| `npm run build` | Compiles TypeScript and creates optimized production assets in `dist/` |
| `npm run preview` | Locally serves the production build for testing |
| `npm run lint` | Type-checks code using the TypeScript compiler (`tsc --noEmit`) |
| `npm run clean` | Cleans previous build artifacts (`dist/`, `server.js`) |

---

## 📁 Project Structure

```
ilmiya-frontend/
├── assets/                  # Static graphic assets and logos
├── public/                  # Static public files, favicons, web manifests
│   ├── favicon.svg
│   ├── ilmiya.svg
│   └── ...
├── src/
│   ├── components/          # Modular UI components
│   │   ├── DashboardView.tsx       # Main dashboard, quick stats, schedule & actions
│   │   ├── DeviceFrameWrapper.tsx  # Interactive device frames (iOS, Android, Tablet)
│   │   ├── FlutterCodeHub.tsx      # Flutter / Dart architecture & source viewer
│   │   ├── GradesView.tsx          # Grades breakdown, rubric & What-If calculator
│   │   ├── HeaderNav.tsx           # Global navigation bar & role switcher
│   │   ├── IlmiyaLogo.tsx          # Vector brand logo component
│   │   ├── MessagingView.tsx       # Chat channels, contextual inquiry threads
│   │   └── NotificationsView.tsx   # Notification feed & live broadcast simulator
│   ├── data/
│   │   ├── flutterSourceCode.ts    # Comprehensive Flutter / Dart codebase files
│   │   └── mockData.ts             # Initial datasets for courses, users, messages
│   ├── App.tsx              # Root application state and navigation controller
│   ├── index.css            # Tailwind CSS directives and custom font definitions
│   ├── main.tsx             # React entrypoint
│   └── types.ts             # TypeScript definitions (Roles, Courses, Assignments, etc.)
├── .env.example             # Template for environment variables
├── bun.lock                 # Bun lockfile
├── index.html               # Main HTML entrypoint with font preconnects
├── metadata.json            # AI Studio / Applet metadata
├── package.json             # Dependencies and build scripts
├── tsconfig.json            # TypeScript configuration
└── vite.config.ts           # Vite bundler configuration
```

---

## 🛡️ Security & Privacy Features

- **Context Isolation**: Direct separation of data models between Student, Parent, Teacher, and Admin roles.
- **End-to-End Encryption Indicators**: Chat threads display verification indicators ensuring student-teacher conversations remain confidential.
- **Audit-Ready Actions**: Broadcasts and grade inquiries maintain strict metadata tagging (sender ID, timestamps, target scopes).

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the project repository.
2. Create a feature branch: `git checkout -b feature/amazing-feature`.
3. Commit your changes: `git commit -m "Add amazing feature"`.
4. Push to the branch: `git push origin feature/amazing-feature`.
5. Open a Pull Request.

---

## 📄 License

This project is licensed under the **Apache-2.0 License**. See the [LICENSE](LICENSE) file for details.
