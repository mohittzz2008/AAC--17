# ROVER COMMAND — Data Contracts & Domain Specifications

## 1. Domain Enums

### 1.1 `DataSourceType`
Distinguishes the source of telemetry:
* `demoSimulated`: Deterministic local sample telemetry conforming to Figma baseline designs.
* `hardwareLive`: Verified real-time telemetry originating from connected physical hardware.

### 1.2 `HardwareVerificationStatus`
Distinguishes verified physical hardware state from unverified/pending states:
* `verified`: Hardware verified and communicating.
* `notVerified`: Hardware assembly pending, bench-testing only, or unverified wiring.

### 1.3 `ConnectionStatus`
Tracks physical transport state:
* `disconnected`: No link established.
* `connecting`: Handshake or discovery in progress.
* `connected`: Active link established and streaming.

### 1.4 `MeasurementValidity`
Distinguishes valid sensor readings from sensor errors or hardware absence:
* `valid`: Value is within valid operational ranges.
* `unavailable`: Physical sensor is unmeasured, unpowered, or missing ADC channel.
* `error`: Hardware failure, sensor timeout, or out-of-bounds electrical reading.

### 1.5 `SubsystemHealthStatus`
Health state for individual subsystems in the diagnostics engine:
* `operational`: Healthy and operating within nominal parameters.
* `warning`: Degraded performance, assembly pending, or partial unverified status.
* `error`: Fault detected, communication failure, or hardware timeout.
* `unknown`: Telemetry not yet received or unverified.
* `unavailable`: Subsystem has no hardware monitoring sensor.

### 1.6 `LogSeverity`
* `info`: Informational events and normal state transitions.
* `warning`: Recoverable alerts, unverified data warnings, or degraded performance.
* `error`: Critical communication failures, integrity errors, or hardware timeouts.

### 1.7 `LogCategory`
* `application`: App initialization, UI navigation, and lifecycle events.
* `device`: Device connection, disconnection, and discovery events.
* `sensor`: Distance, motion, and telemetry sampling events.
* `camera`: Video feed and ESP32-CAM stream state events.
* `communication`: Network transport, socket, and framing events.
* `configuration`: Settings mutation and calibration changes.
* `firmware`: Firmware version check and maintenance logs.

---

## 2. Feature Domain Models

### 2.1 Dashboard (`DashboardTelemetryBundle`)
* `session`: `RoverSessionStatus` (rover ID, operational mode, verification tag, disclaimer).
* `hardwareOverview`: `List<HardwareInventoryItem>` (battery, controller, camera, hardware assembly status).
* `cameraPreview`: `CameraPreviewTelemetry` (preview module, connection state, stream disclaimer).
* `distanceSensors`: `List<DistanceSensorTelemetry>` (dual HC-SR04 readings with provenance).
* `motionSensors`: `List<MotionSensorTelemetry>` (dual RCWL-0516 motion states with provenance).

### 2.2 Camera (`CameraTelemetry`)
* `moduleTitle`: String (e.g. `ESP32-CAM`).
* `connectionStatus`: `ConnectionStatus`.
* `verification`: `HardwareVerificationStatus`.
* `resolution`: String? (e.g. `SVGA 800x600` when connected, null when disconnected).
* `frameRate`: double? (e.g. `15.0 fps` when active, null when disconnected).
* `lastUpdate`: DateTime?.
* `streamHealth`: String? (e.g. `Nominal`, `Unverified`, `Disconnected`).
* `disclaimer`: String.

### 2.3 Sensors (`SensorsTelemetryBundle`)
* `summary`: `SensorsSummary` (total: 4, available: 4, unverified: 4, issues: 0).
* `distanceSensors`: `List<DistanceSensorTelemetry>`.
* `motionSensors`: `List<MotionSensorTelemetry>`.
* `healthStatus`: `SensorHealthStatus` (checks pending, 0/4 verified, stream not verified).
* `recentHistory`: `List<SensorHistoryPoint>` (timestamped telemetry samples for deterministic visualization).

### 2.4 System (`SystemTelemetryBundle`)
* `overview`: `SystemOverview` (Rover ID: ROVER-01, Mode: Demo, Connection: Disconnected, Last Update: --).
* `inventory`: `List<HardwareInventoryItem>` (ESP32 DevKit ×2, ESP32-CAM ×1, DRV8833 ×2, 6V DC Motor ×3, MG90S Servo ×4, HC-SR04 ×2, RCWL-0516 ×2).
* `powerMetrics`: `PowerMetrics` (12V Li-ion battery, 2× 6V buck converters; battery voltage, charge, and buck outputs all strongly typed as `MeasurementValidity.unavailable`).
* `controllers`: `ControllersTelemetry` (2× ESP32 DevKit, 1× ESP32-CAM, status unverified).
* `driveHardware`: `DriveHardwareTelemetry` (DRV8833, DC motors, servos unverified).

### 2.5 Device Connection (`DeviceConnectionState`)
* `status`: `ConnectionStatus`.
* `activeDevice`: `DiscoveredDevice?`.
* `availableDevices`: `List<DiscoveredDevice>`.
* `registeredDevices`: `List<DiscoveredDevice>`.
* `connectionHistory`: `List<ConnectionHistoryEntry>`.
* `isDiscovering`: bool.

### 2.6 Diagnostics & Health (`DiagnosticsBundle`)
* `overallHealth`: `SubsystemHealthStatus`.
* `controllerHealth`: `SubsystemHealthStatus`.
* `cameraHealth`: `SubsystemHealthStatus`.
* `sensorHealth`: `SubsystemHealthStatus`.
* `communicationHealth`: `SubsystemHealthStatus`.
* `powerHealth`: `SubsystemHealthStatus`.
* `activeIssues`: `List<DiagnosticIssue>`.
* `recentIssues`: `List<DiagnosticIssue>`.
* `lastRunTime`: DateTime?.
* `isRunning`: bool.

### 2.7 Activity & Event Logs (`ActivityLogEntry`)
* `id`: String (UUID or monotonic ID).
* `timestamp`: DateTime.
* `category`: `LogCategory`.
* `severity`: `LogSeverity`.
* `message`: String.
* `details`: String?.
* `source`: String.

### 2.8 Configuration & Calibration (`RoverConfiguration`)
* `deviceName`: String (e.g. `ROVER-01`).
* `operatingMode`: String (`Demo Mode` or `Live Hardware`).
* `telemetryIntervalSeconds`: int (e.g. 5 seconds).
* `networkMode`: String (`Station (Wi-Fi)` or `Access Point (SoftAP)`).
* `ssid`: String.
* `password`: String (masked).
* `distanceUnit`: String (`cm` or `inches`).
* `motionSensitivity`: String (`Standard`, `High`).
* `cameraResolution`: String (`VGA`, `SVGA`, `QVGA`).
* `calibrationRecords`: `List<CalibrationRecord>`.

### 2.9 Firmware & Maintenance (`FirmwareBundle`)
* `firmwareInventory`: `List<DeviceFirmwareInfo>` (ESP32 DevKit Controller `v1.0.0 (Demo)`, ESP32 DevKit Aux `v1.0.0 (Demo)`, ESP32-CAM `v1.0.0 (Demo)`).
* `updateAvailability`: `FirmwareUpdateStatus` (No updates available · requires physical hardware integration).
* `maintenanceRecords`: `List<MaintenanceRecord>`.

