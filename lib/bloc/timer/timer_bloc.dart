import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertest/bloc/timer/timer_event.dart';
import 'package:fluttertest/bloc/timer/timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  Timer? _ticker;
  static const int _totalDurationMs = 10000; // Updated to 10 seconds

  TimerBloc() : super(TimerInitial()) {
    on<StartPopupTimer>((event, emit) {
      _ticker?.cancel();
      final startTime = DateTime.now();

      emit(TimerRunning("00:10", 0.00));

      _ticker = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;

        if (elapsed >= _totalDurationMs) {
          _ticker?.cancel();
          add(FinishTimer());
        } else {
          final double progress = elapsed / _totalDurationMs;
          add(TickEvent(elapsed, progress));
        }
      });
    });

    on<TickEvent>((event, emit) {
      int remainingMs = _totalDurationMs - event.elapsedMs;
      int seconds = (remainingMs / 1000).floor();

      emit(
        TimerRunning(
          "00:${seconds.toString().padLeft(2, '0')}",
          event.progress,
        ),
      );
    });

    on<FinishTimer>((event, emit) => emit(TimerFinished()));
  }
}
