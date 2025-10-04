import 'package:intl/intl.dart';

class TimeHelpers {
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm').format(dateTime);
  }

  static String formatTimeWithPeriod(DateTime dateTime) {
    return DateFormat('h:mma').format(dateTime).toLowerCase();
  }

  static String formatFullTime(DateTime dateTime) {
    final hour = DateFormat('h').format(dateTime);
    final minute = DateFormat('mm').format(dateTime);
    final period = DateFormat('a').format(dateTime).toUpperCase();
    return '$hour:$minute$period';
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('EEE, MMMM d').format(dateTime);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hrs ${minutes > 0 ? "$minutes mins" : ""}';
    } else {
      return '$minutes mins';
    }
  }

  static double getAngleForTime(DateTime time) {
    final hour = time.hour % 12;
    final minute = time.minute;
    final totalMinutes = hour * 60 + minute;
    return (totalMinutes / 720) * 360;
  }
}
