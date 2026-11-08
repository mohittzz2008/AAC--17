# ROVER COMMAND — Security, Reliability & Safety Audit

**Document ID**: `AUDIT-09-SECURITY-RELIABILITY`  
**Classification**: Cyber-Physical Security & System Reliability  
**Project**: ROVER COMMAND  
**Root Workspace**: `D:\projects\AAC FLUTTER`  

---

## 1. Secrets & Credential Audit

A thorough inspection of all repository files (`lib/`, `web/`, `android/`, `test/`) was conducted to identify any hardcoded credentials, Wi-Fi keys, or private tokens.

| Asset / Parameter | Location in Codebase | Security Finding | Risk Assessment | Recommendation |
| :--- | :--- | :--- | :--- | :--- |
| **Demo Network SSID & Password** | `DemoConfigurationDataSource.dart` | Contains placeholder strings (`"ROVER-NET"`, `""`) used solely for UI demo state. | **LOW (Benign)** | Maintain dummy placeholders. Real credentials must only be stored in secure device keystore. |
| **Private Keys / API Tokens** | Entire workspace | **ZERO private keys or API tokens found** in the repository. | **SECURE** | Enforce pre-commit hooks to block secret commits. |
| **Firebase / Cloud Configs** | Entire workspace | None present (Self-hosted local IoT architecture). | **SECURE** | Cloud-independent architecture protects against remote leakage. |

---

## 2. Cyber-Physical Safety & Hardware Protection

Because ROVER COMMAND interacts with physical DC motors, high-discharge 12V Li-ion batteries, and servo actuators, software failures can cause physical collisions or equipment damage. The application implements four core safety boundaries:

```
[SAFETY LAYER 1: UI IMMEDIATE SYNCHRONOUS LOCK]
  Emergency Stop pressed -> _heldKeys wiped -> UI visually locked immediately.

[SAFETY LAYER 2: MULTI-KEY ARBITRATION]
  Opposing keys (W + S or Left + Right) immediately result in MovementDirection.stop.

[SAFETY LAYER 3: DEAD-MAN COMMUNICATION TIMEOUT]
  Every movement command packet carries a 250 ms timeout contract.

[SAFETY LAYER 4: HARDWARE-LEVEL WATCHDOG]
  Firmware watchdog automatically pulls DRV8833 sleep pins LOW on link loss.
```

### 2.1 The Dead-Man Switch Contract
* **The Hazard**: If the operator holds "Forward" and the Wi-Fi connection drops or the browser tab closes, the rover could continue driving forward indefinitely.
* **The Enforcement**:
  * Every movement packet includes `"timeout_ms": 250`.
  * The frontend dispatches continuous heartbeats while a key is held.
  * When the key is released, `stopMovement()` is called.
  * If the rover microcontroller misses packets for $> 250\text{ ms}$, firmware stops motor PWM automatically.

### 2.2 Emergency Stop Precedence
* **Absolute Priority**: In `RoverOperationViewModel.dart`, `triggerEmergencyStop()`:
  1. Synchronously wipes `_heldKeys`.
  2. Sets `isEmergencyStopped = true`.
  3. Rejects any subsequent `startMovement()` calls until an explicit operator reset occurs.
  4. Dispatches the high-priority emergency halt packet to the hardware layer.

---

## 3. Reliability, Error Handling & Memory Management

### 3.1 Memory Management & Disposal
Memory leaks in long-running Flutter applications typically arise from orphaned `Ticker` instances, uncancelled `StreamSubscription` objects, or forgotten `ChangeNotifier` listeners.

* **Audit Finding**:
  * `DependencyContainer.dispose()` systematically disposes all 10 ViewModels.
  * `ApplicationZoomController.dispose()` stops and disposes the `_ticker`.
  * `ApplicationZoomWrapper` detaches Web Zoom bridge listeners during unmount.
  * The test suite's `leak_tracker` integration reports zero memory leaks during test runs.

### 3.2 Granular Error Boundaries
* Every asynchronous repository call is wrapped in a `try / catch` block.
* When data retrieval fails, the ViewModel transitions to a strongly-typed `ErrorState(e.toString())` rather than crashing the Flutter application with an unhandled exception.
* Error states present readable diagnostic disclaimers to the operator with actionable retry buttons.

