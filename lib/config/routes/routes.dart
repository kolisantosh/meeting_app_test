import 'package:fluttertest/config/routes/routes_name.dart';
import 'package:fluttertest/view/meeting_details/details_screen.dart';
import 'package:fluttertest/views.dart';

import '../../models/meeting/meeting_model.dart';
import '../../view/dashboard/dashboard.dart';
import '../../view/login/login_screen.dart';
import '../../view/splash/splash.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings setting) {
    switch (setting.name) {
      case RoutesName.splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case RoutesName.login:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case RoutesName.dashboard:
        return MaterialPageRoute(builder: (context) => DashboardPage());
      case RoutesName.details:
        final args = setting.arguments;
        if (args is MeetingModel) {
          return MaterialPageRoute(
            builder: (context) => DetailScreen(meeting: args),
          );
        } else {
          return MaterialPageRoute(
            builder: (context) => Scaffold(body: Text("Invalid arguments")),
          );
        }

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(body: Text("no route denied")),
        );
    }
  }
}
