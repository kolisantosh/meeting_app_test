import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/timer/timer_bloc.dart';
import '../../bloc/timer/timer_state.dart';
import '../../views.dart';

Widget buildCircularTimer() {
  return BlocBuilder<TimerBloc, TimerState>(
    builder: (context, state) {
      String time = "00:10";
      double progress = 0.0;

      if (state is TimerRunning) {
        time = state.timeLeft;
        progress = state.progress;
      } else if (state is TimerFinished) {
        time = "00:00";
        progress = 1.0;
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 450,
                height: 450,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 28,
                  strokeCap: StrokeCap.round, // Rounded ends for smooth look
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.redAccent,
                  ),
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 39,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          // const SizedBox(height: 24),
          // const Text(
          //   "Finalizing Setup...",
          //   style: TextStyle(color: Colors.white70, letterSpacing: 1.2),
          // ),
        ],
      );
    },
  );
}
