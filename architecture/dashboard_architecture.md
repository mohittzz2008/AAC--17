# ROVER COMMAND — Dashboard Architecture Design (Finalized)

## 1. System Overview & Architectural Rationale

ROVER COMMAND is an industrial inspection and telemetry monitoring application designed for high reliability, deterministic telemetry states, and clear operational boundaries.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        SHARED APPLICATION SHELL                        │
│   (Persistent App Bar, Navigation Bar / Nav Rail, Active Screen Host)  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                         ┌──────────┴──────────┐
                         │   ACTIVE FEATURE    │
                         │   (e.g. Dashboard)  │
                         └──────────┬──────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER (MVVM)                       │
│                                                                        │
│   DashboardView ◄─── ListenableBuilder ◄─── DashboardViewModel         │
│   (Stateless Presentation Widgets)           (ChangeNotifier)          │
│   - Header & Demo Mode Badge                 - Exposes Immutable State │
│   - Rover Status Banner                      - Coordinates Refresh     │
│   - Hardware Overview Grid                   - Safe Lifecycle/Disposal │
│   - Camera Preview Card                                                │
│   - Distance Sensors Cluster                                           │
│   - Motion Sensors Cluster                                             │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                              DOMAIN LAYER                              │
│                                                                        │
│   DashboardRepository (Interface Contract)                             │
│   Immutable Domain Entities:                                           │
│   - RoverSessionStatus                                                 │
│   - HardwareInventoryItem                                              │
│   - CameraPreviewTelemetry                                             │
│   - DistanceSensorTelemetry                                            │
│   - MotionSensorTelemetry                                              │
│   Orthogonal Telemetry Enums:                                          │
│   - DataSourceType (demoSimulated / hardwareLive)                      │
│   - HardwareVerificationStatus (verified / notVerified)                │
│   - ConnectionStatus (connected / disconnected / connecting)           │
│   - MeasurementValidity (valid / unavailable / error)                  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                               DATA LAYER                               │
│                                                                        │
│   DashboardRepositoryImpl                                              │
│   ├── DemoDashboardDataSource (Figma Ground Truth Implementation)      │
│   └── [Future] Esp32HardwareDataSource (Hardware Boundary Interface)   │
└────────────────────────────────────────────────────────────────────────┘
```

### Architectural Decisions & Justifications
1. **Feature-First + MVVM**: Organizes business domains into autonomous feature modules while centralizing cross-cutting concerns (Shell, Theme, Responsive Layout).
2. **Single ViewModel for Dashboard**: One `DashboardViewModel` manages the aggregate state for the screen. Individual cards (`HardwareCard`, `DistanceSensorCard`, `CameraPreviewCard`) are pure presentation widgets that consume strongly-typed sub-models. They do not maintain independent ViewModels.
3. **ChangeNotifier + ListenableBuilder**: Leverages standard Flutter foundational primitives with zero third-party dependencies. Provides reactive, fine-grained UI rebuilds with predictable garbage collection and lifecycle management.
4. **Shared Shell Navigation**: Navigation (`Dashboard`, `Camera`, `Sensors`, `System`) belongs to the application shell (`RoverShell`), ensuring persistent routing and view preservation independent of the Dashboard feature.
5. **Separation of Demo and Live Hardware**: Data sources are strictly isolated behind the `DashboardDataSource` interface. The UI cannot access device hardware, sockets, or transport drivers directly.

---

## 2. Mandatory Design System & Exact Color Tokens

The UI strictly adheres to the approved 8-color ROVER COMMAND palette. No extra accents (such as random greens, pinks, or blues) are permitted.

### The 8 Approved Colors
| Token Identifier | Hex Code | Visual Application |
| :--- | :--- | :--- |
| `AppColors.burgundy` | `#7A0D26` | Rover session status alert banner background |
| `AppColors.gold` | `#D1A037` | `DEMO MODE` badge, active navigation state, telemetry accents |
| `AppColors.white` | `#F6F6F6` | Primary high-contrast text, primary measurement numbers |
| `AppColors.black` | `#000000` | Camera viewport interior, `DEMO MODE` badge text contrast |
| `AppColors.background` | `#101014` | Global viewport background (deep industrial dark) |
| `AppColors.surface` | `#19191F` | Dashboard telemetry cards, camera preview shell |
| `AppColors.surfaceRaised` | `#25252D` | 1px card borders, navigation container background/outlines |
| `AppColors.textSecondary` | `#C8C6C7` | Metric labels, units, subheaders, unverified badge text |

