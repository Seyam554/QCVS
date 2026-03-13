// Basic smoke test for The Vision dashboard.
//
// Verifies the app bootstraps correctly and renders the
// dashboard title text.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Dashboard renders title', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: VisionApp()),
    );

    // Verify the header title is rendered.
    expect(find.text('VISION // QUADRUPED CONTROLLER'), findsOneWidget);
  });
}
