import '../../bloc/meeting/meeting_state.dart';
import '../../views.dart';

Map<int, Color> textColorSwatch = {
  50: const Color(0x80cdf6f7),
  100: const Color(0xFFCDF6F7),
  200: const Color(0xFF9BEDEF),
  300: const Color(0xff6ae5e8),
  400: const Color(0xFF38DCE0),
  500: const Color(0xFF06D3D8),
  600: const Color(0xFF05A9AD),
  700: const Color(0xff047f82),
  800: const Color(0xff025456),
  900: const Color(0xff012a2b),
};

class AppColors {
  static const Color primaryColor = Color(0xFF000000);
  static MaterialColor primerColor = MaterialColor(0xFF10203C, textColorSwatch);

  static const Color black = Color(0xFF000000);
  static const Color green = Color(0xFF2D7F3E);
  static const Color yellow = Color(0xFFFFEB3B);
  static const Color red = Color(0xFFFF0000);
  // static const Color darkRed = Color(0xFF8B0000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color outLineColor = Color(0xFFE9EBED);

  static const Color textColor = Color(0xFF404244);
  static const Color textDisableColor = Color(0xFFAEAEAE);

  // Bright colors
  static const Color brightYellowColor = Color.fromRGBO(255, 255, 0, 1.0);
  static const Color brightRedColor = Color.fromRGBO(255, 0, 0, 0.90);
  static const Color brightGreenColor = Color.fromRGBO(0, 255, 0, 0.70);

  // Solid colors with transparency
  static const Color solidYellowColor = Color.fromRGBO(255, 255, 0, 0.40);
  static const Color solidRedColor = Color.fromRGBO(255, 0, 0, 0.6);
  static const Color solidGreenColor = Color.fromRGBO(0, 255, 0, 0.29);

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