### Typography
- **Interface Font Family**: `Inter` (Labels, captions, button text, headers, and UI controls).
- **Telemetry & Technical Font Family**: `JetBrains Mono` (Sensor values, units, hardware counts, and status codes).
- **Fallback Strategy**: Standard platform fallbacks (`sans-serif` and `monospace`) ensure offline zero-dependency compilation.

---

## 3. Final Project Folder Structure

```
lib/
├── main.dart                                # Application bootstrap & dependency injection
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                 # Strict 8-color project palette
│   │   └── app_typography.dart              # Inter & JetBrains Mono text styles
│   ├── theme/
│   │   └── app_theme.dart                   # Material 3 industrial dark theme
│   └── responsive/
│       ├── responsive_layout.dart           # Adaptive layout builder (Mobile, Tablet, Desktop)
│       └── screen_breakpoints.dart          # Breakpoint thresholds (600dp, 1024dp)
├── shared/
│   ├── domain/
│   │   └── enums/
│   │       ├── data_source_type.dart        # demoSimulated | hardwareLive
│   │       ├── verification_status.dart     # verified | notVerified
│   │       ├── connection_status.dart       # connected | disconnected | connecting
│   │       └── measurement_validity.dart    # valid | unavailable | error
│   ├── presentation/
│   │   ├── shell/
│   │   │   ├── rover_shell.dart             # Application shell (AppBar, Navigation host)
│   │   │   └── shell_destination.dart       # Enum: dashboard, camera, sensors, system
│   │   └── widgets/
│   │       ├── demo_mode_badge.dart         # Gold '#D1A037' capsule badge
│   │       ├── rover_card.dart              # Base '#19191F' container with '#25252D' border
│   │       ├── rover_status_tag.dart        # Standardized verification/source pill
│   │       └── rover_navigation_bar.dart    # Adaptive floating bar (mobile) / rail (desktop)
└── features/
    ├── dashboard/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── dashboard_data_source.dart        # Abstract data source contract
    │   │   │   └── demo_dashboard_data_source.dart   # Deterministic Figma demo data
    │   │   └── repositories/
    │   │       └── dashboard_repository_impl.dart    # Repository implementation
    │   ├── domain/
    │   │   ├── models/
    │   │   │   ├── rover_session_status.dart         # Status banner entity
    │   │   │   ├── hardware_inventory_item.dart      # Battery, Controller, Camera, HW item
    │   │   │   ├── camera_preview_telemetry.dart     # ESP32-CAM preview entity
    │   │   │   ├── distance_sensor_telemetry.dart    # HC-SR04 telemetry entity
    │   │   │   ├── motion_sensor_telemetry.dart      # RCWL-0516 telemetry entity
    │   │   │   └── dashboard_telemetry_bundle.dart   # Aggregated immutable domain bundle
    │   │   └── repositories/
    │   │       └── dashboard_repository.dart         # Repository contract
    │   └── presentation/
    │       ├── state/
    │       │   └── dashboard_state.dart              # Immutable UI state (Initial, Loading, Loaded, Error)
    │       ├── viewmodels/
    │       │   └── dashboard_viewmodel.dart          # Single ChangeNotifier ViewModel
    │       ├── views/
    │       │   └── dashboard_view.dart               # Responsive Dashboard view
    │       └── widgets/
    │           ├── dashboard_header.dart             # Title, Subtitle & Demo Mode Badge
    │           ├── rover_status_banner.dart          # Burgundy '#7A0D26' alert card
    │           ├── hardware_overview_grid.dart       # 2x2 grid of hardware items
    │           ├── camera_preview_card.dart          # Viewport shell with unverified state
    │           ├── distance_sensors_cluster.dart     # Dual HC-SR04 telemetry cards
    │           └── motion_sensors_cluster.dart       # Dual RCWL-0516 telemetry cards
    ├── camera/                                       # Screen 2 (Future)
    ├── sensors/                                      # Screen 3 (Future)
    └── system/                                       # Screen 4 (Future)
```

