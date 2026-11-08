# ROVER COMMAND — Hardware Integration Requirements & Unresolved Specifications

## 1. Purpose

This document outlines the confirmed hardware components from the physical circuit diagram (`design_reference/hardware_circuit.jpeg`), details the missing and unverified specifications required before physical ESP32 and ESP32-CAM hardware integration can occur, and defines the safety boundaries enforced in the frontend application.

---

## 2. Confirmed Hardware Components

From inspection of `design_reference/hardware_circuit.jpeg`:

| Component | Quantity | Visible Details / Schematic Labels | Role in Circuit |
| :--- | :--- | :--- | :--- |
| **18650 Li-ion Cells** | 3 cells (3S) | 3.7V nominal × 3 = 11.1V nominal (~12.6V peak), labelled `12V Li-ion` | Main system power source |
| **Power Switch** | 1 | Single-pole toggle switch on main positive rail | Physical system power on/off |
| **Buck Converters** | 3 | Step-down modules with 4R7 inductors and 1000 µF capacitor | Voltage step-down (nominally 6V for motors, 5V/3.3V for microcontrollers) |
| **ESP32 DevKit V1** | 2 | 38-pin DevKit boards; note: *"need to check eep pin has inbuilt jumper..."* | System controllers |
| **ESP32-CAM** | 1 | AI-Thinker style module with OV2640 sensor, microSD, flash LED | Inspection video stream & camera telemetry |
| **DRV8833 Motor Drivers** | 2 | Dual H-bridge breakout boards with 10 kΩ pull-up/down resistors | DC motor & actuator drive stages |
| **Yellow DC Gear Motors** | 2 | Labelled "left motor" & "right motor" with 100 nF suppression caps | Primary wheel drive actuation |
| **Grey DC Motors** | 2 | Suppression caps (100 nF) | Auxiliary drive or mechanical drive |
| **MG90S Micro Servos** | 3-4 | "horizontal servo", "vertical servo", "bullet loader servo" | Camera gimbal pan/tilt & mechanical loader |
| **HC-SR04 Ultrasonic Sensors** | 2 | Voltage divider (1.00 kΩ & 2.00 kΩ) on ECHO line | Front/rear distance obstacle detection |
| **RCWL-0516 Radar Sensors** | 2 | Microwave Doppler motion sensors | Proximity motion & intrusion detection |

---

## 3. Unresolved Hardware Information & Critical Blockers

Before live hardware communication can be implemented in the Flutter frontend, the following engineering details must be verified:

### 3.1 Controller Role Partitioning
* **Unresolved**: The circuit shows two identical ESP32 DevKit boards and one ESP32-CAM. There is no documentation assigning specific roles:
  * Which DevKit is the Primary Controller vs Motor Driver vs Sensor Controller?
  * Does the ESP32-CAM operate as a standalone Wi-Fi server or as an I2C/UART peripheral to a main controller?

### 3.2 Inter-Microcontroller Interconnects
* **Unresolved**: The schematic does not show a shared communication bus between the two ESP32 DevKit boards or the ESP32-CAM:
  * No UART cross-wiring (TX/RX).
  * No I2C bus (SDA/SCL) with pull-ups.
  * No SPI or CAN bus.
* **Requirement**: An inter-board protocol (or unified Wi-Fi/mesh star topology) must be established in firmware before telemetry can be aggregated into a single stream.

### 3.3 Pin Allocations & GPIO Assignments
* **Unresolved**: Wire routes in the schematic pass near pins, but exact GPIO numbers (e.g. GPIO4, GPIO13, GPIO16, etc.) are unlabelled.
* **Requirement**: A definitive pinout mapping table verified against ESP32 strapping pins and ADC2 Wi-Fi conflict limitations.

### 3.4 Telemetry Transport & Network Protocol
* **Unresolved**:
  * Is communication over Wi-Fi SoftAP, local Wi-Fi station, BLE (Bluetooth Low Energy), USB Serial, or MQTT/WebSocket?
  * What is the message framing format (JSON, Protocol Buffers, CBOR, or raw binary packets)?
  * What is the packet refresh rate, timeout threshold, and heartbeat interval?

### 3.5 Camera Streaming Protocol & Endpoint
* **Unresolved**:
  * Does the ESP32-CAM host an HTTP MJPEG stream (e.g. `http://192.168.4.1:81/stream`), RTSP server, or WebRTC channel?
  * What is the camera resolution (QVGA, VGA, SVGA), frame rate target, and JPEG compression quality?

### 3.6 Power Measurement Absence
* **Confirmed Limitation**:
  * The physical schematic contains **NO voltage divider or current shunt** connected to any ESP32 analog ADC pin from the 12V Li-ion battery or 6V buck outputs.
  * Therefore, **battery voltage, battery charge percentage, and buck converter voltages cannot be measured by the microcontroller**.
  * The frontend correctly displays these metrics as `UNAVAILABLE` and `NOMINAL RATINGS · NOT MEASUREMENTS`.

---

## 4. Frontend Safety Boundaries & Enforced Rules

1. **No Drive or Actuation Controls**: The ROVER COMMAND application is an **inspection and monitoring system**. No drive motor or servo actuation controls are exposed in the frontend, preventing unverified physical movement.
2. **Honest Disconnection & Unverified States**: When no hardware connection exists, the UI must explicitly indicate `NOT VERIFIED`, `DISCONNECTED`, and `SIMULATED DATA`. Under no circumstances should fake stream videos or simulated sensor readings be masqueraded as live hardware data.
3. **Clean Abstraction**: All hardware-specific services (`DeviceService`, `TelemetryService`, `CameraService`) are hidden behind abstract Dart interfaces so that when firmware specifications are finalized, hardware implementations can be plugged in seamlessly without touching presentation widgets.

