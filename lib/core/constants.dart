/// ============================================================
/// constants.dart — Global application constants for The Vision
/// ============================================================
///
/// Centralised store for all configurable values including
/// stream URLs, colour hex codes, mock data, and timing
/// parameters. Every magic-number in the app should originate
/// from this file so that a single edit propagates everywhere.
library;

/// ----- Network / Stream URLs -----
/// MJPEG camera stream endpoint — change this to match the
/// robot's on-board camera server address.
const String kCameraStreamUrl = 'http://192.168.0.181:81/stream';

/// ----- Colour Hex Values (used by AppTheme) -----
const int kBackgroundHex = 0xFF0F172A; // Deep charcoal
const int kSurfaceHex = 0xFF1E293B; // Lighter dark blue-grey
const int kPrimaryAccentHex = 0xFF0EA5E9; // Cyberpunk blue
const int kAlertGreenHex = 0xFF84CC16; // Acid green
const int kAlertRedHex = 0xFFEF4444; // Neon red
const int kTextPrimaryHex = 0xFFE2E8F0; // Slate-200 for legible text
const int kTextSecondaryHex = 0xFF94A3B8; // Slate-400 for muted text
const int kTerminalBgHex = 0xFF030712; // Near-black for terminal
const int kTerminalTextHex = 0xFF4ADE80; // Green-400 for terminal text

/// ----- Battery & Telemetry Defaults -----
const double kDefaultBatteryLevel = 0.85; // 85 %
const String kDefaultCpuTemp = '42°C';
const String kDefaultWifiSignal = '-45 dBm';
const String kDefaultGait = 'IDLE';

/// ----- Mock Terminal Logs -----
/// Simulated system log entries displayed in the bottom
/// terminal panel on app start.
const List<String> kMockTerminalLogs = [
  '[10:42:01] SYS  : Boot sequence complete — all servos homed.',
  '[10:42:01] SYS  : Connected to camera feed @ $kCameraStreamUrl',
  '[10:42:03] NET  : WebSocket handshake OK (latency 12 ms)',
  '[10:42:05] VISION: Object detected [person] — Confidence: 0.92',
  '[10:42:07] MOTOR : FL_Leg nominal • FR_Leg nominal',
  '[10:42:08] MOTOR : RL_Leg nominal • RR_Leg nominal',
  '[10:42:10] POWER : Battery 85 % — estimated runtime 47 min',
  '[10:42:12] VISION: Frame rate stable @ 30 fps',
  '[10:42:15] SYS  : Telemetry broadcast active on :8080',
  '[10:42:18] VISION: Object detected [cat] — Confidence: 0.87',
  '[10:42:20] MOTOR : Gait transition → IDLE',
];
