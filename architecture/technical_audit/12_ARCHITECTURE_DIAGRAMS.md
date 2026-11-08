# ROVER COMMAND — Comprehensive Architecture Diagrams

**Document ID**: `AUDIT-12-DIAGRAMS`  
**Classification**: Visual Architecture & Engineering Blueprints  
**Project**: ROVER COMMAND  
**Root Workspace**: `D:\projects\AAC FLUTTER`  

---

## 1. Overall System Architecture

```mermaid
flowchart TB
    subgraph OperatorInterface ["Operator Interface (Ground Station)"]
        Browser["Chrome Browser / CanvasKit Engine"]
        FlutterApp["ROVER COMMAND Flutter SPA"]
        InputEngine["Multi-Input Arbitration (Keyboard, Touch, Mouse)"]
        ZoomEngine["ApplicationZoomController (Matrix4 GPU Scale)"]
    end

    subgraph NetworkLayer ["Network Transport Layer"]
        SoftAP["Wi-Fi SoftAP / Local LAN (802.11)"]
        WSChannel["WebSocket Channel (:8080) - Controls & Telemetry"]
        MJPEGChannel["HTTP MJPEG Stream (:81/stream) - Video Feed"]
    end

    subgraph PhysicalRover ["Physical AAC Rover Hardware"]
        ESP_CAM["ESP32-CAM (AI-Thinker OV2640)"]
        ESP_MAIN["ESP32 DevKit V1 (Main Controller)"]
        ESP_SENSORS["ESP32 DevKit V1 (Sensor Controller)"]
        DRV_MOTORS["2x DRV8833 Motor Drivers"]
        MOTORS["4x 6V DC Drive Motors"]
        SERVOS["4x MG90S Micro Servos (Gimbal / Loader)"]
        SENSORS_US["2x HC-SR04 Ultrasonic (Front/Rear)"]
        SENSORS_RADAR["2x RCWL-0516 Microwave Radar"]
        POWER["3S 18650 Li-ion (12V) + 3x Buck Converters"]
    end

    InputEngine --> FlutterApp
    ZoomEngine --> FlutterApp
    FlutterApp --> Browser
    Browser <==>|Wi-Fi Packets| SoftAP
    SoftAP --> WSChannel
    SoftAP --> MJPEGChannel
    MJPEGChannel <==>|Video Frames| ESP_CAM
    WSChannel <==>|Movement & Telemetry| ESP_MAIN
    ESP_MAIN --> DRV_MOTORS
    DRV_MOTORS --> MOTORS
    DRV_MOTORS --> SERVOS
    ESP_MAIN -.-|Interconnect| ESP_SENSORS
    ESP_SENSORS --> SENSORS_US
    ESP_SENSORS --> SENSORS_RADAR
    POWER --- MOTORS
    POWER --- ESP_MAIN
```

---

## 2. Frontend Architecture (Three-Tier Clean Architecture)

```mermaid
flowchart TD
    subgraph Presentation ["Presentation Layer (Flutter)"]
        Shell["RoverShell (Responsive Shell)"]
        NavRail["RoverNavigationRail (Desktop)"]
        NavBottom["RoverBottomNavigationBar (Mobile/Tablet)"]
        ZoomWrap["ApplicationZoomWrapper (GPU Matrix4)"]
        Screens["10 Feature Screens (Dashboard, Camera, Operation, etc.)"]
        VMs["10 Feature ViewModels (ChangeNotifier)"]
    end

    subgraph Domain ["Domain Layer (Framework-Independent)"]
        Entities["Domain Models (Immutable Value Objects)"]
        Enums["Strongly-Typed Domain Enums"]
        RepoContracts["10 Repository Interface Contracts"]
    end

    subgraph Data ["Data Layer"]
        RepoImpls["10 Repository Implementations"]
        DSContracts["10 DataSource Interfaces"]
        DemoDS["10 Demo Data Sources (Active)"]
        LiveDS["10 Hardware Data Sources (Planned)"]
    end

    Shell --> NavRail
    Shell --> NavBottom
    Shell --> ZoomWrap
    ZoomWrap --> Screens
    Screens -->|Observes via ListenableBuilder| VMs
    VMs -->|Calls via Interface| RepoContracts
    RepoContracts <|.. RepoImpls
    RepoImpls -->|Queries| DSContracts
    DSContracts <|.. DemoDS
    DSContracts <|..- LiveDS
    RepoImpls -->|Maps to| Entities
    Entities --- Enums
```

