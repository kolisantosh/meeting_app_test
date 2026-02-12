abstract class TimerState {}

class TimerInitial extends TimerState {}

class TimerRunning extends TimerState {
  final String timeLeft; // e.g., "00:02"
  final double progress; // e.g., 0.8
  TimerRunning(this.timeLeft, this.progress);
}

class TimerFinished extends TimerState {}
