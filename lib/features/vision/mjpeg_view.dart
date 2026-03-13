/// ============================================================
/// mjpeg_view.dart — Platform-conditional MJPEG viewer export
/// ============================================================
///
/// Uses Dart conditional imports to select the correct MJPEG
/// implementation at compile time:
///   • **Web** → `mjpeg_view_web.dart` (HTML `<img>` element,
///     bypasses CORS restrictions)
///   • **IO** (Desktop / Mobile) → `mjpeg_view_io.dart`
///     (HTTP streaming with manual JPEG frame parsing)
library;

export 'mjpeg_view_io.dart' if (dart.library.html) 'mjpeg_view_web.dart';
