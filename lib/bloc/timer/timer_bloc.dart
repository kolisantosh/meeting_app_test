// timer_bloc.dart
import 'dart:async';

import 'package:fluttertest/bloc/timer/timer_event.dart';
import 'package:fluttertest/bloc/timer/timer_state.dart';

import '../../views.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  Timer? _ticker;
  bool _isReverse = false;

  TimerBloc() : super(TimerInitial()) {
    on<StartPopupTimer>((event, emit) {
      _ticker?.cancel();
      _isReverse = event.isReverse;
      final int totalMs = event.durationSeconds * 1000;
      final startTime = DateTime.now();

      // Initial progress: 0.0 for forward, 1.0 for reverse
      double initialProgress = _isReverse ? 1.0 : 0.0;
      emit(TimerRunning(_formatTime(totalMs), initialProgress));

      _ticker = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;

        if (elapsed >= totalMs) {
          add(FinishTimer());
        } else {
          // Calculate raw progress (0.0 to 1.0)
          double rawProgress = (elapsed / totalMs).clamp(0.0, 1.0);
          // Adjust for reverse mode
          double actualProgress = _isReverse
              ? (1.0 - rawProgress)
              : rawProgress;

          add(TickEvent(elapsed, actualProgress, totalMs));
        }
      });
    });

    on<TickEvent>((event, emit) {
      if (state is TimerFinished) return;

      // Calculate time string based on mode
      int displayMs =
          // _isReverse?
          (event.totalDurationMs - event.elapsedMs);
      // : event.elapsedMs;

      emit(TimerRunning(_formatTime(displayMs), event.progress));
    });

    on<FinishTimer>((event, emit) {
      _ticker?.cancel();
      emit(TimerFinished());
    });
  }

  String _formatTime(int milliseconds) {
    int totalSeconds = (milliseconds / 1000).ceil();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}

// import 'dart:async';
//
// import 'package:fluttertest/bloc/timer/timer_event.dart';
// import 'package:fluttertest/bloc/timer/timer_state.dart';
//
// import '../../views.dart';
//
// class TimerBloc extends Bloc<TimerEvent, TimerState> {
//   Timer? _ticker;
//   // Set to exactly 10 seconds
//   static const int _totalDurationMs = 10000;
//
//   TimerBloc() : super(TimerInitial()) {
//     on<StartPopupTimer>((event, emit) {
//       _ticker?.cancel();
//       final startTime = DateTime.now();
//
//       // Emit initial state immediately
//       emit(TimerRunning("00:10", 0.00));
//
//       _ticker = Timer.periodic(const Duration(milliseconds: 30), (timer) {
//         final elapsed = DateTime.now().difference(startTime).inMilliseconds;
//
//         if (elapsed >= _totalDurationMs) {
//           _ticker?.cancel();
//           add(FinishTimer());
//         } else {
//           final double progress = (elapsed / _totalDurationMs).clamp(0.0, 1.0);
//           add(TickEvent(elapsed, progress));
//         }
//       });
//     });
//
//     on<TickEvent>((event, emit) {
//       // Prevent state updates if we already signaled finished
//       if (state is TimerFinished) return;
//
//       int remainingMs = _totalDurationMs - event.elapsedMs;
//
//       // Use ceil to ensure 00:00 only shows at the absolute end
//       int seconds = (remainingMs / 1000).ceil();
//
//       // Clamp between 0 and 10
//       seconds = seconds.clamp(0, 10);
//
//       emit(
//         TimerRunning(
//           "00:${seconds.toString().padLeft(2, '0')}",
//           event.progress,
//         ),
//       );
//     });
//
//     on<FinishTimer>((event, emit) {
//       _ticker?.cancel();
//       // Force final state to match 100% exactly
//       emit(TimerFinished());
//     });
//   }
//
//   @override
//   Future<void> close() {
//     _ticker?.cancel();
//     return super.close();
//   }
// }
