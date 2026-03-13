/// ============================================================
/// vision_providers.dart — Riverpod state for the Vision feature
/// ============================================================
///
/// Manages the toggle state for the YOLOv8n AI overlay switch
/// and the user-configurable camera stream URL.  Uses Riverpod
/// 2.0+ [StateNotifier] syntax.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';

// ================================================================
// YOLO OVERLAY TOGGLE
// ================================================================

/// Whether the YOLOv8n AI overlay is active on the camera feed.
///
/// Toggling this in the UI would (in production) send a command
/// to the robot to start / stop inference and overlay bounding
/// boxes onto the MJPEG stream.
final yoloOverlayProvider = StateNotifierProvider<YoloOverlayNotifier, bool>(
  (ref) => YoloOverlayNotifier(),
);

/// Simple boolean notifier — flips the YOLO overlay on/off.
class YoloOverlayNotifier extends StateNotifier<bool> {
  YoloOverlayNotifier() : super(false);

  /// Toggle the overlay state.
  void toggle() => state = !state;

  /// Explicitly enable the overlay.
  void enable() => state = true;

  /// Explicitly disable the overlay.
  void disable() => state = false;
}

// ================================================================
// CAMERA STREAM URL (user-configurable)
// ================================================================

/// Holds the current MJPEG camera stream URL.
///
/// The default value is [kCameraStreamUrl] from constants.dart,
/// but the user can change it at runtime via the UI text field.
/// When updated, the vision panel reconnects to the new stream.
final cameraStreamUrlProvider =
    StateNotifierProvider<CameraStreamUrlNotifier, String>(
  (ref) => CameraStreamUrlNotifier(),
);

/// Notifier that manages the camera stream URL string.
class CameraStreamUrlNotifier extends StateNotifier<String> {
  CameraStreamUrlNotifier() : super(kCameraStreamUrl);

  /// Update the stream URL to a new value.
  void setUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isNotEmpty && trimmed != state) {
      state = trimmed;
    }
  }
}