---

## 4. Domain Model Definitions & Telemetry Enums

Telemetry dimensions are strictly separated into orthogonal types rather than combined into arbitrary status strings.

### Orthogonal Enums (`lib/shared/domain/enums/`)

```dart
/// Identifies where the data originates.
enum DataSourceType {
  demoSimulated('SIMULATED'),
  hardwareLive('LIVE');

  final String displayLabel;
  const DataSourceType(this.displayLabel);
}

/// Identifies whether the hardware entity has been physically verified.
enum HardwareVerificationStatus {
  verified('VERIFIED'),
  notVerified('NOT VERIFIED');

  final String displayLabel;
  const HardwareVerificationStatus(this.displayLabel);
}

/// Identifies transport-level connection state.
enum ConnectionStatus {
  connected('CONNECTED'),
  connecting('CONNECTING'),
  disconnected('NOT CONNECTED');

  final String displayLabel;
  const ConnectionStatus(this.displayLabel);
}

/// Identifies whether the measurement itself is readable and calibrated.
enum MeasurementValidity {
  valid,
  unavailable,
  error;
}
```

### Dashboard Domain Entities (`lib/features/dashboard/domain/models/`)

#### 1. `RoverSessionStatus` (Session Banner)
```dart
class RoverSessionStatus {
  final String roverId;                          // "ROVER-01"
  final String sessionDescription;               // "Simulated data only · No live connection"
  final DataSourceType dataSourceType;           // DataSourceType.demoSimulated
  final HardwareVerificationStatus verification; // HardwareVerificationStatus.notVerified
  final ConnectionStatus connection;             // ConnectionStatus.disconnected

  const RoverSessionStatus({
    required this.roverId,
    required this.sessionDescription,
    this.dataSourceType = DataSourceType.demoSimulated,
    this.verification = HardwareVerificationStatus.notVerified,
    this.connection = ConnectionStatus.disconnected,
  });
}
```

#### 2. `HardwareInventoryItem` (2×2 Hardware Cards)
```dart
class HardwareInventoryItem {
  final String categoryKey;                      // "BATTERY", "CONTROLLER", "CAMERA", "HARDWARE"
  final String specification;                    // "12V Li-ion", "2 × ESP32 DevKit", "ESP32-CAM", "Assembly pending"
  final HardwareVerificationStatus verification; // HardwareVerificationStatus.notVerified
  final DataSourceType dataSourceType;           // DataSourceType.demoSimulated

  const HardwareInventoryItem({
    required this.categoryKey,
    required this.specification,
    this.verification = HardwareVerificationStatus.notVerified,
    this.dataSourceType = DataSourceType.demoSimulated,
  });
}
```

#### 3. `CameraPreviewTelemetry` (Camera Card)
```dart
class CameraPreviewTelemetry {
  final String moduleTitle;                      // "ESP32-CAM preview"
  final String statusHeadline;                   // "NO VIDEO FEED / NOT CONNECTED"
  final String streamDisclaimer;                 // "Placeholder · Streaming unverified"
  final ConnectionStatus connection;             // ConnectionStatus.disconnected
  final HardwareVerificationStatus verification; // HardwareVerificationStatus.notVerified
  final DataSourceType dataSourceType;           // DataSourceType.demoSimulated

  const CameraPreviewTelemetry({
    this.moduleTitle = 'ESP32-CAM preview',
    this.statusHeadline = 'NO VIDEO FEED / NOT CONNECTED',
    this.streamDisclaimer = 'Placeholder · Streaming unverified',
    this.connection = ConnectionStatus.disconnected,
    this.verification = HardwareVerificationStatus.notVerified,
    this.dataSourceType = DataSourceType.demoSimulated,
  });
}
```

