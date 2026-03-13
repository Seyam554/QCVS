/// ============================================================
/// vision_panel.dart — Main center camera feed panel
/// ============================================================
///
/// The largest widget on the dashboard. Renders a live MJPEG
/// stream from the robot's camera, overlaid with a floating
/// YOLOv8n toggle switch and a user-editable camera URL bar.
///
/// The MJPEG viewer automatically uses the correct platform
/// implementation:
///   • **Web** → HTML `<img>` element (CORS-exempt)
///   • **Desktop** → HTTP streaming with JPEG frame parsing
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils.dart';
import 'mjpeg_view.dart'; // conditional import: web vs IO
import 'vision_providers.dart';

/// Displays the MJPEG camera feed with an overlaid YOLO toggle
/// and a configurable stream URL input bar at the bottom.
///
/// The stream URL is pulled from [cameraStreamUrlProvider] which
/// defaults to [kCameraStreamUrl] but can be changed by the user
/// at runtime via the input bar.
class VisionPanel extends ConsumerWidget {
  const VisionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yoloEnabled = ref.watch(yoloOverlayProvider);
    final streamUrl = ref.watch(cameraStreamUrlProvider);

    return GlassPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ---- Main feed area ----
          Expanded(
            child: Stack(
              children: [
                // ---- MJPEG Stream (platform-aware) ----
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: MjpegView(
                      key: ValueKey(streamUrl), // reconnect on URL change
                      streamUrl: streamUrl,
                    ),
                  ),
                ),

                // ---- Scan-line overlay for futuristic effect ----
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withAlpha(10),
                            Colors.transparent,
                            AppColors.primary.withAlpha(10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ---- Top-left stream label ----
                Positioned(
                  top: 12,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(60),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.alertRed,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.alertRed.withAlpha(150),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LIVE FEED',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    letterSpacing: 2,
                                    fontSize: 10,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---- YOLO Toggle (top-right) ----
                Positioned(
                  top: 12,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: yoloEnabled
                            ? AppColors.alertGreen.withAlpha(100)
                            : AppColors.primary.withAlpha(40),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.center_focus_strong_outlined,
                          size: 14,
                          color: yoloEnabled
                              ? AppColors.alertGreen
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'YOLOv8n AI',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: yoloEnabled
                                        ? AppColors.alertGreen
                                        : AppColors.textSecondary,
                                    letterSpacing: 1.5,
                                    fontSize: 10,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 20,
                          child: Switch(
                            value: yoloEnabled,
                            onChanged: (_) =>
                                ref.read(yoloOverlayProvider.notifier).toggle(),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---- Bottom: Camera URL Input Bar ----
          _CameraUrlBar(),
        ],
      ),
    );
  }
}

// ================================================================
// CAMERA URL INPUT BAR
// ================================================================

/// A sleek input bar at the bottom of the vision panel that lets
/// the user type a camera stream URL and press Connect.
///
/// Uses Riverpod to read/write the [cameraStreamUrlProvider].
/// When the user submits (Enter key or Connect button), the URL
/// is updated in the provider, which triggers a reconnect via
/// the [ValueKey] on the MJPEG widget.
class _CameraUrlBar extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CameraUrlBar> createState() => _CameraUrlBarState();
}

class _CameraUrlBarState extends ConsumerState<_CameraUrlBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(cameraStreamUrlProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConnect() {
    final url = _controller.text.trim();
    if (url.isNotEmpty) {
      ref.read(cameraStreamUrlProvider.notifier).setUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(200),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withAlpha(30),
          ),
        ),
      ),
      child: Row(
        children: [
          // ---- Label ----
          Icon(
            Icons.videocam_outlined,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'STREAM',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),

          // ---- URL Text Field ----
          Expanded(
            child: SizedBox(
              height: 32,
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _onConnect(),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: 'http://192.168.x.x:81/stream',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withAlpha(100),
                    fontSize: 11,
                  ),
                  filled: true,
                  fillColor: AppColors.surface.withAlpha(180),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primary.withAlpha(40),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primary.withAlpha(40),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ---- Connect Button ----
          SizedBox(
            height: 32,
            child: ElevatedButton.icon(
              onPressed: _onConnect,
              icon: const Icon(Icons.link_rounded, size: 14),
              label: const Text(
                'CONNECT',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withAlpha(30),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: AppColors.primary.withAlpha(80),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
