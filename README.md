# Momentum ⚡
### Cross-Platform Personal Productivity, Task Management, Consistency & KPI Tracking System

**Momentum** is a cross-platform personal productivity and consistency tracking application engineered with a **local-first architecture**. It helps users organize everyday responsibilities, maintain long-term consistency, manage nested projects, track time accurately, and measure performance against short-term and long-term key performance indicators (KPIs).

Designed natively for **Linux Desktop (Ubuntu 24.04 LTS)**, **Windows Desktop**, and **Android Mobile** (optimized for Samsung Galaxy S24 Ultra and standard smartphones).

---

## 🌟 Key Features

### 1. Local-First Task Management
- **Full Offline Capability**: Built on SQLite with Drift ORM. Operates with zero network dependency.
- **Rich Task Attributes**: Optional notes, hierarchical categories, custom icons, image attachments, external URLs, priorities (Low, Medium, High, Urgent), scheduled dates, and due dates.
- **Non-blocking Statuses**: `Pending`, `Doing`, `Done`, `Skipped`, and `Cancelled`.
- **Integrated Time Tracking**: Timestamp-based duration calculation ensuring accurate time logging across app pauses, restarts, and backgrounding. Only one timer runs at any moment.

### 2. Hierarchical Focus Labels & Sub-Projects
- **Parent & Sub-Label Hierarchy**: Organize work into parent domains (e.g., *YouTube*, *Learning*, *Career*, *Social Media*, *Personal*) and sub-labels (e.g., *Channel 1*, *Linux*, *Internship Preparation*, *Instagram*).
- **Consolidated Parent Dashboards**: Parent dashboards aggregate all child sub-labels and direct parent tasks with weighted completion rates—**strictly preventing double-counting**.
- **Independent KPI Targets**: Configure count targets, time targets, or rate targets per sub-label.

### 3. Flexible Recurrence Engine
- **9 Recurrence Modes**: Once, Daily, Weekdays, Every Other Day, Every $N$ Days, Weekly (specific days of week), Monthly, Every $N$ Months, and Custom intervals.
- **Bounded Occurrence Expansion**: Timezone-safe calculations with date normalization.
- **Per-occurrence Completion**: Complete or skip specific occurrences without altering the master recurring template.

### 4. Consistency & Streak Tracking
- **Consecutive Day Calculations**: Active streak computation with 1-day grace period support.
- **Non-punitive Analytics**: Future dates and skipped tasks are never treated as failures.
- **Visual Analytics**: Daily stacked bar charts, weekly productivity curves, and focus distribution donut charts powered by `fl_chart`.

### 5. Linux Desktop Wallpaper Dashboard
- **Live Wallpaper HUD**: Generates a dynamic 1920×1080 SVG dashboard displaying today's progress, focus area completion, consistency streak, and motivational quotes.
- **Desktop Adapter Detection**: Native support for **GNOME Shell**, **KDE Plasma**, and **XFCE**.
- **Safe Restoration**: Saves the user's original desktop wallpaper before initial modification and restores it immediately upon disabling the feature.
- **Debounced Auto-Update**: Automatically refreshes the wallpaper 10 seconds after task changes to conserve system resources.

### 6. Cloud Synchronization (Supabase)
- **Bi-Directional Offline Sync**: Changes are queued in local SQLite `SyncQueueItems` and synced automatically when network connectivity is detected.
- **Conflict Resolution Rules**:
  1. *Last-Write-Wins (LWW)*: Based on updated timestamps for master records.
  2. *Server-Wins*: For deletion conflicts.
  3. *Append-Only*: For `CompletionEvents` and `TimerSessions` so no user effort is lost.
- **Row-Level Security (RLS)**: PostgreSQL schema with RLS policies ensuring users only access their own data.

### 7. Mindful Motivation & Notifications
- **Curated Motivational Quotes**: Curated database of 60+ positive, progress-oriented quotes.
- **Anti-Repetition Algorithm**: Dynamically delivers morning, afternoon, evening, and completion quotes without consecutive repeats.
- **Configurable Notifications**: Hourly check-in reminders, active work hours, quiet hours, and daily completion digests.

---

## 🏗️ Architecture & Technology Stack