#### 4. `DistanceSensorTelemetry` (HC-SR04)
```dart
class DistanceSensorTelemetry {
  final String sensorId;                         // "01", "02"
  final String hardwareModel;                    // "HC-SR04"
  final int? distanceCm;                         // 124, 86 (null if unavailable)
  final MeasurementValidity validity;            // MeasurementValidity.valid
  final HardwareVerificationStatus verification; // HardwareVerificationStatus.notVerified
  final DataSourceType dataSourceType;           // DataSourceType.demoSimulated

  const DistanceSensorTelemetry({
    required this.sensorId,
    this.hardwareModel = 'HC-SR04',
    this.distanceCm,
    this.validity = MeasurementValidity.valid,
    this.verification = HardwareVerificationStatus.notVerified,
    this.dataSourceType = DataSourceType.demoSimulated,
  });

  String get formattedValue => validity == MeasurementValidity.valid && distanceCm != null
      ? '$distanceCm'
      : '--';
}
```

#### 5. `MotionSensorTelemetry` (RCWL-0516)
```dart
enum MotionState {
  clear('CLEAR'),
  motion('MOTION'),
  unknown('UNKNOWN');

  final String label;
  const MotionState(this.label);
}

class MotionSensorTelemetry {
  final String sensorId;                         // "01", "02"
  final String hardwareModel;                    // "RCWL-0516"
  final MotionState state;                       // MotionState.clear, MotionState.motion
  final MeasurementValidity validity;            // MeasurementValidity.valid
  final HardwareVerificationStatus verification; // HardwareVerificationStatus.notVerified
  final DataSourceType dataSourceType;           // DataSourceType.demoSimulated

  const MotionSensorTelemetry({
    required this.sensorId,
    this.hardwareModel = 'RCWL-0516',
    required this.state,
    this.validity = MeasurementValidity.valid,
    this.verification = HardwareVerificationStatus.notVerified,
    this.dataSourceType = DataSourceType.demoSimulated,
  });
}
```

#### 6. `DashboardTelemetryBundle` (Aggregated Screen Snapshot)
```dart
class DashboardTelemetryBundle {
  final RoverSessionStatus session;
  final List<HardwareInventoryItem> hardwareOverview;
  final CameraPreviewTelemetry cameraPreview;
  final List<DistanceSensorTelemetry> distanceSensors;
  final List<MotionSensorTelemetry> motionSensors;
  final DateTime timestamp;

  const DashboardTelemetryBundle({
    required this.session,
    required this.hardwareOverview,
    required this.cameraPreview,
    required this.distanceSensors,
    required this.motionSensors,
    required this.timestamp,
  });
}
```

---

## 5. Presentation Layer State & ViewModel

### Immutable UI State (`lib/features/dashboard/presentation/state/dashboard_state.dart`)
```dart
sealed class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardTelemetryBundle data;
  final bool isDemoMode;
  final DateTime lastUpdated;

  const DashboardLoaded({
    required this.data,
    this.isDemoMode = true,
    required this.lastUpdated,
  });
}

class DashboardError extends DashboardState {
  final String userMessage;
  const DashboardError(this.userMessage);
}
```

### DashboardViewModel Responsibilities (`lib/features/dashboard/presentation/viewmodels/`)
- Extends Flutter's built-in `ChangeNotifier`.
- **Single ViewModel Scope**: Orchestrates state for the entire Dashboard screen; cards remain lightweight, reusable, and stateless.
- Exposes:
  - `DashboardState get state => _state;`
  - `Future<void> initialize();`
  - `Future<void> refresh();`
- **Safe Disposal**: Cancels any active timers or stream subscriptions before calling `super.dispose()` to prevent memory leaks.

---

## 6. Contracts: Repository & Data Source

### `DashboardRepository` Contract
```dart
abstract interface class DashboardRepository {
  Future<DashboardTelemetryBundle> getTelemetrySnapshot();
  Stream<DashboardTelemetryBundle> streamTelemetry();
}
```

### `DashboardDataSource` Contract
```dart
abstract interface class DashboardDataSource {
  Future<DashboardTelemetryBundle> fetchTelemetry();
  Stream<DashboardTelemetryBundle> telemetryStream();
}
```