---

## 3. Feature-First Directory Structure

```mermaid
graph TD
    Root["lib/"] --> App["app/ (DependencyContainer)"]
    Root --> Core["core/ (Theme, Responsive, Zoom)"]
    Root --> Shared["shared/ (Shell, Enums, Common Widgets)"]
    Root --> Features["features/"]

    Features --> F1["dashboard/"]
    Features --> F2["camera/"]
    Features --> F3["sensors/"]
    Features --> F4["rover_operation/"]
    Features --> F5["system/"]
    Features --> F6["device_connection/"]
    Features --> F7["diagnostics/"]
    Features --> F8["activity_logs/"]
    Features --> F9["configuration/"]
    Features --> F10["firmware/"]

    subgraph StandardStructure ["Clean Structure in Every Feature"]
        DataDir["data/ (datasources, repositories)"]
        DomainDir["domain/ (models, repositories)"]
        PresDir["presentation/ (screens, state, viewmodels, widgets)"]
    end

    F1 --- DataDir
    F1 --- DomainDir
    F1 --- PresDir
```

---

## 4. MVVM and Repository Communication Pattern

```mermaid
classDiagram
    class Screen {
        +ViewModel viewModel
        +build(BuildContext) Widget
    }

    class ViewModel {
        -UIState _state
        -Repository _repository
        +initialize() Future
        +executeAction() Future
        +notifyListeners() void
    }

    class Repository {
        <<interface>>
        +fetchData() Future~Entity~
        +sendCommand(Command) Future~Result~
    }

    class RepositoryImpl {
        -DataSource _dataSource
        +fetchData() Future~Entity~
        +sendCommand(Command) Future~Result~
    }

    class DataSource {
        <<interface>>
        +getRawData() Future
        +dispatchPacket() Future
    }

    Screen ..> ViewModel : observes
    ViewModel ..> Repository : invokes
    RepositoryImpl ..|> Repository : implements
    RepositoryImpl ..> DataSource : delegates
```

---

## 5. Application Startup Sequence

```mermaid
sequenceDiagram
    autonumber
    participant Browser as Chrome V8 / DOM
    participant Main as lib/main.dart
    participant DI as DependencyContainer
    participant Shell as RoverShell
    participant Zoom as ApplicationZoomWrapper
    participant Screen as DashboardScreen
    participant VM as DashboardViewModel
    participant Repo as DashboardRepositoryImpl

    Browser->>Main: Loads web app (main())
    Main->>Shell: runApp(RoverCommandApp -> RoverShell)
    Shell->>DI: DependencyContainer() (Singleton initializes Repos & VMs)
    Shell->>Shell: Parses URI query parameters (?tab=...)
    Shell->>Zoom: Instantiates workspace ApplicationZoomWrapper
    Zoom->>Screen: Builds active DashboardScreen
    Screen->>VM: initialize() called on mount
    VM->>VM: Emits DashboardLoading()
    VM->>Repo: fetchDashboardTelemetry()
    Repo-->>VM: Returns DashboardTelemetryBundle
    VM->>VM: Emits DashboardLoaded()
    VM-->>Screen: Repaints with fresh telemetry
```

---

## 6. User-to-Hardware Remote Command Flow

```mermaid
sequenceDiagram
    autonumber
    actor Operator as Operator
    participant UI as RoverOperationScreen (D-Pad)
    participant VM as RoverOperationViewModel
    participant Repo as RoverOperationRepositoryImpl
    participant Net as WebSocket Client
    participant ESP as ESP32 Main Controller
    participant Driver as DRV8833 H-Bridge
    participant Motors as 6V DC Motors

    Operator->>UI: Presses 'W' / Taps Forward Button
    UI->>VM: handleKeyDown('W') / startMovement(forward)
    VM->>VM: Checks auto-repeat, opposing keys, and E-Stop lock
    VM->>VM: Sets activeDirection = forward; notifyListeners() (UI Highlights)
    VM->>Repo: sendMovementCommand(forward)
    Repo->>Net: Dispatches JSON {"cmd":"MOVE","dir":"FWD","timeout_ms":250}
    Net-->>ESP: Transmits over Wi-Fi
    ESP->>Driver: Asserts IN1=PWM, IN2=0 (Forward Mode)
    Driver->>Motors: Delivers 6V DC current
    Motors-->>Operator: Rover moves forward physically
```