```
lib/
├── core/                       # Core system, theme, and utilities
│   ├── constants/              # App icons, default labels, constants
│   ├── errors/                 # Result<T> pattern and domain AppError
│   ├── extensions/             # Context, DateTime, and String extensions
│   ├── theme/                  # Material 3 typography, palette, radius, spacing
│   └── utils/                  # Date formatting, math, validators, strings
├── data/
│   ├── local/                  # SQLite persistence (Drift)
│   │   ├── daos/               # DAOs (Tasks, Labels, Occurrences, Timer, KPI, Sync)
│   │   ├── tables/             # Drift schema tables
│   │   └── database.dart       # Main Drift database with background executor
│   ├── remote/                 # Supabase client wrapper & authentication
│   ├── repositories/           # Repositories (Task, Label, KPI, Timer)
│   └── sync/                   # Sync engine & conflict resolver
├── domain/
│   ├── enums/                  # TaskStatus, Priority, RecurrenceType, etc.
│   ├── models/                 # Immutable domain entities with Equatable
│   └── services/               # Recurrence, KPI calculations, Streaks, Timers
├── features/
│   ├── analytics/              # Analytics dashboard & fl_chart visualizations
│   ├── calendar/               # Month grid inspector & occurrence history
│   ├── dashboard/              # Main HUD, greetings, quick-add, label overview
│   ├── labels/                 # Label management & consolidated parent/child screens
│   ├── linux_wallpaper/        # SVG renderer, desktop adapters (GNOME/KDE/XFCE)
│   ├── motivation/             # Time-of-day quotes and greetings service
│   ├── notifications/          # Local notifications manager
│   ├── settings/               # Themes, credentials, backup JSON export/import
│   └── tasks/                  # Today tasks, All tasks, Task form, filters
├── routing/                    # GoRouter configuration with ShellRoute navigation
└── shared/                     # Reusable widgets (Cards, Scaffolds, Pickers)
```

---

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK**: Version `3.47.x` or newer (Dart `3.13.x`+).
2. **C/C++ Build Tools** (for Linux Desktop):
   ```bash
   sudo apt update
   sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libsecret-1-dev
   ```
3. **Optional for Wallpaper PNG Rendering** (Linux):
   ```bash
   sudo apt install -y imagemagick
   ```

### Installation

Clone the repository and fetch dependencies:

```bash
git clone https://github.com/your-username/momentum.git
cd momentum
flutter pub get
```

To compile code generators (Drift database models):
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 💻 Building and Running

### 1. Linux Desktop (Ubuntu 24.04 LTS)

Run in debug mode:
```bash
flutter run -d linux
```

Build release bundle:
```bash
flutter build linux --release
```
The compiled binary will be located at:
`build/linux/x64/release/bundle/momentum`

### 2. Windows Desktop

Run in debug mode:
```bash
flutter run -d windows
```

Build release bundle:
```bash
flutter build windows --release
```
The compiled executable will be located at:
`build/windows/x64/runner/Release/momentum.exe`

### 3. Android (Mobile)

Connect an Android device (e.g. Samsung Galaxy S24 Ultra) via USB debugging:
```bash
flutter devices
flutter run -d <device-id>
```

Build release APK or App Bundle:
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

---

## ☁️ Supabase Cloud Backend Setup

Momentum functions 100% offline without Supabase. To enable optional cloud backup and cross-device sync:

1. Create a project at [supabase.com](https://supabase.com).
2. Navigate to the **SQL Editor** in your Supabase dashboard.
3. Open `supabase/migrations/20261016_initial_schema.sql` from this repository and run the entire script.
   - Creates `labels`, `tasks`, `recurrence_rules`, `task_occurrences`, `completion_events`, `timer_sessions`, `kpi_definitions`, and `notification_settings` tables.
   - Enables Row Level Security (RLS) on all tables.
   - Creates automatic `updated_at` timestamp triggers.
4. Open **Settings** in the Momentum application:
   - Paste your **Supabase Project URL** (`https://xyz.supabase.co`).
   - Paste your **Supabase Anon Key**.
   - Tap **Save Credentials**.
   - Register or Sign In with your email.

---

## 🧪 Testing & Code Quality

Momentum maintains a comprehensive test suite covering domain business logic, recurrence rules, KPI aggregations, streak algorithms, repositories, providers, and widget rendering.

Run all unit and widget tests:
```bash
flutter test
```

Run static analysis:
```bash
flutter analyze lib/ test/
```

Expected result: **0 errors, 0 warnings, 0 lint issues**.

---

## 🔒 Security & Data Integrity

- **Local Privacy**: All databases, cache files, and settings are stored locally in standard OS application data directories.
- **Foreign Key Protection**: SQLite PRAGMA `foreign_keys = ON` ensures child occurrences and timer logs are cleanly cascading.
- **No Data Loss on Sync**: Deleting or archiving a label retains historical `CompletionEvent` logs and previous KPI performance.
- **Wallpaper Safety**: The original desktop wallpaper setting is securely cached in `SharedPreferences` before any modification is applied.

---

## 📄 License

This project is licensed under the MIT License — see the LICENSE file for details.
