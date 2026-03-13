# 🤖 Quadruped Control Vision System (QCVS) v1.0

> **The Vision** — A high-performance IoT dashboard for controlling a quadruped robot and monitoring its telemetry and computer vision feeds in real-time.

## ✨ Features

- **Live MJPEG Camera Feed** — Real-time video stream from the robot's onboard camera with configurable IP address
- **YOLOv8n AI Toggle** — Enable/disable object detection overlay on the camera feed
- **D-Pad Movement Control** — Directional pad for forward, reverse, left, and right movement
- **Action Commands** — Quick-access buttons for Stand, Sit, Trot, and Power Down
- **System Telemetry** — Real-time readouts for battery, CPU temperature, Wi-Fi signal, gait mode, uptime, and memory
- **Event Terminal** — Color-coded scrollable log terminal for system events
- **Dark Industrial Glassmorphism UI** — Premium cyberpunk-inspired design with JetBrains Mono typography

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants.dart          # Global configuration values
│   ├── theme.dart              # Dark Industrial Glassmorphism theme
│   └── utils.dart              # Shared widgets (GlassPanel, SectionLabel)
├── features/
│   ├── controls/
│   │   └── controls_panel.dart # D-Pad + action buttons
│   ├── dashboard/
│   │   └── dashboard_screen.dart # Main 3-column layout
│   ├── telemetry/
│   │   ├── telemetry_panel.dart  # System readouts + battery gauge
│   │   └── terminal_panel.dart   # Event log terminal
│   └── vision/
│       ├── mjpeg_view.dart       # Platform-conditional MJPEG export
│       ├── mjpeg_view_web.dart   # Web: HTML <img> (CORS-exempt)
│       ├── mjpeg_view_io.dart    # Desktop: HTTP stream parsing
│       ├── vision_panel.dart     # Camera feed + YOLO toggle + URL bar
│       └── vision_providers.dart # Riverpod state providers
└── main.dart                     # App entry point
```

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform framework (Web + Desktop) |
| **Riverpod** | Reactive state management |
| **Google Fonts** | JetBrains Mono typography |
| **Custom MJPEG Parser** | Live camera feed without CORS issues |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.29+
- Dart SDK 3.7+

### Run on Web
```bash
flutter run -d chrome
```

### Run on Windows Desktop
```bash
flutter run -d windows
```

### Build Release (Windows)
```bash
flutter build windows --release
```

## 📡 Camera Configuration

Enter your camera's MJPEG stream URL directly in the dashboard's stream input bar:
```
http://192.168.x.x:81/stream
```

## 📄 License

MIT License — feel free to use and modify.

---

Built with ❤️ using Flutter
