import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

class TimerState {
  final String timeLeft;
  final double progress;
  final bool isReverse;
  final String status;
  final bool isFinished;

  TimerState({
    required this.timeLeft,
    required this.progress,
    required this.isReverse,
    required this.status,
    this.isFinished = false,
  });

  // Initial state helper
  factory TimerState.initial() => TimerState(
    timeLeft: "00:00",
    progress: 0.0,
    isReverse: true,
    status: "Ready",
  );

  TimerState copyWith({
    String? timeLeft,
    double? progress,
    bool? isReverse,
    String? status,
    bool? isFinished,
  }) {
    return TimerState(
      timeLeft: timeLeft ?? this.timeLeft,
      progress: progress ?? this.progress,
      isReverse: isReverse ?? this.isReverse,
      status: status ?? this.status,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(TimerState.initial());

  Timer? _ticker;

  void startTimer({required int durationSeconds, bool isReverse = true}) {
    _ticker?.cancel();

    final int totalMs = durationSeconds * 1000;
    final startTime = DateTime.now();

    // Set initial UI based on mode
    state = state.copyWith(
      isReverse: isReverse,
      progress: isReverse ? 1.0 : 0.0,
      timeLeft: isReverse ? _formatTime(totalMs) : _formatTime(0),
      status: "Starting",
      isFinished: false,
    );

    _ticker = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;

      if (elapsedMs >= totalMs) {
        _ticker?.cancel();
        state = state.copyWith(
          timeLeft: isReverse ? _formatTime(0) : _formatTime(totalMs),
          progress: isReverse ? 0.0 : 1.0,
          isFinished: true,
          status: "Finished",
        );
      } else {
        _tick(elapsedMs, totalMs, isReverse);
      }
    });
  }

  void _tick(int elapsedMs, int totalMs, bool isReverse) {
    // Logic for Timer Text: Countdown if reverse, Stopwatch if not
    int displayMs = isReverse ? (totalMs - elapsedMs) : (totalMs - elapsedMs);
    // elapsedMs;

    // Logic for Progress Bar: Draining if reverse, Filling if not
    double rawProgress = (elapsedMs / totalMs).clamp(0.0, 1.0);
    double actualProgress = isReverse ? (1.0 - rawProgress) : rawProgress;

    // UI Status logic
    String currentStatus = (elapsedMs / totalMs) > 0.8 ? "Urgent" : "Running";

    state = state.copyWith(
      timeLeft: _formatTime(displayMs),
      progress: actualProgress,
      status: currentStatus,
    );
  }

  String _formatTime(int milliseconds) {
    int totalSeconds = (milliseconds / 1000).ceil();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
