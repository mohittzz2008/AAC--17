# ROVER COMMAND — Complete Application Architecture & Navigation Flow

## 1. System Overview

ROVER COMMAND is an industrial-grade telemetry, inspection, and monitoring frontend designed for autonomous and semi-autonomous rover systems. It is engineered with a strict **Feature-First + MVVM + Repository** architecture with **zero third-party state-management packages**, relying entirely on standard Flutter primitives (`ChangeNotifier`, `ListenableBuilder`, `LayoutBuilder`, `CustomPainter`).

```
┌────────────────────────────────────────────────────────────────────────┐
│                        SHARED APPLICATION SHELL                        │
│             (App Header, Responsive Nav Capsule / Nav Rail)            │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
         ┌──────────────────────────┼──────────────────────────┐
         │                          │                          │
         ▼                          ▼                          ▼
┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐
│  01. DASHBOARD  │        │   02. CAMERA    │        │   03. SENSORS   │
│  (Overview &    │        │  (ESP32-CAM     │        │ (HC-SR04 &      │
│   Telemetry)    │        │   Inspection)   │        │  RCWL-0516)     │
└─────────────────┘        └─────────────────┘        └─────────────────┘
                                    │
                                    ▼
                           ┌─────────────────┐
                           │   04. SYSTEM    │
                           │  (Hardware Hub) │
                           └────────┬────────┘
                                    │  (Secondary Navigation)
         ┌──────────────────────────┼──────────────────────────┐
         │                          │                          │
         ▼                          ▼                          ▼
┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐
│ 05. CONNECTION  │        │ 06. DIAGNOSTICS │        │ 07. EVENT LOGS  │
│  (Discovery &   │        │ (Health Checks  │        │ (History, Search│
│   Pairing)      │        │  & Faults)      │        │  & Filters)     │
└─────────────────┘        └─────────────────┘        └─────────────────┘
         │                                                     │
         ▼                                                     ▼
┌─────────────────┐                                   ┌─────────────────┐
│08. CONFIGURATION│                                   │  09. FIRMWARE   │
│ (Settings &     │                                   │ (Inventory &    │
│  Calibration)   │                                   │  Maintenance)   │
└─────────────────┘                                   └─────────────────┘
```

---

## 2. Navigation Architecture

### 2.1 Primary Navigation (Application Shell)
The application shell (`RoverShell`) maintains the primary selected destination among the four top-level tabs:
1. `Dashboard` (`ShellDestination.dashboard`)
2. `Camera` (`ShellDestination.camera`)
3. `Sensors` (`ShellDestination.sensors`)
4. `System` (`ShellDestination.system`)

Responsive adaptation:
* **Mobile (< 600 dp)**: Fixed floating bottom capsule navigation (`RoverBottomNavigationBar`) with safe area offsets.
* **Tablet (600 - 1024 dp)**: Adaptive capsule navigation preserving horizontal viewport.
* **Desktop (≥ 1024 dp)**: Persistent 110 dp left navigation rail (`RoverNavigationRail`) with active gold highlight and labeled icons.

### 2.2 Secondary Navigation (System Management Hub)
When the user is in the `System` destination, five secondary management destinations are accessible:
1. `Device Connection` (`SystemSubDestination.deviceConnection`)
2. `Diagnostics & Health` (`SystemSubDestination.diagnostics`)
3. `Activity & Event Logs` (`SystemSubDestination.activityLogs`)
4. `Configuration & Calibration` (`SystemSubDestination.configuration`)
5. `Firmware & Maintenance` (`SystemSubDestination.firmware`)

The navigation architecture implements:
* Sub-page state retention without recreating ViewModels.
* Breadcrumb navigation bar on secondary pages with a back button leading back to the `System` hub.
* Direct deep-linking or shortcut navigation from other features (e.g., Camera retry shortcut to Diagnostics; Dashboard alerts linking to Sensors or System).

---

## 3. Dependency Container & Service Boundary

All feature ViewModels and Repositories are registered in a lightweight, centralized dependency container:
`lib/app/dependency_container.dart`

```
   ┌───────────────────────┐
   │  DependencyContainer  │
   └───────────┬───────────┘
               │
  ┌────────────┼────────────┬────────────┐
  ▼            ▼            ▼            ▼
Dashboard    Camera      Sensors       System
ViewModel   ViewModel   ViewModel    ViewModel
    │           │           │            │
    ▼           ▼           ▼            ▼
Dashboard    Camera      Sensors       System
Repository  Repository  Repository   Repository
    │           │           │            │
    └───────────┴─────┬─────┴────────────┘
                      ▼
              Demo Data Sources
         (Figma & Simulated Telemetry)
                      ▼
         [Future Hardware Boundary]
       (ESP32 / BLE / Wi-Fi / Sockets)
```

This guarantees:
1. Pure unidirectional dependencies: UI → ViewModel → Repository → Data Source.
2. Single-source-of-truth state across views.
3. Completely deterministic demo data for headless tests and verification.
4. Clean insertion points for physical ESP32 services without modifying UI widgets.

---

## 4. Design System Tokens Enforced

All nine pages strictly adhere to the project's eight approved tokens:

| Token | Hex | Role |
| :--- | :--- | :--- |
| `AppColors.burgundy` | `#7A0D26` | Rover session banner, critical alert tags |
| `AppColors.gold` | `#D1A037` | DEMO MODE badge, active tab indicator, telemetry accents |
| `AppColors.white` | `#F6F6F6` | Primary high-contrast labels, primary measurement digits |
| `AppColors.black` | `#000000` | Camera viewport interior, badge contrast text |
| `AppColors.background` | `#101014` | Global viewport background |
| `AppColors.surface` | `#19191F` | Telemetry cards, configuration panels |
| `AppColors.surfaceRaised` | `#25252D` | 1px card borders, dividers, chip outlines |
| `AppColors.secondaryText` | `#C8C6C7` | Metric units, captions, secondary labels |

No gradients, glassmorphism, or unauthorized accent colors are used anywhere in the codebase.

