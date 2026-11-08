# ROVER COMMAND — Complete Project Structure & File Analysis

**Document ID**: `AUDIT-02-STRUCTURE-ANALYSIS`  
**Classification**: Codebase Topology & Component Inventory  
**Project**: ROVER COMMAND  
**Root Workspace**: `D:\projects\AAC FLUTTER`  

---

## 1. Complete Directory Tree

```
D:\projects\AAC FLUTTER
├── .dart_tool/                  # Dart build cache & package config
├── .idea/                       # IDE metadata
├── android/                     # Android native runner
│   ├── app/
│   │   ├── build.gradle         # Android app build configuration
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/com/example/rover_command/
│   │           └── MainActivity.kt
│   └── build.gradle             # Top-level Gradle configuration
├── architecture/                # System documentation & technical contracts
│   ├── technical_audit/         # Comprehensive Master Audit Documentation (Current Suite)
│   ├── complete_application_architecture.md
│   ├── complete_application_audit.md
│   ├── dashboard_architecture.md
│   ├── data_contracts.md
│   ├── hardware_integration_requirements.md
│   └── implementation_report.md
├── build/                       # Compilation outputs
│   └── web/                     # Production Web SPA bundle (HTML, CanvasKit, JS, Wasm)
├── design_reference/            # Figma exports & hardware circuit schematics
│   └── hardware_circuit.jpeg    # Physical hardware circuit diagram
├── lib/                         # Application Source Code
│   ├── main.dart                # Application entry point
│   ├── app/
│   │   └── dependency_container.dart # Pure Dart DI service locator / singleton manager
│   ├── core/                    # Cross-cutting foundational infrastructure
│   │   ├── responsive/
│   │   │   └── screen_breakpoints.dart # Device breakpoint tokens
│   │   ├── theme/
│   │   │   ├── app_colors.dart         # Approved industrial color palette
│   │   │   ├── app_radius.dart         # Border radius constants
│   │   │   ├── app_spacing.dart        # Padding and spacing scale
│   │   │   ├── app_theme.dart          # Dark theme Material 3 definition
│   │   │   ├── app_typography.dart     # Inter & JetBrains Mono font styles
│   │   │   ├── camera_colors.dart      # Camera viewport HUD color tokens
│   │   │   └── control_colors.dart     # Directional pad & action button tokens
│   │   └── zoom/
│   │       ├── application_zoom_controller.dart # Centralized matrix scale engine
│   │       ├── application_zoom_wrapper.dart    # GPU transform wrapper + HUD pill
│   │       ├── web_zoom_bridge.dart             # Conditional export bridge
│   │       ├── web_zoom_bridge_stub.dart        # Non-web VM testing stub
│   │       ├── web_zoom_bridge_web.dart         # dart:js_interop DOM listener bridge
│   │       └── zoom_aware_scroll_behavior.dart  # Scroll physics modifier key filter
│   ├── features/                # Domain-Driven Feature Modules (Clean Architecture)
│   │   ├── activity_logs/       # System event history & audit trail
│   │   ├── camera/              # ESP32-CAM stream viewer & feed diagnostics
│   │   ├── configuration/       # Network, sensor, and rover calibration settings
│   │   ├── dashboard/           # High-level inspection overview & sensor telemetry
│   │   ├── device_connection/   # Device discovery, pairing, and transport management
│   │   ├── diagnostics/         # Subsystem health tree & active fault issues
│   │   ├── firmware/            # Device firmware versioning & OTA update records
│   │   ├── rover_operation/     # Remote rover operation, D-pad, and Emergency Stop
│   │   ├── sensors/             # Detailed ultrasonic & microwave radar telemetry
│   │   └── system/              # System overview, hardware inventory, sub-routing
│   └── shared/                  # Reusable cross-feature components & domain enums
│       ├── domain/enums/        # Shared strongly-typed domain enumerations
│       │   ├── connection_status.dart
│       │   ├── data_source_type.dart
│       │   ├── hardware_verification_status.dart
│       │   ├── log_category.dart
│       │   ├── log_severity.dart
│       │   ├── measurement_validity.dart
│       │   └── subsystem_health_status.dart
│       └── presentation/
│           ├── shell/           # Root navigation shell & layout switcher
│           │   ├── destination_placeholder.dart
│           │   ├── rover_shell.dart
│           │   ├── shell_destination.dart
│           │   └── system_sub_destination.dart
│           └── widgets/         # Shared industrial UI widgets
│               ├── app_page_header.dart
│               ├── custom_telemetry_chart.dart
│               ├── rover_bottom_navigation_bar.dart
│               ├── rover_navigation_rail.dart
│               └── status_badge.dart
├── reports/                     # Automated browser verification reports & screenshots
├── scratch/                     # Automation scripts & verification harnesses
├── screenshots/                 # Multi-device regression screenshots (Desktop/Mobile)
├── test/                        # Automated unit and widget test suite
│   ├── unit/                    # Logic and state tests
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── widget/                  # UI and interaction tests
│   │   ├── dashboard/
│   │   ├── rover_operation/
│   │   ├── shell/
│   │   └── zoom/
│   └── widget_test.dart
├── web/                         # Flutter Web assets & bootstrap host
│   ├── favicon.png
│   ├── flutter_bootstrap.js
│   ├── index.html               # Web host HTML with non-passive zoom listeners
│   └── manifest.json            # PWA manifest
├── analysis_options.yaml        # Static analyzer configuration
├── pubspec.yaml                 # Project manifest & dependency configuration
└── pubspec.lock                 # Locked dependency version resolution
```

