import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../logic/loading_watchdog.dart';
import '../../theme/app_theme.dart';

/// Overlay widget that appears when loading takes too long.
class LoadingWatchdogOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRetry;
  final VoidCallback? onDevHome;
  final bool enabled;

  const LoadingWatchdogOverlay({
    super.key,
    required this.child,
    this.onRetry,
    this.onDevHome,
    this.enabled = kDebugMode,
  });

  @override
  State<LoadingWatchdogOverlay> createState() => _LoadingWatchdogOverlayState();
}

class _LoadingWatchdogOverlayState extends State<LoadingWatchdogOverlay> {
  bool _showOverlay = false;
  String? _stuckCubit;
  Duration? _elapsed;
  StreamSubscription<LoadingTimeoutEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _subscription = LoadingWatchdogService.instance.timeoutStream.listen(
        _onTimeout,
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onTimeout(LoadingTimeoutEvent event) {
    if (!mounted) return;
    setState(() {
      _showOverlay = true;
      _stuckCubit = event.cubitName;
      _elapsed = event.elapsed;
    });
    print('[LoadingWatchdogOverlay] Showing overlay for: ${event.cubitName}');
  }

  void _handleRetry() {
    setState(() => _showOverlay = false);
    widget.onRetry?.call();
  }

  void _handleDevHome() {
    setState(() => _showOverlay = false);
    widget.onDevHome?.call();
  }

  void _handleReport() {
    print('=== LOADING WATCHDOG REPORT ===');
    print('Stuck Cubit: $_stuckCubit');
    print('Elapsed Time: ${_elapsed?.inSeconds}s');
    print('Timestamp: ${DateTime.now().toIso8601String()}');
    print('===============================');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report logged to console'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleDismiss() {
    setState(() => _showOverlay = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showOverlay && widget.enabled) _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    return GestureDetector(
      onTap: _handleDismiss,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tap-through
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_bottom,
                      color: Colors.orange,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    'Taking Too Long',
                    style: kSubtitleStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Message
                  Text(
                    'Something seems to be taking a while.\nTry reloading or continue to the app.',
                    style: kBodyStyle.copyWith(color: kTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                  if (kDebugMode && _stuckCubit != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Debug: $_stuckCubit (${_elapsed?.inSeconds}s)',
                      style: kBodyStyle.copyWith(
                        fontSize: 11,
                        color: kTextSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Retry button
                      ElevatedButton.icon(
                        onPressed: _handleRetry,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Continue button
                      OutlinedButton(
                        onPressed: _handleDevHome,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: kPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _handleReport,
                      child: Text(
                        'Report to Console',
                        style: kBodyStyle.copyWith(
                          color: kTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
