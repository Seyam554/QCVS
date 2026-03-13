/// ============================================================
/// utils.dart — Shared utility helpers for The Vision
/// ============================================================
///
/// Small, pure-function helpers that are used across multiple
/// features.  Keeping them here avoids circular imports.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';

/// Returns a [Widget] wrapped in a frosted-glass panel.
///
/// Uses [BackdropFilter] + [ClipRRect] to create the
/// glassmorphism surface effect described in the design spec.
/// [borderRadius] and [blurSigma] can be tuned per-panel.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blurSigma = 12.0,
    this.padding = const EdgeInsets.all(16),
    this.border = true,
  });

  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final EdgeInsets padding;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            // Semi-transparent surface for the glass look
            color: AppColors.surface.withAlpha(180),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border
                ? Border.all(
                    color: AppColors.primary.withAlpha(40),
                    width: 1,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Formats a [DateTime] into the terminal-log timestamp format
/// used in the bottom event panel: `[HH:MM:SS]`.
String formatTimestamp(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  final s = dt.second.toString().padLeft(2, '0');
  return '[$h:$m:$s]';
}

/// A small reusable "section label" widget used above each panel.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
      ),
    );
  }
}