---

## 2. In-Depth File-by-File Analysis

### 2.1 Application Entry & Dependency Wiring

#### `lib/main.dart`
* **File Path**: `D:\projects\AAC FLUTTER\lib\main.dart`
* **Purpose**: Serves as the Dart execution entry point. Bootstraps the Flutter widget tree and configures root-level theme, title, and scroll physics.
* **Technologies Used**: Dart, Flutter Material.
* **Important Classes & Functions**:
  * `main()`: Calls `runApp(const RoverCommandApp())`.
  * `RoverCommandApp`: Root `StatelessWidget` returning `MaterialApp`. Sets `theme: AppTheme.darkTheme`, `scrollBehavior: const ZoomAwareScrollBehavior()`, and `home: const RoverShell()`.
* **Dependencies**: Depends on `core/theme/app_theme.dart`, `core/zoom/zoom_aware_scroll_behavior.dart`, `shared/presentation/shell/rover_shell.dart`.
* **Status**: **Actively used** (Core Root).

#### `lib/app/dependency_container.dart`
* **File Path**: `D:\projects\AAC FLUTTER\lib\app\dependency_container.dart`
* **Purpose**: Pure Dart service locator and dependency injection container. Instantiates and retains singletons for all 10 repositories and 10 ViewModels.
* **Technologies Used**: Dart OOP, Singleton pattern, Factory constructor.
* **Important Classes & Functions**:
  * `DependencyContainer`: Singleton class with private constructor `DependencyContainer._internal()`.
  * `_initRepositories()`: Injects demo data sources into repository implementations.
  * `_initViewModels()`: Injects repositories into ViewModels.
  * `dispose()`: Cleanly tears down all 10 ViewModels during application shutdown.
* **Dependent Files**: Consumed by `lib/shared/presentation/shell/rover_shell.dart`, unit test files.
* **Status**: **Actively used** (Core DI Engine).

---

### 2.2 Core Infrastructure & Theme

#### `lib/core/theme/app_colors.dart`
* **File Path**: `D:\projects\AAC FLUTTER\lib\core\theme\app_colors.dart`
* **Purpose**: Single source of truth for the 8-color approved industrial palette.
* **Key Color Tokens**:
  * `AppColors.burgundy` (`#7A0D26`): Alert/session banners, prominent cards.
  * `AppColors.gold` (`#D1A037`): Primary accent, active navigation, status indicators.
  * `AppColors.white` (`#F6F6F6`): High-contrast primary text.
  * `AppColors.black` (`#000000`): Dark viewport background.
  * `AppColors.background` (`#101014`): Deep obsidian application canvas background.
  * `AppColors.surface` (`#19191F`): Primary card and panel surface.
  * `AppColors.surfaceRaised` (`#25252D`): Elevated borders, dividers, raised elements.
  * `AppColors.textSecondary` (`#C6C6C7`): Secondary labels, timestamps, metadata.
* **Status**: **Actively used**.

#### `lib/core/theme/app_typography.dart`
* **File Path**: `D:\projects\AAC FLUTTER\lib\core\theme\app_typography.dart`
* **Purpose**: Defines standardized typography tokens using `Inter` for interface elements and `JetBrains Mono` for telemetry numbers and timestamps.
* **Status**: **Actively used**.

#### `lib/core/responsive/screen_breakpoints.dart`
* **File Path**: `D:\projects\AAC FLUTTER\lib\core\responsive\screen_breakpoints.dart`
* **Purpose**: Enforces responsive width boundaries:
  * `mobileMax = 600.0`
  * `tabletMax = 1024.0`
* **Status**: **Actively used**.

---

### 2.3 Zoom & Matrix Engine Files

#### `lib/core/zoom/application_zoom_controller.dart`
* **File Path**: `D:\projects\AAC FLUTTER\lib\core\zoom\application_zoom_controller.dart`
* **Purpose**: Centralized zoom state engine managing $4 \times 4$ transformation matrices, critically damped ticker interpolation, exponential scroll scaling, and cursor focal point anchoring.
* **Technologies Used**: Dart, `package:vector_math/vector_math_64.dart`, Flutter `TickerProvider`.
* **Important Methods**:
  * `initialize(TickerProvider)`: Starts frame ticker.
  * `zoomIn()`, `zoomOut()`, `resetZoom()`: Discrete 10% steps.
  * `zoomByWheel(Offset focalPoint, double deltaY)`: Exponential continuous zoom anchored to cursor.
  * `zoomByGesture(Offset focalPoint, double scaleFactor)`: Touchpad / pinch zoom.
  * `transformMatrix`: Computes `Matrix4.identity()..translateByDouble()..scaleByDouble()`.
