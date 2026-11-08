# ROVER COMMAND — State Management & Data Flow Architecture

**Document ID**: `AUDIT-05-STATE-DATAFLOW`  
**Classification**: Application State Architecture & Data Propagation  
**Project**: ROVER COMMAND  
**Root Workspace**: `D:\projects\AAC FLUTTER`  

---

## 1. State Management Philosophy: Native Reactive MVVM

The project intentionally avoids heavy external state management libraries (`Provider`, `Riverpod`, `BLoC`, `MobX`, `GetX`) in favor of native Dart and Flutter primitives:

1. **`ChangeNotifier`**: Serves as the observable state container inside ViewModels.
2. **`ListenableBuilder`**: Subscribes directly to `ChangeNotifier` updates and triggers granular sub-tree repaints without rebuilding entire screens.
3. **Sealed / Subclass State Hierarchies**: States are modeled as explicit classes representing discrete UI conditions:
   * `*Initial` (Pre-initialization state)
   * `*Loading` (Asynchronous operation or data fetch in flight)
   * `*Loaded` (Valid immutable domain data available for rendering)
   * `*Error` (Failure condition with descriptive error message)

---

## 2. Complete State Matrix Across All 10 Features

| Feature | ViewModel Class | State Base Class | State Subclasses / Fields | Primary Actions / Mutations |
| :--- | :--- | :--- | :--- | :--- |
| **Dashboard** | `DashboardViewModel` | `DashboardState` | `Initial`, `Loading`, `Loaded(DashboardTelemetryBundle)`, `Error(msg)` | `initialize()`, `refresh()` |
| **Camera** | `CameraViewModel` | `CameraState` | `Initial`, `Loading`, `Loaded(CameraTelemetry)`, `Error(msg)` | `initialize()`, `reconnect()` |
| **Sensors** | `SensorsViewModel` | `SensorsState` | `Initial`, `Loading`, `Loaded(SensorsTelemetryBundle)`, `Error(msg)` | `initialize()`, `refresh()` |
| **Rover Operation**| `RoverOperationViewModel`| `RoverOperationState`| `Initial`, `Loading`, `Loaded(RoverOperationTelemetry, activeDirection, isEmergencyStopped, noticeMessage)`, `Error(msg)` | `startMovement()`, `stopMovement()`, `handleKeyDown()`, `handleKeyUp()`, `triggerEmergencyStop()`, `resetEmergencyStop()` |
| **System** | `SystemViewModel` | `SystemState` | `Initial`, `Loading`, `Loaded(SystemTelemetryBundle)`, `Error(msg)` | `initialize()`, `refresh()` |
| **Device Connection**| `DeviceConnectionViewModel`| `DeviceConnectionState`| `Initial`, `Connecting`, `Connected`, `Disconnected`, `Discovery(devices)` | `startDiscovery()`, `connectDevice()`, `disconnectDevice()` |
| **Diagnostics** | `DiagnosticsViewModel` | `DiagnosticsState` | `Initial`, `Running`, `Loaded(DiagnosticsBundle)`, `Error(msg)` | `runDiagnostics()`, `dismissIssue()` |
| **Activity Logs** | `ActivityLogsViewModel` | `ActivityLogsState` | `Initial`, `Loading`, `Loaded(logs, filterCategory, filterSeverity, query)` | `filterByCategory()`, `filterBySeverity()`, `search()`, `clearLogs()` |
| **Configuration** | `ConfigurationViewModel`| `ConfigurationState`| `Initial`, `Saving`, `Loaded(RoverConfiguration)`, `Success`, `Error(msg)` | `updateNetwork()`, `updateSensors()`, `saveConfiguration()`, `resetDefaults()`|
| **Firmware** | `FirmwareViewModel` | `FirmwareState` | `Initial`, `Checking`, `Loaded(FirmwareBundle)`, `Updating(progress)`, `Error(msg)`| `checkForUpdates()`, `applyFirmwareUpdate()` |

---

## 3. End-to-End Data Flow Tracing

### 3.1 Trace A: User Initiates Forward Motion

