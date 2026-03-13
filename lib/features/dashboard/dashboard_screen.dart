/// ============================================================
/// dashboard_screen.dart — Main single-page layout
/// ============================================================
///
/// Assembles all feature panels into a responsive grid:
///
///  ┌──────────────────────────────────────────────────┐
///  │                  HEADER BAR                      │
///  ├─────────┬──────────────────────┬─────────────────┤
///  │         │                      │                 │
///  │ CONTROLS│    VISION FEED       │   TELEMETRY     │
///  │ (D-Pad) │    (MJPEG + YOLO)    │   (Readouts)    │
///  │         │                      │                 │
///  ├─────────┴──────────────────────┴─────────────────┤
///  │              EVENT TERMINAL                      │
///  └──────────────────────────────────────────────────┘
///
/// Uses [Row] + [Column] + [Expanded] for the flex layout.
library;

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../controls/controls_panel.dart';
import '../telemetry/telemetry_panel.dart';
import '../telemetry/terminal_panel.dart';
import '../vision/vision_panel.dart';

/// The root screen of The Vision dashboard.
///
/// This is a [StatelessWidget] because all reactive state is
/// managed by Riverpod providers — the widget tree itself has
/// no mutable state.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ============ A. HEADER BAR ============
            _HeaderBar(),

            const SizedBox(height: 12),

            // ============ BODY (3-column) ============
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  // ---- B. Left Sidebar: Controls ----
                  const SizedBox(
                    width: 240,
                    child: ControlsPanel(),
                  ),

                  const SizedBox(width: 12),

                  // ---- C. Center: Vision Feed ----
                  const Expanded(
                    flex: 3,
                    child: VisionPanel(),
                  ),

                  const SizedBox(width: 12),

                  // ---- D. Right Sidebar: Telemetry ----
                  const SizedBox(
                    width: 260,
                    child: TelemetryPanel(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ============ E. BOTTOM: Terminal ============
            const SizedBox(
              height: 180,
              child: TerminalPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// HEADER BAR
// ================================================================

/// Top header bar with app title, connection status, and battery.
class _HeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      borderRadius: 12,
      child: Row(
        children: [
          // ---- Logo / Brand Icon ----
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withAlpha(60),
              ),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 14),

          // ---- App Title ----
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'VISION // QUADRUPED CONTROLLER',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'v1.0.0  •  FIRMWARE 2026.03',
                style: TextStyle(
                  color: AppColors.textSecondary.withAlpha(150),
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          const Spacer(),

          // ---- Connection Status ----
          _StatusPill(
            icon: Icons.cell_tower_rounded,
            label: 'SYS: ONLINE',
            color: AppColors.alertGreen,
          ),

          const SizedBox(width: 16),

          // ---- Battery Mini Indicator ----
          _BatteryMiniBadge(level: kDefaultBatteryLevel),
        ],
      ),
    );
  }
}

// ================================================================
// STATUS PILL
// ================================================================

/// A small pill badge with a glowing dot, used for connection status.
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(180),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// BATTERY MINI BADGE
// ================================================================

/// Compact battery indicator in the header — shows icon + percentage.
class _BatteryMiniBadge extends StatelessWidget {
  const _BatteryMiniBadge({required this.level});
  final double level;

  @override
  Widget build(BuildContext context) {
    final pct = (level * 100).toInt();
    final color = level > 0.6
        ? AppColors.alertGreen
        : level > 0.3
            ? const Color(0xFFFBBF24)
            : AppColors.alertRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.battery_full_rounded, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$pct%',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