### `DemoDashboardDataSource` Ground Truth
Implements `DashboardDataSource` using the exact values from `design_reference/01_dashboard.png`:
- `RoverSessionStatus`: `"ROVER-01"`, `"Simulated data only · No live connection"`, `notVerified`, `demoSimulated`
- `HardwareInventory`:
  - `BATTERY`: `"12V Li-ion"`
  - `CONTROLLER`: `"2 × ESP32 DevKit"`
  - `CAMERA`: `"ESP32-CAM"`
  - `HARDWARE`: `"Assembly pending"`
- `CameraPreview`: `"ESP32-CAM preview"`, `"NO VIDEO FEED / NOT CONNECTED"`, `"Placeholder · Streaming unverified"`
- `DistanceSensors`:
  - Sensor `01`: `124 cm`, `SIMULATED`, `NOT VERIFIED`
  - Sensor `02`: `86 cm`, `SIMULATED`, `NOT VERIFIED`
- `MotionSensors`:
  - Sensor `01`: `CLEAR`, `SIMULATED`, `NOT VERIFIED`
  - Sensor `02`: `MOTION`, `SIMULATED`, `NOT VERIFIED`

### Future Hardware Integration Boundary
- When real hardware is deployed, a new `Esp32HardwareDataSource` will implement `DashboardDataSource`.
- It will communicate over verified transport (e.g. WebSocket, Serial, or REST) to the dual ESP32s and ESP32-CAM.
- It will convert raw packet payloads into the exact same `DashboardTelemetryBundle` domain models, seamlessly toggling `dataSourceType` to `hardwareLive` and `connection` to `connected`.
- The ViewModel and all UI widgets will remain 100% untouched.

---

## 7. Shared Application Navigation Architecture

Navigation is decoupled from the Dashboard feature and managed by a shared application shell (`RoverShell`):

```
                        ┌──────────────────┐
                        │    RoverShell    │
                        └────────┬─────────┘
                                 │
           ┌─────────────────────┼─────────────────────┐
           │                     │                     │
           ▼                     ▼                     ▼
┌────────────────────┐ ┌────────────────────┐ ┌────────────────────┐
│   Mobile Layout    │ │   Tablet Layout    │ │   Desktop Layout   │
│  (Bottom Nav Bar)  │ │ (Centered Content) │ │  (Navigation Rail) │
└──────────┬─────────┘ └─────────┬──────────┘ └──────────┬─────────┘
           │                     │                       │
           └─────────────────────┼───────────────────────┘
                                 │
                                 ▼
                    [ Active Screen Switcher ]
             Index 0: DashboardView (Current)
             Index 1: CameraView (Future)
             Index 2: SensorsView (Future)
             Index 3: SystemView (Future)
```

### Destinations (`lib/shared/presentation/shell/shell_destination.dart`)
1. **Dashboard** (`Icons.home_outlined`) — Telemetry overview & preview
2. **Camera** (`Icons.videocam_outlined`) — Dedicated video stream & controls
3. **Sensors** (`Icons.show_chart`) — In-depth sensor gauges & system health
4. **System** (`Icons.settings_outlined`) — Power distribution & controller inventory

---

## 8. Responsive Layout Strategy

Responsive decisions are evaluated based on **available window width constraints** rather than hardcoded device assumptions.

| Window Width | Category | Viewport Strategy | Navigation Shell |
| :--- | :--- | :--- | :--- |
| `< 600 dp` | **Mobile** | Exact Figma single-column scrollable layout (`390 dp` design baseline). All paired cards render in 2 columns. | Floating rounded bottom capsule (`#19191F`, border `#25252D`, 20 dp radius) docked above bottom safe area. |
| `600 dp – 1024 dp` | **Tablet** | Centered dashboard container (`max-width: 720 dp`). Telemetry clusters expand horizontally. | Centered floating bottom navigation bar or top application bar. |
| `> 1024 dp` | **Desktop / Laptop** | Workstation multi-column layout (`max-width: 1200 dp`):<br>• **Left Column (30%)**: Session Status + 2×2 Hardware Cards<br>• **Center Column (45%)**: Prominent Camera Viewport<br>• **Right Column (25%)**: Distance & Motion Sensor Telemetry Stack | Left-docked industrial Navigation Rail (`#19191F`, border `#25252D`), maintaining full vertical space. |