```
[User Presses 'W' / Touches Up Arrow]
                   │
                   ▼
[DirectionalControlPad / Shortcuts Widget]
   ├── Detects touch down / keydown
   └── Invokes viewModel.handleKeyDown('W')
                   │
                   ▼
[RoverOperationViewModel]
   ├── Checks: _heldKeys.contains('W') -> Suppresses OS key auto-repeats
   ├── Arbitrates: _heldKeys contains opposite ('S')? -> Safe Halt if true
   ├── Emergency Stop Check: isEmergencyStopped == true? -> Reject with Notice
   ├── State Update: Sets activeDirection = MovementDirection.forward
   ├── Emits: notifyListeners() -> Immediate synchronous UI arrow highlight
   └── Invokes: repository.sendMovementCommand(MovementDirection.forward)
                   │
                   ▼
[RoverOperationRepositoryImpl]
   ├── Constructs: MovementCommand(direction: forward, timestamp, sequenceNumber++)
   └── Invokes: dataSource.dispatchMovement(direction)
                   │
                   ▼
[DemoRoverOperationDataSource (Future: HardwareDataSource)]
   ├── Live Transport: (WebSocket / UDP / HTTP endpoint / serial link)
   ├── Payload: {"cmd": "MOVE", "dir": "FWD", "seq": 104, "crc": 0x4B}
   └── Returns: MovementCommand(confirmed: true)
                   │
                   ▼
[Physical Rover / ESP32 Firmware Execution]
   ├── ESP32 DevKit Receives Packet
   ├── PWM Duty Cycle Applied to DRV8833 Dual H-Bridge
   └── 6V DC Motors Rotate Forward
```

### 3.2 Trace B: Emergency Stop Safety Arbitration

```
[User Presses SPACEBAR / Taps EMERGENCY STOP Button]
                   │
                   ▼
[RoverOperationViewModel.triggerEmergencyStop()]
   ├── 1. Clears _heldKeys set immediately (cancels any pressed directional keys)
   ├── 2. Mutates State synchronously:
   │       activeDirection = MovementDirection.stop
   │       isEmergencyStopped = true
   │       noticeMessage = "EMERGENCY STOP ENGAGED: Motors halted."
   ├── 3. Emits notifyListeners() (Instant visual lock on D-Pad and Red E-Stop glow)
   └── 4. Calls repository.triggerEmergencyStop()
                   │
                   ▼
[RoverOperationRepositoryImpl -> DataSource]
   ├── Dispatches immediate high-priority safety packet:
   │   {"cmd": "ESTOP", "action": "HALT_ALL", "seq": 105}
   └── Physical DRV8833 inputs pulled to LOW/BRAKE within milliseconds.
```

### 3.3 Trace C: Reverse Sensor Data Ingestion Flow

```
[HC-SR04 Ultrasonic / RCWL-0516 Microwave Sensors]
                   │
                   ▼
[ESP32 Controller Sampling (Firmware)]
   ├── Measures ECHO pulse duration (HC-SR04) -> Converts to cm
   └── Reads digital OUT pin (RCWL-0516) -> HIGH (Motion) / LOW (Clear)
                   │
                   ▼
[Network Transport (Wi-Fi / WebSocket / BLE)]
   └── Packets streamed to client:
       {"sensors": {"d1": 124.0, "d2": 86.0, "m1": 0, "m2": 1, "ts": 1794086200}}
                   │
                   ▼
[SensorsDataSource]
   └── Parses raw bytes / JSON into DTO
                   │
                   ▼
[SensorsRepositoryImpl]
   └── Validates measurement ranges and maps into immutable domain model:
       SensorsTelemetryBundle(
         distanceSensors: [DistanceSensorTelemetry(124 cm, valid), ...],
         motionSensors: [MotionSensorTelemetry(motionDetected, valid), ...]
       )
                   │
                   ▼
[SensorsViewModel]
   ├── Updates _state = SensorsLoaded(bundle)
   └── Calls notifyListeners()
                   │
                   ▼
[ListenableBuilder in SensorsScreen / DashboardScreen]
   ├── Rebuilds only the sensor metric cards and CustomTelemetryChart
   └── Repaints UI at calibrated 60 FPS without layout thrashing
```

---

## 4. Multi-Input Arbitration Engine (`RoverOperationViewModel`)

To ensure flawless operation across touchscreens, keyboards, and mice, `RoverOperationViewModel` maintains an internal `Set<String> _heldKeys`:

1. **Auto-Repeat Suppression**: The OS periodically resends `keydown` events when a key is physically held down. If `_heldKeys.contains(normalizedKey)`, subsequent repeated events are dropped immediately.
2. **Opposing Key Safety Arbitration**:
   * If both `W` and `S` (or `ArrowUp` and `ArrowDown`) are held simultaneously, the rover **halts** (`MovementDirection.stop`).
   * If both `A` and `D` (or `ArrowLeft` and `ArrowRight`) are held, the rover **halts**.
3. **Emergency Stop Precedence**: If Space is pressed, `_heldKeys` is wiped instantly, and all directional inputs are blocked until `resetEmergencyStop()` is explicitly called.
4. **Touch Cancellation**: When a touch pointer slides off a D-Pad button or an incoming phone call occurs on mobile, `onPointerCancel` triggers `stopMovement()` to prevent runaway rover movement.

