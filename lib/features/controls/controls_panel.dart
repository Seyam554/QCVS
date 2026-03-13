/// ============================================================
/// controls_panel.dart — Left sidebar: D-Pad & action buttons
/// ============================================================
///
/// Contains a custom directional pad for walking movement
/// control and a grid of action buttons (Stand, Sit, Trot,
/// Power Down) for posture / gait commands.
library;

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/utils.dart';

/// Left sidebar panel containing the D-Pad and action buttons.
class ControlsPanel extends StatelessWidget {
  const ControlsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('MOVEMENT CONTROL'),
          const SizedBox(height: 8),

          // ---- D-Pad ----
          const Expanded(
            flex: 3,
            child: Center(child: _DPad()),
          ),

          const SizedBox(height: 16),

          // ---- Divider ----
          Divider(color: AppColors.primary.withAlpha(30)),

          const SizedBox(height: 12),
          const SectionLabel('ACTIONS'),
          const SizedBox(height: 8),

          // ---- Action Buttons Grid ----
          Expanded(
            flex: 2,
            child: _ActionButtonGrid(),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// D-PAD WIDGET
// ================================================================

/// A custom directional pad with Up / Down / Left / Right
/// arranged in a cross pattern around a central indicator dot.
class _DPad extends StatelessWidget {
  const _DPad();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background.withAlpha(120),
              border: Border.all(
                color: AppColors.primary.withAlpha(30),
                width: 1.5,
              ),
            ),
          ),

          // Up
          Positioned(
            top: 4,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_up_rounded,
              label: 'FWD',
              onPressed: () => _onDPad('forward'),
            ),
          ),
          // Down
          Positioned(
            bottom: 4,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_down_rounded,
              label: 'REV',
              onPressed: () => _onDPad('reverse'),
            ),
          ),
          // Left
          Positioned(
            left: 4,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_left_rounded,
              label: 'L',
              onPressed: () => _onDPad('left'),
            ),
          ),
          // Right
          Positioned(
            right: 4,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_right_rounded,
              label: 'R',
              onPressed: () => _onDPad('right'),
            ),
          ),

          // Center indicator dot
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.primary.withAlpha(60),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(30),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.open_with_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder: In production, this would send a WebSocket
  /// command to the robot's motor controller.
  void _onDPad(String direction) {
    debugPrint('[CONTROLS] D-Pad pressed: $direction');
  }
}

/// Individual button inside the D-Pad cluster.
///
/// Renders as a rounded-rect with an icon, tinted with the
/// primary accent colour on press via [InkWell].
class _DPadButton extends StatelessWidget {
  const _DPadButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        splashColor: AppColors.primary.withAlpha(40),
        highlightColor: AppColors.primary.withAlpha(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(220),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withAlpha(50),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 7,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ACTION BUTTONS GRID
// ================================================================

/// Grid of action buttons for posture / gait commands.
class _ActionButtonGrid extends StatelessWidget {
  /// Action definitions: label, icon, colour, and callback.
  static final _actions = [
    _ActionDef('STAND', Icons.arrow_upward_rounded, AppColors.primary),
    _ActionDef('SIT', Icons.arrow_downward_rounded, AppColors.primary),
    _ActionDef('TROT', Icons.pets_rounded, AppColors.alertGreen),
    _ActionDef('POWER\nDOWN', Icons.power_settings_new_rounded, AppColors.alertRed),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: _actions.map((a) => _ActionButton(def: a)).toList(),
    );
  }
}

/// Data class describing a single action button.
class _ActionDef {
  const _ActionDef(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

/// A single action button with icon, label, and accent border.
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.def});
  final _ActionDef def;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => debugPrint('[ACTION] ${def.label} pressed'),
        splashColor: def.color.withAlpha(40),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(200),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: def.color.withAlpha(60),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(def.icon, size: 18, color: def.color),
              const SizedBox(height: 6),
              Text(
                def.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: def.color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
