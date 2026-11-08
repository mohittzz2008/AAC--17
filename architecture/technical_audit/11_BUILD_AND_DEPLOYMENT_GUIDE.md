# ROVER COMMAND — Build & Deployment Guide

**Document ID**: `AUDIT-11-BUILD-DEPLOYMENT`  
**Classification**: DevOps, Build Engineering & Operations  
**Project**: ROVER COMMAND  
**Root Workspace**: `D:\projects\AAC FLUTTER`  

---

## 1. Prerequisites & Environment Setup

To build and run ROVER COMMAND on a clean development workstation, verify the following tools:

| Prerequisite | Minimum Version | Installation Verification |
| :--- | :--- | :--- |
| **Flutter SDK** | `3.18.0` (Recommended `3.22+`) | `flutter --version` |
| **Dart SDK** | `3.11.4` (Bundled with Flutter) | `dart --version` |
| **Google Chrome** | `115+` (Tested on `156`) | `chrome.exe --version` |
| **Android Studio / SDK**| API 33+ (For Android builds) | `flutter doctor` |
| **Java JDK** | JDK 17 or 21 (For Gradle builds) | `javac -version` |
| **Python** | Python 3.10+ (For local servers & tests) | `python --version` |

---

## 2. Clean Environment Initialization

### Step 1: Clone Repository & Navigate
```bash
git clone <repository_url> "D:\projects\AAC FLUTTER"
cd "D:\projects\AAC FLUTTER"
```

### Step 2: Fetch Dependencies
```bash
flutter pub get
```

### Step 3: Verify Environment Health
```bash
flutter analyze
flutter test --concurrency=1
```

---

## 3. Development Execution Commands

### 3.1 Running Flutter Web in Google Chrome (Debug Mode)
```bash
flutter run -d chrome --web-renderer canvaskit
```
* **Hot Reload**: Press `r` in terminal to trigger hot reload.
* **CanvasKit**: Forces high-performance WebAssembly/WebGL rendering matching production.

### 3.2 Running on Android Handheld Device / Emulator
```bash
flutter run -d android
```

### 3.3 Deep-Link Navigation Parameters
When launching or testing in Chrome, navigate directly to any page via URL parameters:
* `http://localhost:8080/?tab=dashboard` $\to$ Dashboard
* `http://localhost:8080/?tab=camera` $\to$ Camera Viewport
* `http://localhost:8080/?tab=sensors` $\to$ Detailed Sensors
* `http://localhost:8080/?tab=control` $\to$ Rover Operation & D-Pad
* `http://localhost:8080/?tab=system` $\to$ System Overview
* `http://localhost:8080/?tab=system&sub=connection` $\to$ Device Connection
* `http://localhost:8080/?tab=system&sub=diagnostics` $\to$ Diagnostics & Health
* `http://localhost:8080/?tab=system&sub=logs` $\to$ Activity & Event Logs
* `http://localhost:8080/?tab=system&sub=config` $\to$ Configuration & Calibration
* `http://localhost:8080/?tab=system&sub=firmware` $\to$ Firmware & Maintenance

---

## 4. Production Build & Distribution

### 4.1 Production Web SPA Build
```bash
flutter build web --release --no-wasm-dry-run
```
* **Output Path**: `D:\projects\AAC FLUTTER\build\web\`
* **Key Artifacts**:
  * `index.html`: Entry host with zoom capture listeners.
  * `main.dart.js`: Compiled Dart code ($2.6\text{ MB}$).
  * `canvaskit/canvaskit.wasm`: WebAssembly rendering engine.
  * `flutter_bootstrap.js`: Service worker & engine loader.

### 4.2 Hosting the Web Build Locally
To test the production build locally using Python:
```bash
python -m http.server 8089 --directory "D:\projects\AAC FLUTTER\build\web"
```
Then open: `http://127.0.0.1:8089/`

### 4.3 Android Release APK Build
```bash
flutter build apk --release
```
* **Output Path**: `D:\projects\AAC FLUTTER\build\app\outputs\flutter-apk\app-release.apk`
* Ready for side-loading onto an Android tablet or smartphone for field rover control.

---

## 5. Web Server Configuration (Nginx Example)

When deploying to a local field laptop or Raspberry Pi running Nginx:

```nginx
server {
    listen 80;
    server_name rover.local;
    root /var/www/rover_command;
    index index.html;

    # Gzip Compression
    gzip on;
    gzip_types text/plain text/css application/javascript application/json application/wasm image/svg+xml;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache CanvasKit and WebAssembly binaries
    location ~* \.(wasm|ttf|otf|png|jpg)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
```

