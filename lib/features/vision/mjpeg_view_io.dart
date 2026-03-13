/// ============================================================
/// mjpeg_view_io.dart — IO (Desktop/Mobile) MJPEG viewer
/// ============================================================
///
/// On non-web platforms there are no CORS restrictions, so we
/// can parse the MJPEG multipart stream directly over HTTP.
/// Each JPEG frame is extracted by scanning for SOI (0xFFD8)
/// and EOI (0xFFD9) markers in the byte stream.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/theme.dart';

/// IO-specific MJPEG stream viewer (Desktop / Mobile).
///
/// Opens a persistent HTTP GET connection to the camera's MJPEG
/// endpoint and renders each decoded JPEG frame using
/// [Image.memory] with [gaplessPlayback] to prevent flickering.
class MjpegView extends StatefulWidget {
  const MjpegView({super.key, required this.streamUrl});

  final String streamUrl;

  @override
  State<MjpegView> createState() => _MjpegViewState();
}

class _MjpegViewState extends State<MjpegView> {
  /// The latest decoded JPEG frame to display.
  Uint8List? _currentFrame;

  /// Whether we are currently connecting / loading.
  bool _isLoading = true;

  /// Error message if the stream fails.
  String? _error;

  /// HTTP client kept alive for the streaming connection.
  http.Client? _client;

  /// Subscription to the byte stream.
  StreamSubscription<List<int>>? _subscription;

  @override
  void initState() {
    super.initState();
    _connectToStream();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _client?.close();
    super.dispose();
  }

  /// Opens an HTTP GET request to the MJPEG endpoint and
  /// parses individual JPEG frames from the multipart stream.
  Future<void> _connectToStream() async {
    try {
      _client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.streamUrl));
      final response = await _client!.send(request);

      if (response.statusCode != 200) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'HTTP ${response.statusCode}';
          });
        }
        return;
      }

      // Buffer to accumulate incoming bytes
      final buffer = BytesBuilder(copy: false);

      // JPEG markers
      const jpegStart = [0xFF, 0xD8]; // SOI marker
      const jpegEnd = [0xFF, 0xD9]; // EOI marker

      _subscription = response.stream.listen(
        (chunk) {
          buffer.add(chunk);
          final bytes = buffer.toBytes();

          // Search for complete JPEG frames (SOI → EOI)
          int startIdx = -1;
          for (int i = 0; i < bytes.length - 1; i++) {
            if (bytes[i] == jpegStart[0] && bytes[i + 1] == jpegStart[1]) {
              startIdx = i;
            }
            if (startIdx != -1 &&
                bytes[i] == jpegEnd[0] &&
                bytes[i + 1] == jpegEnd[1]) {
              // Found a complete frame
              final frame = Uint8List.fromList(
                bytes.sublist(startIdx, i + 2),
              );

              if (mounted) {
                setState(() {
                  _currentFrame = frame;
                  _isLoading = false;
                  _error = null;
                });
              }

              // Keep remaining bytes after this frame
              final remaining = bytes.sublist(i + 2);
              buffer.clear();
              buffer.add(remaining);
              break;
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _error = error.toString();
            });
          }
        },
        onDone: () {
          if (mounted && _currentFrame == null) {
            setState(() {
              _isLoading = false;
              _error = 'Stream ended unexpectedly';
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Error state
    if (_error != null) {
      return _buildErrorState(_error!);
    }

    // Loading state
    if (_isLoading || _currentFrame == null) {
      return _buildLoadingState();
    }

    // Stream is live — display the latest frame
    return Image.memory(
      _currentFrame!,
      fit: BoxFit.cover,
      gaplessPlayback: true, // prevents flicker between frames
    );
  }

  /// Spinner + text shown while the MJPEG stream is connecting.
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
              'AWAITING VIDEO STREAM...',
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
  Widget _buildErrorState(String error) {
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