* **Status**: **Actively used** (Core Zoom Model).

#### `lib/core/zoom/application_zoom_wrapper.dart`
* **File Path**: `D:\projects\AAC FLUTTER\lib\core\zoom\application_zoom_wrapper.dart`
* **Purpose**: Presentation wrapper applying matrix transformation to workspace content via GPU layer while overlaying a floating zoom HUD pill (`-`, `percentage`, `+`, `reset`).
* **Status**: **Actively used**.

#### `lib/core/zoom/web_zoom_bridge_web.dart` & `web_zoom_bridge_stub.dart`
* **File Path**: `D:\projects\AAC FLUTTER\lib\core\zoom/web_zoom_bridge_web.dart`
* **Purpose**: Bridges browser DOM events (`_flutterOnWheelZoom`, `_flutterOnKeyboardZoom`) into Dart via `dart:js_interop`. The stub allows running unit tests on the standard Dart VM without compilation errors.
* **Status**: **Actively used**.

#### `lib/core/zoom/zoom_aware_scroll_behavior.dart`
* **File Path**: `D:\projects\AAC FLUTTER\lib\core\zoom/zoom_aware_scroll_behavior.dart`
* **Purpose**: Custom `MaterialScrollBehavior` and `ScrollPhysics` preventing child scrollable widgets (ListViews, SingleChildScrollViews) from consuming wheel events when `Ctrl` or `Meta` is held down.
* **Status**: **Actively used**.

---

### 2.4 Feature Modules (Clean Architecture Breakdown)

Each feature adheres to an identical, decoupled three-tier Clean Architecture:

| Feature Directory | Primary Screen | ViewModel | Repository Contract & Implementation | Data Source Contract & Implementation |
| :--- | :--- | :--- | :--- | :--- |
| **`dashboard/`** | `DashboardScreen` | `DashboardViewModel` | `DashboardRepository` / `DashboardRepositoryImpl` | `DashboardDataSource` / `DemoDashboardDataSource` |
| **`camera/`** | `CameraScreen` | `CameraViewModel` | `CameraRepository` / `CameraRepositoryImpl` | `CameraDataSource` / `DemoCameraDataSource` |
| **`sensors/`** | `SensorsScreen` | `SensorsViewModel` | `SensorsRepository` / `SensorsRepositoryImpl` | `SensorsDataSource` / `DemoSensorsDataSource` |
| **`rover_operation/`**| `RoverOperationScreen` | `RoverOperationViewModel` | `RoverOperationRepository` / `RoverOperationRepositoryImpl` | `RoverOperationDataSource` / `DemoRoverOperationDataSource` |
| **`system/`** | `SystemScreen` | `SystemViewModel` | `SystemRepository` / `SystemRepositoryImpl` | `SystemDataSource` / `DemoSystemDataSource` |
| **`device_connection/`**| `DeviceConnectionScreen` | `DeviceConnectionViewModel`| `DeviceConnectionRepository` / `DeviceConnectionRepositoryImpl`| `DeviceConnectionDataSource` / `DemoDeviceConnectionDataSource`|
| **`diagnostics/`** | `DiagnosticsScreen` | `DiagnosticsViewModel` | `DiagnosticsRepository` / `DiagnosticsRepositoryImpl` | `DiagnosticsDataSource` / `DemoDiagnosticsDataSource` |
| **`activity_logs/`**| `ActivityLogsScreen` | `ActivityLogsViewModel` | `ActivityLogsRepository` / `ActivityLogsRepositoryImpl` | `ActivityLogsDataSource` / `DemoActivityLogsDataSource` |
| **`configuration/`**| `ConfigurationScreen` | `ConfigurationViewModel`| `ConfigurationRepository` / `ConfigurationRepositoryImpl` | `ConfigurationDataSource` / `DemoConfigurationDataSource` |
| **`firmware/`** | `FirmwareScreen` | `FirmwareViewModel` | `FirmwareRepository` / `FirmwareRepositoryImpl` | `FirmwareDataSource` / `DemoFirmwareDataSource` |

---

### 2.5 Obsolete, Redundant, or Scratch Files

| File / Path | Nature | Recommendation |
| :--- | :--- | :--- |
| `hs_err_pid20476.log` | Root directory JVM crash dump (from an IDE or Gradle execution). | Safe to delete. |
| `scratch/capture_all_pages.py` | Standalone Python script used during earlier visual audit phases. | Historical testing utility. Retain in scratch. |
| `scratch/capture_revised_screenshots.py` | Standalone Python script used during Phase 6 visual refinement. | Historical testing utility. Retain in scratch. |
| `scratch/verify_real_browser_zoom.js` | Node.js CDP script executed during zoom verification. | Verification utility. Retain in scratch. |
| `scratch/run_browser_verification_harness.py` | Python HTTP test server harness for Chrome verification. | Verification utility. Retain in scratch. |

