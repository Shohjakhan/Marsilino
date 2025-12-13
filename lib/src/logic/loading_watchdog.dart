import 'dart:async';
import 'package:flutter/foundation.dart';

/// Callback for watchdog events.
typedef WatchdogCallback = void Function(String cubitName, Duration elapsed);

/// Watchdog to detect stuck loading states.
class LoadingWatchdog {
  static const _defaultTimeout = Duration(seconds: 12);

  final Duration timeout;
  final WatchdogCallback? onTimeout;
  final bool enabled;

  Timer? _timer;
  String? _currentCubit;
  DateTime? _loadingStartTime;

  LoadingWatchdog({
    this.timeout = _defaultTimeout,
    this.onTimeout,
    this.enabled = kDebugMode, // Only enabled in debug by default
  });

  /// Start watching a cubit's loading state.
  void startWatching(String cubitName) {
    if (!enabled) return;

    _currentCubit = cubitName;
    _loadingStartTime = DateTime.now();

    print('[LoadingWatchdog] Started watching: $cubitName');

    _timer?.cancel();
    _timer = Timer(timeout, () {
      final elapsed = DateTime.now().difference(_loadingStartTime!);
      print(
        '[LoadingWatchdog] ⚠️ TIMEOUT: $cubitName has been loading for ${elapsed.inSeconds}s',
      );
      onTimeout?.call(cubitName, elapsed);
    });
  }

  /// Stop watching (call when loading finishes).
  void stopWatching(String cubitName) {
    if (!enabled) return;

    if (_currentCubit == cubitName) {
      final elapsed = _loadingStartTime != null
          ? DateTime.now().difference(_loadingStartTime!)
          : Duration.zero;
      print(
        '[LoadingWatchdog] Stopped watching: $cubitName (took ${elapsed.inMilliseconds}ms)',
      );
      _reset();
    }
  }

  /// Reset watchdog state.
  void _reset() {
    _timer?.cancel();
    _timer = null;
    _currentCubit = null;
    _loadingStartTime = null;
  }

  /// Dispose of the watchdog.
  void dispose() {
    _reset();
  }

  /// Get current loading cubit name.
  String? get currentlyWatching => _currentCubit;

  /// Get elapsed time if currently watching.
  Duration? get elapsedTime {
    if (_loadingStartTime == null) return null;
    return DateTime.now().difference(_loadingStartTime!);
  }
}

/// Global loading watchdog instance.
class LoadingWatchdogService {
  static final LoadingWatchdogService _instance = LoadingWatchdogService._();
  static LoadingWatchdogService get instance => _instance;

  LoadingWatchdogService._();

  final Map<String, LoadingWatchdog> _watchdogs = {};
  final _timeoutController = StreamController<LoadingTimeoutEvent>.broadcast();

  Stream<LoadingTimeoutEvent> get timeoutStream => _timeoutController.stream;

  /// Get or create a watchdog for a cubit.
  LoadingWatchdog getWatchdog(String cubitName) {
    return _watchdogs.putIfAbsent(
      cubitName,
      () => LoadingWatchdog(
        onTimeout: (name, elapsed) {
          _timeoutController.add(
            LoadingTimeoutEvent(cubitName: name, elapsed: elapsed),
          );
        },
      ),
    );
  }

  /// Report that a cubit started loading.
  void reportLoadingStart(String cubitName) {
    getWatchdog(cubitName).startWatching(cubitName);
  }

  /// Report that a cubit finished loading.
  void reportLoadingEnd(String cubitName) {
    getWatchdog(cubitName).stopWatching(cubitName);
  }

  /// Dispose all watchdogs.
  void dispose() {
    for (final watchdog in _watchdogs.values) {
      watchdog.dispose();
    }
    _watchdogs.clear();
    _timeoutController.close();
  }
}

/// Event emitted when a loading timeout occurs.
class LoadingTimeoutEvent {
  final String cubitName;
  final Duration elapsed;
  final DateTime timestamp;

  LoadingTimeoutEvent({required this.cubitName, required this.elapsed})
    : timestamp = DateTime.now();

  @override
  String toString() =>
      'LoadingTimeoutEvent(cubit: $cubitName, elapsed: ${elapsed.inSeconds}s)';
}
