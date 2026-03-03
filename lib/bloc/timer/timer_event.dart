// abstract class TimerEvent {}
//
// /// Triggered when the user clicks the button to open the popup
// class StartPopupTimer extends TimerEvent {}
//
// /// Internal event fired every 30ms to update the UI
// class TickEvent extends TimerEvent {
//   final int elapsedMs;
//   final double progress;
//
//   TickEvent(this.elapsedMs, this.progress);
// }
//
// /// Triggered when the 15 seconds are complete
// class FinishTimer extends TimerEvent {}

// timer_event.dart
abstract class TimerEvent {}

class StartPopupTimer extends TimerEvent {
  final int durationSeconds;
  final bool isReverse;

  StartPopupTimer({required this.durationSeconds, this.isReverse = false});
}

class TickEvent extends TimerEvent {
  final int elapsedMs;
  final double progress;
  final int totalDurationMs; // Pass total to calculate dynamic time

  TickEvent(this.elapsedMs, this.progress, this.totalDurationMs);
}

class FinishTimer extends TimerEvent {}
