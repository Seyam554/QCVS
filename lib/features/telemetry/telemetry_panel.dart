/// ============================================================
/// telemetry_panel.dart — Right sidebar: system telemetry
/// ============================================================
///
/// Displays real-time (mock) readouts for CPU temperature,
/// Wi-Fi signal strength, current gait mode, and a battery
/// gauge.  In production these values would be pushed over a
/// WebSocket connection from the robot.
library;

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';

/// Right sidebar showing telemetry gauges and system readouts.
class TelemetryPanel extends StatelessWidget {
  const TelemetryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('SYSTEM TELEMETRY'),
          const SizedBox(height: 8),

          // ---- Scrollable content area ----
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- Battery Gauge ----
                  _BatteryGauge(level: kDefaultBatteryLevel),
                  const SizedBox(height: 16),

                  // ---- Telemetry Readouts ----
                  _TelemetryRow(
                    icon: Icons.thermostat_outlined,
                    label: 'CPU TEMP',
                    value: kDefaultCpuTemp,
                    valueColor: AppColors.alertGreen,
                  ),
                  const SizedBox(height: 10),
                  _TelemetryRow(
                    icon: Icons.wifi_rounded,
                    label: 'WI-FI RSSI',
                    value: kDefaultWifiSignal,
                    valueColor: AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  _TelemetryRow(
                    icon: Icons.directions_walk_rounded,
                    label: 'GAIT MODE',
                    value: kDefaultGait,
                    valueColor: AppColors.textPrimary,
                  ),

                  const SizedBox(height: 12),

                  // ---- System Stats ----
                  Divider(color: AppColors.primary.withAlpha(30)),
                  const SizedBox(height: 8),
                  _TelemetryRow(
                    icon: Icons.schedule_rounded,
                    label: 'UPTIME',
                    value: '00:47:32',
                    valueColor: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  _TelemetryRow(
                    icon: Icons.memory_rounded,
                    label: 'CPU LOAD',
                    value: '23 %',
                    valueColor: AppColors.alertGreen,
                  ),
                  const SizedBox(height: 8),
                  _TelemetryRow(
                    icon: Icons.storage_rounded,
                    label: 'MEMORY',
                    value: '512 / 2048 MB',
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// BATTERY GAUGE
// ================================================================

/// A styled battery level indicator with percentage label.
///
/// Renders as a horizontal bar that fills from left to right.
/// The fill colour shifts from green → yellow → red based on
/// the [level] value (0.0 – 1.0).
class _BatteryGauge extends StatelessWidget {
  const _BatteryGauge({required this.level});
  final double level;

  Color _barColor() {
    if (level > 0.6) return AppColors.alertGreen;
    if (level > 0.3) return const Color(0xFFFBBF24); // Amber
    return AppColors.alertRed;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (level * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _barColor().withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + label + percentage
          Row(
            children: [
              Icon(Icons.battery_full_rounded, size: 16, color: _barColor()),
              const SizedBox(width: 8),
              Text(
                'BATTERY',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: TextStyle(
                  color: _barColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: level,
              minHeight: 6,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor()),
            ),
          ),

          const SizedBox(height: 6),
          Text(
            'EST. RUNTIME: 47 MIN',
            style: TextStyle(
              color: AppColors.textSecondary.withAlpha(150),
              fontSize: 8,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// TELEMETRY ROW
// ================================================================

/// A single key-value readout row with an accompanying icon.
class _TelemetryRow extends StatelessWidget {
  const _TelemetryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Leading icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: valueColor.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: valueColor),
        ),
        const SizedBox(width: 10),

        // Label + Value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
