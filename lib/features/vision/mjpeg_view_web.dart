/// ============================================================
/// mjpeg_view_web.dart — Web MJPEG viewer using HTML <img> tag
/// ============================================================
///
/// On Flutter Web, direct HTTP requests to the camera are
/// blocked by the browser's CORS policy because the ESP32-CAM
/// (or similar) does not send `Access-Control-Allow-Origin`
/// headers.
///
/// **Solution:** The HTML `<img>` tag is exempt from CORS.
/// Browsers natively understand MJPEG multipart streams when
/// used as an `<img src="...">`.  We embed this via
/// [HtmlElementView] + [platformViewRegistry].
library;

// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Web-specific MJPEG stream viewer.
///
/// Creates an HTML `<img>` element whose `src` points directly
/// at the MJPEG endpoint.  The browser handles multipart JPEG
/// decoding natively — no manual byte parsing required.
class MjpegView extends StatefulWidget {
  const MjpegView({super.key, required this.streamUrl});

  /// The full MJPEG stream URL, e.g.
  /// `http://192.168.0.182:81/stream`
  final String streamUrl;

  @override
  State<MjpegView> createState() => _MjpegViewState();
}

class _MjpegViewState extends State<MjpegView> {
  /// Unique view type string used by [platformViewRegistry].
  late String _viewType;

  /// Tracks whether the <img> reported an error (offline / bad URL).
  bool _hasError = false;

  /// Tracks whether at least one frame has loaded.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _registerView();
  }

  /// Registers a platform view factory that creates an <img>
  /// element pointing at the MJPEG stream.
  void _registerView() {
    // Unique key per widget instance + URL to avoid collisions
    _viewType =
        'mjpeg-${widget.streamUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final img = html.ImageElement()
          ..src = widget.streamUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'cover'
          ..style.display = 'block'
          ..style.background = '#0F172A'; // Match AppColors.background

        // --- Event listeners ---
        img.onLoad.listen((_) {
          if (mounted && _isLoading) {
            setState(() => _isLoading = false);
          }
        });

        img.onError.listen((_) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          }
        });

        return img;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        // The actual HTML <img> element embedded in Flutter
        HtmlElementView(viewType: _viewType),

        // Loading overlay (shown until the first frame arrives)
        if (_isLoading) _buildLoadingState(),
      ],
    );
  }

  /// Spinner + text shown while the stream is connecting.
  Widget _buildLoadingState() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'CONNECTING TO STREAM...',
              style: TextStyle(
                color: AppColors.textSecondary,
                letterSpacing: 3,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.streamUrl,
              style: TextStyle(
                color: AppColors.primary.withAlpha(120),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error state shown when the camera stream cannot be reached.
  Widget _buildErrorState() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_off_outlined,
              color: AppColors.alertRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'STREAM OFFLINE',
              style: TextStyle(
                color: AppColors.alertRed,
                letterSpacing: 3,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to connect to ${widget.streamUrl}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
