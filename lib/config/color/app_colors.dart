import '../../bloc/meeting/meeting_state.dart';
import '../../views.dart';

class AppColors{
  static const Color black = Color(0xFF000000);
  static const Color green = Color(0xFF2D7F3E);
  static const Color yellow = Color(0xFFFFEB3B);
  static const Color red = Color(0xFFFF0000);
  static const Color darkRed = Color(0xFF8B0000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);

  // Bright colors
  static const Color brightYellowColor = Color.fromRGBO(255, 255, 0, 1.0);
  static const Color brightRedColor = Color.fromRGBO(255, 0, 0, 0.9);
  static const Color brightGreenColor = Color.fromRGBO(0, 255, 0, 0.7);

// Solid colors with transparency
  static const Color solidYellowColor = Color.fromRGBO(255, 255, 0, 0.4);
  static const Color solidRedColor = Color.fromRGBO(255, 0, 0, 0.4);
  static const Color solidGreenColor = Color.fromRGBO(0, 255, 0, 0.3);

  static Color getThemeColor(WatchStatus status) {
    switch (status) {
      case WatchStatus.green:
        return brightGreenColor;
      case WatchStatus.yellow:
        return brightYellowColor;
      case WatchStatus.red:
        return brightRedColor;
    }
  }

  static Color getPrimaryColor(WatchStatus status) {
    switch (status) {
      case WatchStatus.green:
        return green;
      case WatchStatus.yellow:
        return yellow;
      case WatchStatus.red:
        return red;
    }
  }
}