---

## 9. Comprehensive Testing Plan

```
test/
├── unit/
│   ├── domain/
│   │   ├── distance_sensor_telemetry_test.dart
│   │   ├── motion_sensor_telemetry_test.dart
│   │   └── dashboard_telemetry_bundle_test.dart
│   ├── data/
│   │   └── demo_dashboard_data_source_test.dart
│   └── presentation/
│       └── dashboard_viewmodel_test.dart
├── widget/
│   ├── shared/
│   │   ├── demo_mode_badge_test.dart
│   │   ├── rover_card_test.dart
│   │   └── rover_navigation_bar_test.dart
│   └── dashboard/
│       ├── dashboard_header_test.dart
│       ├── rover_status_banner_test.dart
│       ├── hardware_overview_grid_test.dart
│       ├── camera_preview_card_test.dart
│       ├── distance_sensors_cluster_test.dart
│       └── motion_sensors_cluster_test.dart
└── responsive/
    ├── dashboard_mobile_layout_test.dart
    ├── dashboard_tablet_layout_test.dart
    └── dashboard_desktop_layout_test.dart
```

### Verification Criteria
1. **Unit Tests**:
   - Verify `DemoDashboardDataSource` returns non-null items with `HardwareVerificationStatus.notVerified` and `DataSourceType.demoSimulated`.
   - Verify `DashboardViewModel` transitions through `DashboardInitial` -> `DashboardLoading` -> `DashboardLoaded`.
2. **Widget Tests**:
   - Verify exact strings from `01_dashboard.png`: `ROVER COMMAND`, `DEMO MODE`, `ROVER-01`, `12V Li-ion`, `2 × ESP32 DevKit`, `ESP32-CAM`, `Assembly pending`, `124 cm`, `86 cm`, `CLEAR`, `MOTION`.
   - Verify only the approved 8 palette colors are utilized.
3. **Responsive Tests**:
   - Confirm layout constraints adapt properly across widths `390 dp`, `768 dp`, and `1280 dp` without RenderFlex overflow.

---

## 10. Phased Implementation Sequence

```
┌────────────────────────────────────────────────────────┐
│ Phase 1: Core Design System Tokens                     │
│ - Strict 8-color constants in app_colors.dart          │
│ - Typography text styles in app_typography.dart        │
│ - Aligned ThemeData in app_theme.dart                  │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ Phase 2: Domain Layer & Orthogonal Enums               │
│ - DataSourceType, HardwareVerificationStatus, etc.     │
│ - Domain entities & DashboardTelemetryBundle           │
│ - DashboardRepository contract                         │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ Phase 3: Data Layer & Ground Truth Demo Source         │
│ - DashboardDataSource contract                         │
│ - DemoDashboardDataSource (Figma verified values)      │
│ - DashboardRepositoryImpl                              │
│ - Unit tests for data layer                            │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ Phase 4: State Management & ViewModel                  │
│ - DashboardState sealed class                          │
│ - DashboardViewModel (ChangeNotifier)                  │
│ - ViewModel unit tests                                 │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ Phase 5: Shared Application Shell & Navigation         │
│ - RoverShell (Mobile bottom bar + Desktop nav rail)    │
│ - Shared widgets: DemoModeBadge, RoverCard, StatusTag  │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ Phase 6: Dashboard Presentation Widgets                │
│ - DashboardHeader, RoverStatusBanner                   │
│ - HardwareOverviewGrid, CameraPreviewCard              │
│ - DistanceSensorsCluster, MotionSensorsCluster         │
│ - ResponsiveDashboardView integration                  │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ Phase 7: Quality Gate & Final Verification             │
│ - Complete unit, widget, and responsive test suite     │
│ - flutter analyze (0 warnings/errors)                  │
│ - flutter test (100% pass)                             │
│ - flutter build web --release                          │
└────────────────────────────────────────────────────────┘
```
