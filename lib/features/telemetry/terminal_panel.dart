/// ============================================================
/// terminal_panel.dart — Bottom panel: scrollable event terminal
/// ============================================================
///
/// A terminal-style scrollable log widget that renders green
/// monospace text on a near-black background.  On first build
/// it populates itself with mock log entries from
/// [kMockTerminalLogs] and auto-scrolls to the bottom.
library;

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';

/// Event terminal log panel.
///
/// Renders mock system log entries to simulate a live feed
/// of WebSocket data.  The [ScrollController] keeps the view
/// pinned to the latest entry.
class TerminalPanel extends StatefulWidget {
  const TerminalPanel({super.key});

  @override
  State<TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  final ScrollController _scrollController = ScrollController();

  /// Working list of log lines — in production this would be
  /// backed by a [StreamController] fed from a WebSocket.
  final List<String> _logs = List.from(kMockTerminalLogs);

  @override
  void initState() {
    super.initState();
    // Scroll to bottom after the first frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.terminalBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.terminalText.withAlpha(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Terminal header bar ----
          _buildHeaderBar(),

          // ---- Log entries ----
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Text(
                    _logs[index],
                    style: TextStyle(
                      color: _logColor(_logs[index]),
                      fontSize: 11,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Terminal header bar with title and decorative dots.
  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.terminalBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(
            color: AppColors.terminalText.withAlpha(20),
          ),
        ),
      ),
      child: Row(
        children: [
          // Traffic-light dots (decorative)
          _dot(AppColors.alertRed),
          const SizedBox(width: 6),
          _dot(const Color(0xFFFBBF24)),
          const SizedBox(width: 6),
          _dot(AppColors.alertGreen),
          const SizedBox(width: 14),

          Icon(Icons.terminal_rounded, size: 12, color: AppColors.terminalText),
          const SizedBox(width: 8),

          Text(
            'EVENT TERMINAL',
            style: TextStyle(
              color: AppColors.terminalText.withAlpha(200),
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          Text(
            '${_logs.length} entries',
            style: TextStyle(
              color: AppColors.terminalText.withAlpha(100),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  /// Colour-code log lines by their prefix keyword.
  Color _logColor(String line) {
    if (line.contains('ERROR') || line.contains('FAIL')) {
      return AppColors.alertRed;
    }
    if (line.contains('VISION')) return const Color(0xFF38BDF8); // Sky-400
    if (line.contains('MOTOR')) return const Color(0xFFFBBF24); // Amber-400
    if (line.contains('POWER')) return const Color(0xFFA78BFA); // Violet-400
    if (line.contains('NET')) return const Color(0xFF2DD4BF); // Teal-400
    return AppColors.terminalText; // Default green
  }

  /// Tiny decorative dot for the terminal title bar.
  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