---

## 7. Sensor-to-Dashboard Telemetry Flow

```mermaid
sequenceDiagram
    autonumber
    participant Ultra as HC-SR04 Sensors
    participant Radar as RCWL-0516 Sensors
    participant ESP as ESP32 Sensor Controller
    participant Net as WebSocket / UDP Stream
    participant DS as SensorsDataSource
    participant Repo as SensorsRepositoryImpl
    participant VM as SensorsViewModel
    participant UI as SensorsScreen / Dashboard

    Ultra->>ESP: Echo pulse duration (Distance in cm)
    Radar->>ESP: Digital High/Low (Motion trigger)
    ESP->>Net: Broadcasts telemetry packet @ 10 Hz
    Net->>DS: Ingests raw sensor JSON
    DS->>Repo: Passes DTO
    Repo->>Repo: Validates ranges & maps to SensorsTelemetryBundle
    Repo->>VM: Returns immutable domain bundle
    VM->>VM: Updates state = SensorsLoaded; notifyListeners()
    VM-->>UI: ListenableBuilder rebuilds metric cards & CustomTelemetryChart
```

---

## 8. Emergency Stop Command Sequence (Safety Critical)

```mermaid
sequenceDiagram
    autonumber
    actor Operator as Operator
    participant UI as EmergencyStopButton / Spacebar
    participant VM as RoverOperationViewModel
    participant Repo as RoverOperationRepositoryImpl
    participant Net as High-Priority Socket
    participant ESP as ESP32 Controller
    participant Driver as DRV8833 Drivers

    Operator->>UI: Hits SPACEBAR / Presses EMERGENCY STOP
    UI->>VM: triggerEmergencyStop()
    VM->>VM: 1. Clears _heldKeys (wipes pending directional inputs)
    VM->>VM: 2. Sets isEmergencyStopped=true, activeDirection=stop
    VM->>VM: 3. notifyListeners() (Instant synchronous UI Lock)
    VM->>Repo: triggerEmergencyStop()
    Repo->>Net: Dispatches priority packet {"cmd":"ESTOP","action":"HALT"}
    Net-->>ESP: Immediate TCP Packet
    ESP->>Driver: Disables PWM, asserts BRAKE mode, pulls SLEEP LOW
    Driver-->>ESP: Motors halted within < 10 ms
```

---

## 9. Camera Stream Architecture

```mermaid
flowchart LR
    OV2640["OV2640 Camera Sensor"] -->|DVP Parallel Bus| ESP32CAM["ESP32-CAM (AI-Thinker)"]
    ESP32CAM -->|Hardware JPEG Compression| Buffer["Frame Buffer (PSRAM)"]
    Buffer -->|HTTP Chunked Stream (:81/stream)| SoftAP["Wi-Fi SoftAP (802.11)"]
    SoftAP -->|Multipart/x-mixed-replace| Browser["Chrome Browser"]
    Browser -->|CanvasKit Texture / Image.network| Viewport["CameraStreamViewport Widget"]
    Viewport -->|Tactical HUD Overlay| Display["HUD Crosshairs, FPS & Latency Overlay"]
```

---

## 10. Deployment & Build Architecture

```mermaid
flowchart TD
    Source["Flutter / Dart Source Code (lib/)"] --> Analyzer["Dart Analyzer (flutter analyze)"]
    Analyzer --> Tests["Automated Tests (flutter test)"]
    Tests --> Builder["Production Web Compiler (flutter build web --release)"]
    Builder --> TreeShaker["Font Tree Shaker (CupertinoIcons -99.4%, Material -99.0%)"]
    TreeShaker --> Wasm["CanvasKit Wasm + main.dart.js Output"]
    Wasm --> DistFolder["build/web/ Distribution Folder"]

    DistFolder --> TargetA["Local Field Laptop (Chrome / Python Server :8089)"]
    DistFolder --> TargetB["Dedicated Rover Web Server (Raspberry Pi Nginx)"]
    DistFolder --> TargetC["Android Native APK (flutter build apk --release)"]
```

