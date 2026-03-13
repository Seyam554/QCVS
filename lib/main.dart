/// ============================================================
/// main.dart — Application entry point for The Vision
/// ============================================================
///
/// Bootstraps the Flutter app with:
///   1. Riverpod [ProviderScope] at the root for state management.
///   2. The custom dark industrial glassmorphism [ThemeData].
///   3. The [DashboardScreen] as the single-page home.
///
/// Optimised for Web & Desktop — no mobile-specific scaffolding.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    /// [ProviderScope] must be the root widget so every
    /// descendant can access Riverpod providers.
    const ProviderScope(child: VisionApp()),
  );
}

/// Root [MaterialApp] for The Vision IoT Dashboard.
///
/// Uses the custom dark theme returned by [buildAppTheme()] and
/// renders the [DashboardScreen] as its home widget.  Web title
/// is set to match the product name.
class VisionApp extends StatelessWidget {
  const VisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Vision — Quadruped Controller',
      debugShowCheckedModeBanner: false,

      // Apply the Dark Industrial Glassmorphism theme
      theme: buildAppTheme(),

      // Single-page dashboard — no routing required
      home: const DashboardScreen(),
    );
  }
}
